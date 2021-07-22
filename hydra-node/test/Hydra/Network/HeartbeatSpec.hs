module Hydra.Network.HeartbeatSpec where

import Hydra.Prelude

import Control.Monad.Class.MonadSTM (MonadSTM (readTVarIO), modifyTVar', newTVarIO)
import Control.Monad.IOSim (runSimOrThrow)
import Hydra.Network (Host (..), Network (..))
import Hydra.Network.Heartbeat (Heartbeat (..), withHeartbeat)
import Hydra.Network.Message (Message (Connected, Disconnected, ReqTx))
import Test.Hspec (Spec, describe, it, shouldBe)

spec :: Spec
spec = describe "Heartbeat" $ do
  let captureOutgoing msgqueue _cb action =
        action $ Network{broadcast = \msg -> atomically $ modifyTVar' msgqueue (msg :)}

      captureIncoming receivedMessages msg =
        atomically $ modifyTVar' receivedMessages (msg :)

  it "sends a heartbeat message with own party id after 500 ms" $ do
    let sentHeartbeats = runSimOrThrow $ do
          sentMessages <- newTVarIO ([] :: [Heartbeat (Message Integer)])

          withHeartbeat 1 (captureOutgoing sentMessages) noop $ \_ ->
            threadDelay 1.1

          readTVarIO sentMessages

    sentHeartbeats `shouldBe` [Ping 1]

  it "sends Connected when Ping received from other party" $ do
    let receivedHeartbeats = runSimOrThrow $ do
          receivedMessages <- newTVarIO ([] :: [Message Integer])

          withHeartbeat 1 (\incoming _ -> incoming (Ping 2)) (captureIncoming receivedMessages) $ \_ ->
            threadDelay 1

          readTVarIO receivedMessages

    receivedHeartbeats `shouldBe` [Connected 2]

  it "sends Connected when any message received from other party" $ do
    let receivedHeartbeats = runSimOrThrow $ do
          receivedMessages <- newTVarIO ([] :: [Message Integer])

          withHeartbeat 1 (\incoming _ -> incoming (Data $ ReqTx 2 1)) (captureIncoming receivedMessages) $ \_ ->
            threadDelay 1

          readTVarIO receivedMessages

    receivedHeartbeats `shouldBe` [ReqTx 2 1, Connected 2]

  it "do not send Connected on subsequent messages from already Connected party" $ do
    let receivedHeartbeats = runSimOrThrow $ do
          receivedMessages <- newTVarIO ([] :: [Message Integer])

          withHeartbeat 1 (\incoming _ -> incoming (Data $ ReqTx 2 1) >> incoming (Ping 2)) (captureIncoming receivedMessages) $ \_ ->
            threadDelay 1

          readTVarIO receivedMessages

    receivedHeartbeats `shouldBe` [ReqTx 2 1, Connected 2]

  it "sends Disconnected given no messages has been received from known party within twice heartbeat delay" $ do
    let receivedHeartbeats = runSimOrThrow $ do
          receivedMessages <- newTVarIO ([] :: [Message Integer])

          let component incoming action =
                race_
                  (action (Network noop))
                  (incoming (Ping 2) >> threadDelay 4 >> incoming (Ping 2) >> threadDelay 7)

          withHeartbeat 1 component (captureIncoming receivedMessages) $ \_ ->
            threadDelay 20

          readTVarIO receivedMessages

    receivedHeartbeats `shouldBe` [Disconnected 2, Connected 2]

  it "stop sending heartbeat message given action sends a message" $ do
    let someMessage = ReqTx 1 1
        sentHeartbeats = runSimOrThrow $ do
          sentMessages <- newTVarIO ([] :: [Heartbeat (Message Integer)])

          withHeartbeat 1 (captureOutgoing sentMessages) noop $ \Network{broadcast} -> do
            threadDelay 0.6
            broadcast someMessage
            threadDelay 1

          readTVarIO sentMessages

    sentHeartbeats `shouldBe` [Data someMessage, Ping 1]

  it "restart sending heartbeat messages given last message sent is older than heartbeat delay" $ do
    let someMessage = ReqTx 1 1
        sentHeartbeats = runSimOrThrow $ do
          sentMessages <- newTVarIO ([] :: [Heartbeat (Message Integer)])

          withHeartbeat 1 (captureOutgoing sentMessages) noop $ \Network{broadcast} -> do
            threadDelay 0.6
            broadcast someMessage
            threadDelay 3.6

          readTVarIO sentMessages

    sentHeartbeats `shouldBe` [Ping 1, Data someMessage, Ping 1]

testHost :: Host
testHost = Host{hostName = "0.0.0.0", portNumber = 4000}

noop :: Monad m => b -> m ()
noop = const $ pure ()
