module Enecuum.Blockchain.DB.Entities.Types where

import           Enecuum.Prelude
import qualified Enecuum.Blockchain.Domain.KBlock as D

type KBlockIdx      = D.BlockNumber
type MBlockIdx      = D.BlockNumber
type TransactionIdx = Word32
type DBIndex        = Word32