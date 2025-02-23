{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Wno-deferred-out-of-scope-variables #-}

-- | Chain component implementation which uses directly the Node-to-Client
-- protocols to submit "hand-rolled" transactions.
module Hydra.Chain.Direct (
  NetworkMagic (NetworkMagic),
  withIOManager,
  module Hydra.Chain.Direct,
) where

import Hydra.Prelude

import Cardano.Ledger.Alonzo.Rules.Utxo (UtxoPredicateFailure (UtxosFailure))
import Cardano.Ledger.Alonzo.Rules.Utxos (FailureDescription (PlutusFailure), TagMismatchDescription (FailedUnexpectedly), UtxosPredicateFailure (ValidationTagMismatch))
import Cardano.Ledger.Alonzo.Rules.Utxow (UtxowPredicateFail (WrappedShelleyEraFailure))
import Cardano.Ledger.Alonzo.TxInfo (PlutusDebugInfo (..), debugPlutus, slotToPOSIXTime)
import Cardano.Ledger.Babbage.PParams (PParams' (..))
import Cardano.Ledger.Babbage.Rules.Utxo (BabbageUtxoPred (FromAlonzoUtxoFail))
import Cardano.Ledger.Babbage.Rules.Utxow (BabbageUtxowPred (FromAlonzoUtxowFail))
import Cardano.Ledger.Babbage.Tx (ValidatedTx)
import Cardano.Ledger.Shelley.API (ApplyTxError (ApplyTxError))
import qualified Cardano.Ledger.Shelley.API as Ledger
import Cardano.Ledger.Shelley.Rules.Ledger (LedgerPredicateFailure (UtxowFailure))
import Cardano.Ledger.Shelley.Rules.Utxow (UtxowPredicateFailure (UtxoFailure))
import Cardano.Ledger.Slot (EpochInfo)
import Cardano.Slotting.EpochInfo (hoistEpochInfo)
import Control.Exception (IOException)
import Control.Monad.Class.MonadSTM (
  newEmptyTMVar,
  newTQueueIO,
  newTVarIO,
  putTMVar,
  readTQueue,
  takeTMVar,
  writeTQueue,
 )
import Control.Monad.Trans.Except (runExcept)
import Control.Tracer (nullTracer)
import Data.List ((\\))
import Hydra.Cardano.Api (
  CardanoMode,
  ChainPoint (..),
  Era,
  EraHistory (EraHistory),
  LedgerEra,
  NetworkId,
  PaymentKey,
  SigningKey,
  Tx,
  VerificationKey,
  fromConsensusPointHF,
  shelleyBasedEra,
  toConsensusPointHF,
  toLedgerPParams,
  toLedgerUTxO,
 )
import qualified Hydra.Cardano.Api as Api
import Hydra.Chain (
  ChainComponent,
  PostTxError (..),
 )
import Hydra.Chain.CardanoClient (
  QueryPoint (QueryAt),
  queryEraHistory,
  queryProtocolParameters,
  querySystemStart,
  queryTip,
  queryUTxO,
 )
import Hydra.Chain.Direct.Handlers (
  ChainSyncHandler,
  DirectChainLog (..),
  RecordedAt (..),
  SomeOnChainHeadStateAt (..),
  TimeHandle (..),
  chainSyncHandler,
  mkChain,
  onRollBackward,
  onRollForward,
 )
import Hydra.Chain.Direct.State (
  SomeOnChainHeadState (..),
  idleOnChainHeadState,
 )
import Hydra.Chain.Direct.Util (
  Block,
  defaultCodecs,
  nullConnectTracers,
  versions,
 )
import Hydra.Chain.Direct.Wallet (
  TinyWallet (..),
  getTxId,
  newTinyWallet,
 )
import Hydra.Logging (Tracer, traceWith)
import Hydra.Party (Party)
import Ouroboros.Consensus.Cardano.Block (
  GenTx (..),
  HardForkApplyTxErr (ApplyTxErrBabbage),
 )
import qualified Ouroboros.Consensus.HardFork.History as Consensus
import Ouroboros.Consensus.Ledger.SupportsMempool (ApplyTxErr)
import Ouroboros.Consensus.Network.NodeToClient (Codecs' (..))
import Ouroboros.Consensus.Shelley.Ledger.Mempool (mkShelleyTx)
import Ouroboros.Network.Block (Point (..), Tip, getTipPoint)
import Ouroboros.Network.Magic (NetworkMagic (..))
import Ouroboros.Network.Mux (
  MuxMode (..),
  MuxPeer (MuxPeer),
  OuroborosApplication (..),
  RunMiniProtocol (..),
 )
import Ouroboros.Network.NodeToClient (
  IOManager,
  LocalAddress,
  NodeToClientProtocols (..),
  NodeToClientVersion,
  connectTo,
  localSnocket,
  localStateQueryPeerNull,
  localTxMonitorPeerNull,
  nodeToClientProtocols,
  withIOManager,
 )
import Ouroboros.Network.Protocol.ChainSync.Client (
  ChainSyncClient (..),
  ClientStIdle (..),
  ClientStIntersect (..),
  ClientStNext (..),
  chainSyncClientPeer,
 )
import Ouroboros.Network.Protocol.LocalTxSubmission.Client (
  LocalTxClientStIdle (..),
  LocalTxSubmissionClient (..),
  SubmitResult (..),
  localTxSubmissionClientPeer,
 )
import Test.Cardano.Ledger.Alonzo.Serialisation.Generators ()

withDirectChain ::
  -- | Tracer for logging
  Tracer IO DirectChainLog ->
  -- | Network identifer to which we expect to connect.
  NetworkId ->
  -- | A cross-platform abstraction for managing I/O operations on local sockets
  IOManager ->
  -- | Path to a domain socket used to connect to the server.
  FilePath ->
  -- | Key pair for the wallet.
  (VerificationKey PaymentKey, SigningKey PaymentKey) ->
  -- | Hydra party of our hydra node.
  Party ->
  -- | Cardano keys of all Head participants (including our key pair).
  [VerificationKey PaymentKey] ->
  -- | Point at which to start following the chain.
  Maybe ChainPoint ->
  ChainComponent Tx IO a
withDirectChain tracer networkId iocp socketPath keyPair party cardanoKeys point callback action = do
  queue <- newTQueueIO
  wallet <- newTinyWallet (contramap Wallet tracer) networkId keyPair queryUTxOEtc
  let (vk, _) = keyPair
  headState <-
    newTVarIO $
      SomeOnChainHeadStateAt
        { currentOnChainHeadState =
            SomeOnChainHeadState $
              idleOnChainHeadState networkId (cardanoKeys \\ [vk]) vk party
        , recordedAt = AtStart
        }
  res <-
    race
      ( do
          -- FIXME: There's currently a race-condition with the actual client
          -- which will only see transactions after it has established
          -- connection with the server's tip. So any transaction submitted
          -- before that tip will be missed.
          threadDelay 2
          action $
            mkChain
              tracer
              (queryTimeHandle networkId socketPath)
              cardanoKeys
              wallet
              headState
              (submitTx queue)
      )
      ( handle onIOException $ do
          let intersection = toConsensusPointHF <$> point
          let client = ouroborosApplication tracer intersection queue (chainSyncHandler tracer callback headState) wallet
          connectTo
            (localSnocket iocp)
            nullConnectTracers
            (versions networkId client)
            socketPath
      )
  case res of
    Left a -> pure a
    Right () -> error "'connectTo' cannot terminate but did?"
 where
  queryUTxOEtc queryPoint address = do
    utxo <- Ledger.unUTxO . toLedgerUTxO <$> queryUTxO networkId socketPath queryPoint [address]
    pparams <- toLedgerPParams (shelleyBasedEra @Api.Era) <$> queryProtocolParameters networkId socketPath queryPoint
    systemStart <- querySystemStart networkId socketPath queryPoint
    epochInfo <- toEpochInfo <$> queryEraHistory networkId socketPath queryPoint
    pure (utxo, pparams, systemStart, epochInfo)

  toEpochInfo :: EraHistory CardanoMode -> EpochInfo (Either Text)
  toEpochInfo (EraHistory _ interpreter) =
    hoistEpochInfo (first show . runExcept) $
      Consensus.interpreterToEpochInfo interpreter

  submitTx queue vtx = do
    response <- atomically $ do
      response <- newEmptyTMVar
      writeTQueue queue (vtx, response)
      return response
    atomically (takeTMVar response)
      >>= maybe (pure ()) throwIO

  onIOException :: IOException -> IO ()
  onIOException ioException =
    throwIO $
      ConnectException
        { ioException
        , socketPath
        , networkId
        }

-- | Query ad-hoc epoch, system start and protocol parameters to determine
-- current point in time.
queryTimeHandle :: NetworkId -> FilePath -> IO TimeHandle
queryTimeHandle networkId socketPath = do
  tip@(ChainPoint slotNo _) <- queryTip networkId socketPath
  systemStart <- querySystemStart networkId socketPath (QueryAt tip)
  eraHistory <- queryEraHistory networkId socketPath (QueryAt tip)
  let epochInfo = toEpochInfo eraHistory
  pparams <- queryProtocolParameters networkId socketPath (QueryAt tip)
  let toTime =
        slotToPOSIXTime
          (toLedgerPParams (shelleyBasedEra @Era) pparams)
          epochInfo
          systemStart
  pure $
    TimeHandle
      { currentPointInTime = (slotNo,) <$> toTime slotNo
      , adjustPointInTime = \n (slot, _) -> do
          let adjusted = slot + n
          time <- toTime adjusted
          pure (adjusted, time)
      }
 where
  toEpochInfo :: EraHistory CardanoMode -> EpochInfo (Either Text)
  toEpochInfo (EraHistory _ interpreter) =
    hoistEpochInfo (first show . runExcept) $
      Consensus.interpreterToEpochInfo interpreter

data ConnectException = ConnectException
  { ioException :: IOException
  , socketPath :: FilePath
  , networkId :: NetworkId
  }
  deriving (Show)

instance Exception ConnectException

-- | Thrown when the user-provided custom point of intersection is unknown to
-- the local node. This may happen if users shut down their node quickly after
-- starting them and hold on a not-so-stable point of the chain. When they turn
-- the node back on, that point may no longer exist on the network if a fork
-- with deeper roots has been adopted in the meantime.
newtype IntersectionNotFoundException = IntersectionNotFound
  { requestedPoint :: Point Block
  }
  deriving (Show)

instance Exception IntersectionNotFoundException

ouroborosApplication ::
  (MonadST m, MonadTimer m, MonadThrow m) =>
  Tracer m DirectChainLog ->
  Maybe (Point Block) ->
  TQueue m (ValidatedTx LedgerEra, TMVar m (Maybe (PostTxError Tx))) ->
  ChainSyncHandler m ->
  TinyWallet m ->
  NodeToClientVersion ->
  OuroborosApplication 'InitiatorMode LocalAddress LByteString m () Void
ouroborosApplication tracer point queue handler wallet nodeToClientV =
  nodeToClientProtocols
    ( const $
        pure $
          NodeToClientProtocols
            { localChainSyncProtocol =
                InitiatorProtocolOnly $
                  let peer = chainSyncClient handler wallet point
                   in MuxPeer nullTracer cChainSyncCodec (chainSyncClientPeer peer)
            , localTxSubmissionProtocol =
                InitiatorProtocolOnly $
                  let peer = txSubmissionClient tracer queue
                   in MuxPeer nullTracer cTxSubmissionCodec (localTxSubmissionClientPeer peer)
            , localStateQueryProtocol =
                InitiatorProtocolOnly $
                  let peer = localStateQueryPeerNull
                   in MuxPeer nullTracer cStateQueryCodec peer
            , localTxMonitorProtocol =
                InitiatorProtocolOnly $
                  let peer = localTxMonitorPeerNull
                   in MuxPeer nullTracer cTxMonitorCodec peer
            }
    )
    nodeToClientV
 where
  Codecs
    { cChainSyncCodec
    , cTxSubmissionCodec
    , cStateQueryCodec
    , cTxMonitorCodec
    } = defaultCodecs nodeToClientV

chainSyncClient ::
  forall m.
  (MonadSTM m, MonadThrow m) =>
  ChainSyncHandler m ->
  TinyWallet m ->
  Maybe (Point Block) ->
  ChainSyncClient Block (Point Block) (Tip Block) m ()
chainSyncClient handler wallet = \case
  Nothing ->
    ChainSyncClient (pure initStIdle)
  Just startingPoint ->
    ChainSyncClient $
      pure $ do
        SendMsgFindIntersect
          [startingPoint]
          ( clientStIntersect
              (\_ -> throwIO (IntersectionNotFound startingPoint))
          )
 where
  -- NOTE:
  -- We fast-forward the chain client to the current node's tip on start, and
  -- from there, follow the chain block by block as they arrive. This is why the
  -- chain client here has no state (and needs no persistence of previously seen
  -- headers). It fits with the narrative of heads being online all-the-time;
  -- history prior to when the client is created is thus not needed.
  --
  -- To acquire the chain tip, we leverage the fact that in any responses, the
  -- server will send its current tip, which can then find an intersection with.
  -- Hence the first `SendMsgRequestNext` which sole purpose is to get the
  -- server's tip. Note that the findIntersect can fail after that if the server
  -- switches to a different chain fork in between the two calls, in which case
  -- we'll start over the last step with the new tip.
  initStIdle :: ClientStIdle Block (Point Block) (Tip Block) m ()
  initStIdle = SendMsgRequestNext initStNext (pure initStNext)
   where
    initStNext :: ClientStNext Block (Point Block) (Tip Block) m ()
    initStNext =
      ClientStNext
        { recvMsgRollForward = \_ (getTipPoint -> tip) ->
            ChainSyncClient $ findIntersect tip
        , recvMsgRollBackward = \_ (getTipPoint -> tip) ->
            ChainSyncClient $ findIntersect tip
        }

    findIntersect :: Point Block -> m (ClientStIdle Block (Point Block) (Tip Block) m ())
    findIntersect tip =
      pure $ SendMsgFindIntersect [tip] (clientStIntersect findIntersect)

  clientStIntersect ::
    (Point Block -> m (ClientStIdle Block (Point Block) (Tip Block) m ())) ->
    ClientStIntersect Block (Point Block) (Tip Block) m ()
  clientStIntersect onIntersectionNotFound =
    ClientStIntersect
      { recvMsgIntersectFound = \_ _ ->
          ChainSyncClient (pure clientStIdle)
      , recvMsgIntersectNotFound = \(getTipPoint -> tip) ->
          ChainSyncClient $ onIntersectionNotFound tip
      }

  clientStIdle :: ClientStIdle Block (Point Block) (Tip Block) m ()
  clientStIdle = SendMsgRequestNext clientStNext (pure clientStNext)

  clientStNext :: ClientStNext Block (Point Block) (Tip Block) m ()
  clientStNext =
    ClientStNext
      { recvMsgRollForward = \block _tip -> ChainSyncClient $ do
          -- Update the tiny wallet
          update wallet block
          -- Observe Hydra transactions
          onRollForward handler block
          pure clientStIdle
      , recvMsgRollBackward = \point _tip -> ChainSyncClient $ do
          -- Re-initialize the tiny wallet
          reset wallet $ QueryAt (fromConsensusPointHF point)
          -- Rollback main chain sync handler
          onRollBackward handler point
          pure clientStIdle
      }

txSubmissionClient ::
  forall m.
  (MonadSTM m) =>
  Tracer m DirectChainLog ->
  TQueue m (ValidatedTx LedgerEra, TMVar m (Maybe (PostTxError Tx))) ->
  LocalTxSubmissionClient (GenTx Block) (ApplyTxErr Block) m ()
txSubmissionClient tracer queue =
  LocalTxSubmissionClient clientStIdle
 where
  clientStIdle :: m (LocalTxClientStIdle (GenTx Block) (ApplyTxErr Block) m ())
  clientStIdle = do
    (tx, response) <- atomically $ readTQueue queue
    traceWith tracer (PostingTx (getTxId tx, tx))
    pure $
      SendMsgSubmitTx
        (GenTxBabbage . mkShelleyTx $ tx)
        ( \case
            SubmitSuccess -> do
              traceWith tracer (PostedTx (getTxId tx))
              atomically (putTMVar response Nothing)
              clientStIdle
            SubmitFail reason -> do
              atomically (putTMVar response (Just $ onFail reason))
              clientStIdle
        )

  -- XXX(SN): patch-work error pretty printing on single plutus script failures
  onFail err =
    case err of
      ApplyTxErrBabbage (ApplyTxError [failure]) ->
        fromMaybe failedToPostTx (unwrapPlutus failure)
      _ ->
        failedToPostTx
   where
    failedToPostTx = FailedToPostTx{failureReason = show err}

  unwrapPlutus :: LedgerPredicateFailure LedgerEra -> Maybe (PostTxError Tx)
  unwrapPlutus = \case
    UtxowFailure (FromAlonzoUtxowFail (WrappedShelleyEraFailure (UtxoFailure (FromAlonzoUtxoFail (UtxosFailure (ValidationTagMismatch _ (FailedUnexpectedly (PlutusFailure plutusFailure debug :| _)))))))) ->
      let plutusDebugInfo =
            case debugPlutus (decodeUtf8 debug) of
              DebugSuccess budget -> "DebugSuccess: " <> show budget
              DebugCannotDecode err -> "DebugCannotDecode: " <> fromString err
              DebugInfo logs err _debug ->
                unlines
                  [ "DebugInfo:"
                  , "  Error: " <> show err
                  , "  Logs:"
                  ]
                  <> unlines (fmap ("    " <>) logs)
              DebugBadHex err -> "DebugBadHex: " <> fromString err
       in Just $ PlutusValidationFailed{plutusFailure, plutusDebugInfo}
    _ ->
      Nothing
