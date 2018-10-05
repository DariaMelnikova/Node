module Enecuum.Blockchain.Domain.Generate where

import Enecuum.Prelude hiding (Ordering)
import Enecuum.Blockchain.Domain.Graph
import Enecuum.Blockchain.Domain.KBlock
import Enecuum.Blockchain.Domain.Transaction
import Enecuum.Blockchain.Domain.Microblock
import Data.HGraph.StringHashable (StringHash (..),toHash)
import qualified Enecuum.Language              as L
import Data.List (delete)

data Ordering = InOrder | RandomOrder

kBlockInBunch :: Integer
kBlockInBunch = 5

generateNKBlocks = generateKBlocks genesisHash
generateNKBlocksWithOrder = createKBlocks genesisHash

-- Generate bunch of key blocks (randomly or in order)
createKBlocks :: StringHash -> Integer -> Ordering -> Free L.NodeF [KBlock]
createKBlocks prevKBlockHash from order = do
  kBlockBunch <- generateKBlocks prevKBlockHash from
  kBlockIndices <- generateIndices order
  let kBlocks = map ((kBlockBunch !! )  . fromIntegral) kBlockIndices
  pure kBlocks

-- Generate bunch of key blocks
generateKBlocks :: StringHash -> Integer -> Free L.NodeF [KBlock]
generateKBlocks prevHash from = loopGenKBlock prevHash from (from + kBlockInBunch)

-- loop - state substitute : create new Kblock using hash of previous
loopGenKBlock :: StringHash -> Integer -> Integer -> Free L.NodeF [KBlock]
loopGenKBlock prevHash from to = do
  let kblock = genKBlock prevHash from
      newPrevHash = toHash kblock
  if (from < to)
    then do
      rest <- loopGenKBlock newPrevHash (from + 1) to
      return (kblock:rest)
    else return []

genKBlock :: StringHash -> Integer -> KBlock
genKBlock prevHash i = KBlock
    { _prevHash   = prevHash
    , _number     = i
    , _nonce      = i
    , _solver     = toHash (i + 3)
    }

genNTransactions :: Int -> L.NodeL [Transaction]
genNTransactions k =  do
  numbers <- replicateM k $ L.getRandomInt (0, 1000)
  pure $ map genTransaction numbers

genTransaction :: Integer -> Transaction
genTransaction i =  Transaction
    { _owner     = i
    , _receiver  = i + 100
    , _amount    = i + 7
    }

genMicroblock :: StringHash -> [Transaction] -> Microblock
genMicroblock hashofKeyBlock tx = Microblock
    { _keyBlock     = hashofKeyBlock
    , _transactions = tx
    }

generateIndices :: Ordering -> Free L.NodeF [Integer]
generateIndices order = do
  case order of
    RandomOrder -> loopGenIndices [0 .. kBlockInBunch]
    InOrder -> pure $ [0 .. kBlockInBunch]

-- loop: choose randomly one from the rest of list Integers
-- example:
-- [1,2,3,4,5] - 2
-- [1,3,4,5] - 4
-- [1,3,5] - 5
-- [1,3] - 1
-- [3] - 3
-- the result: [2,4,5,1,3]
loopGenIndices :: [Integer] -> Free L.NodeF [Integer]
loopGenIndices numbers = do
  if (not $ null numbers)
    then do
      let maxIndex = fromIntegral $ length numbers - 1
      p <- fromIntegral <$> L.getRandomInt (0, maxIndex)
      let result = numbers !! p
      -- choose next number from rest
      rest <- loopGenIndices $ delete result numbers
      return (result:rest)
    else return []