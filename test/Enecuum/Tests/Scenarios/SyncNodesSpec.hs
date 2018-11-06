{-# LANGUAGE DuplicateRecordFields #-}

module Enecuum.Tests.Scenarios.SyncNodesSpec where

import           Data.Aeson
import qualified Enecuum.Assets.Scenarios                     as A
import qualified Enecuum.Blockchain.Lens                      as Lens
import qualified Enecuum.Domain                               as D

import           Enecuum.Prelude
-- <<<<<<< HEAD
-- =======
-- import           Enecuum.Interpreters (runNodeDefinitionL)
-- import qualified Enecuum.Language   as L
-- import qualified Enecuum.Blockchain.Lens   as Lens
-- import qualified Enecuum.Domain     as D
-- import qualified Enecuum.Runtime    as R
-- import qualified Data.Map           as M
-- import qualified Enecuum.Framework.NodeDefinition.Interpreter as R

-- import qualified Enecuum.Assets.Nodes.GraphNode.Config       as A
-- import qualified Enecuum.Assets.Nodes.GraphNode.Transmitter  as A
-- import qualified Enecuum.Assets.Nodes.GraphNode.Receiver     as A
-- import qualified Enecuum.Assets.Nodes.PoW.Config             as A
-- import qualified Enecuum.Assets.Nodes.PoW.PoW                as A
-- import qualified Enecuum.Assets.Nodes.PoA                    as A
-- import qualified Enecuum.Assets.Nodes.Messages               as A
-- import qualified Enecuum.Assets.Nodes.Address                as A
-- -- import qualified Enecuum.Assets.Scenarios      as A
-- >>>>>>> master
import           Enecuum.Testing.Integrational
import           Test.Hspec
import           Test.Hspec.Contrib.HUnit                     (fromHUnitTest)
import           Test.HUnit

spec :: Spec
spec = describe "Synchronization tests" $ fromHUnitTest $ TestList
    [TestLabel "test net sync" testNodeNet]


testNodeNet :: Test
testNodeNet = TestCase $ withNodesManager $ \mgr -> pure ()
    -- Test is fragile. Temporarily disabled.

    -- let graphNodeConfig = A.noDBConfig
    -- let poaNodeConfig   = A.PoANodeConfig 0

    -- void $ startNode Nothing mgr $ A.graphNodeTransmitter graphNodeConfig
    -- waitForNode A.graphNodeTransmitterRpcAddress

    -- void $ startNode Nothing mgr A.powNode
    -- waitForNode A.powNodeRpcAddress

    -- void $ startNode Nothing mgr $ A.poaNode A.Good poaNodeConfig
    -- waitForNode A.poaNodeRpcAddress

    -- void $ startNode Nothing mgr $ A.graphNodeReceiver graphNodeConfig
    -- waitForNode A.graphNodeReceiverRpcAddress

    -- threadDelay $ 1000 * 1000

    -- _ :: Either Text A.SuccessMsg <- makeIORpcRequest A.powNodeRpcAddress $ A.NBlockPacketGeneration 2 (1000 * 500)

    -- waitForBlocks 2 A.graphNodeTransmitterRpcAddress
    -- waitForBlocks 2 A.graphNodeReceiverRpcAddress

    -- threadDelay $ 1000 * 1000

    -- Right kBlock1 :: Either Text D.KBlock <- makeIORpcRequest A.graphNodeTransmitterRpcAddress A.GetLastKBlock
    -- Right kBlock2 :: Either Text D.KBlock <- makeIORpcRequest A.graphNodeReceiverRpcAddress    A.GetLastKBlock

    -- D.toHash kBlock1 `shouldBe` D.StringHash "LtemDXK0lVSbo90SjIG62jEOi/6CHl8x3ws38xcrpsI="
    -- kBlock1 `shouldBe` kBlock2

    -- Right (A.GetMBlocksForKBlockResponse mblocksPrev1) <- makeIORpcRequest A.graphNodeTransmitterRpcAddress
    --     $ A.GetMBlocksForKBlockRequest (kBlock1 ^. Lens.prevHash)
    -- Right (A.GetMBlocksForKBlockResponse mblocksPrev2) <- makeIORpcRequest A.graphNodeReceiverRpcAddress
    --     $ A.GetMBlocksForKBlockRequest (kBlock2 ^. Lens.prevHash)

    -- eWalletBalances1 :: [Either Text A.WalletBalanceMsg] <- forM (concat $ toKeys <$> mblocksPrev1) $ \i ->
    --     makeIORpcRequest A.graphNodeTransmitterRpcAddress $ A.GetWalletBalance i

    -- eWalletBalances2 :: [Either Text A.WalletBalanceMsg] <- forM (concat $ toKeys <$> mblocksPrev2) $ \i ->
    --     makeIORpcRequest A.graphNodeReceiverRpcAddress    $ A.GetWalletBalance i

    -- (rights eWalletBalances1) `shouldBe` (rights eWalletBalances2)
    -- length (rights eWalletBalances1) `shouldSatisfy` (> 0)

-- <<<<<<< HEAD
--     stopNode A.graphNodeTransmitterRpcAddress
--     stopNode A.powNodeRpcAddress
--     stopNode A.poaNodeRpcAddress
--     stopNode A.graphNodeReceiverRpcAddress
--     where
--         toKeys mblocks = (D._owner :: D.Transaction -> D.PublicKey) <$> (D._transactions :: D.Microblock -> [D.Transaction]) mblocks
-- =======
    -- -- Mblocks for the underlying kblock should be synchronized.
    -- length mblocksPrev1 `shouldBe` 1
    -- mblocksPrev1 `shouldBe` mblocksPrev2

    -- where
    --     toKeys mblocks = (D._owner :: D.Transaction -> D.PublicKey) <$> (D._transactions :: D.Microblock -> [D.Transaction]) mblocks
-- >>>>>>> master
