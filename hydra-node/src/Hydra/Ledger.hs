module Hydra.Ledger where

import Cardano.Prelude hiding (undefined)

-- NOTE(MB): We probably want to move these common types somewhere else. Putting
-- here to avoid circular dependencies with Hydra.Logic

type Committed = Map ParticipationToken Amount

-- | Naiive representation of value, which is likely to change.
type Amount = Natural

-- | Identifies the commit of a single party member
data ParticipationToken = ParticipationToken
  { totalTokens :: Natural
  , thisToken :: Party
  }
  deriving (Eq, Ord, Show, Read)

-- | Identifies a party in a Hydra head.
type Party = Natural

-- * Ledger interface

class
  ( Eq tx
  , Eq (UTxO tx)
  , Show tx
  , Show (UTxO tx)
  ) =>
  Tx tx
  where
  type UTxO tx

data Ledger tx = Ledger
  { canApply :: UTxO tx -> tx -> ValidationResult
  , applyTransaction :: UTxO tx -> tx -> Either ValidationError (UTxO tx)
  , initLedgerState :: UTxO tx
  }

makeUTxO :: forall tx. Ledger tx -> UTxO tx -> [tx] -> Either ValidationError (UTxO tx)
makeUTxO Ledger{applyTransaction} = foldM applyTransaction

-- | Either valid or an error which we get from the ledger-specs tx validation.
data ValidationResult
  = Valid
  | Invalid ValidationError
  deriving (Eq, Show)

data ValidationError = ValidationError deriving (Eq, Show)
