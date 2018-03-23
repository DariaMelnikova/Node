{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE ViewPatterns #-}
module Sharding.Sharding where

import              Sharding.Space.Distance
import              Sharding.Space.Points
import              Sharding.Space.Shift
import              Sharding.Types

import              Node.Node.Types
import              Control.Concurrent.Chan
import              Data.List.Extra
import              Control.Concurrent
import              Control.Monad
import qualified    Data.ByteString     as B
import              Data.Word
import              Node.Data.Data
import              Service.Timer
import qualified    Data.Set            as S


-- TODO Is it file or db like sqlite?
-- TODO What am I do if my neighbors is a liars?
loadMyBlockIndex :: IO (S.Set BlockHash)
loadMyBlockIndex = undefined

-- TODO Is it file or db like sqlite?
loadInitInformation :: IO (S.Set Neighbor, MyNodePosition)
loadInitInformation = undefined


sendToNetLevet :: Chan ManagerMiningMsgBase -> ShardingNodeRequestAndResponce -> IO ()
sendToNetLevet aChan aMsg = writeChan aChan $ ShardingNodeRequestOrResponce aMsg

initOfShardingNode aChanOfNetLevel aChanRequest aMyNodeId aMyNodePosition = do
    sendToNetLevet aChanOfNetLevel $ IamAwakeRequst aMyNodeId aMyNodePosition

    aMyBlocksIndex <- loadMyBlockIndex
    (aMyNeighbors, aMyPosition) <- loadInitInformation

    metronome (10^8) $ do
        writeChan aChanRequest CleanBlocksAction
        writeChan aChanRequest ShiftAction

    return $ makeEmptyShardingNode aMyNeighbors aMyNodeId aMyPosition aMyBlocksIndex


neighborPositions :: ShardingNode -> S.Set NodePosition
neighborPositions = S.map neighborPosition . nodeNeighbors

shiftIsNeed :: ShardingNode -> Bool
shiftIsNeed aShardingNode = checkUnevenness
    (nodePosition aShardingNode) (neighborPositions aShardingNode)


shiftTheShardingNode ::
        Chan ManagerMiningMsgBase
    -> (ShardingNode ->  IO ())
    ->  ShardingNode
    ->  IO ()
shiftTheShardingNode aChanOfNetLevel aLoop aShardingNode = do
    let aNeighborPositions = neighborPositions aShardingNode
        aMyNodePosition    = nodePosition aShardingNode
        aNearestPositions  = S.fromList $
            findNearestNeighborPositions aMyNodePosition aNeighborPositions
        aNewPosition       = shiftToCenterOfMass aMyNodePosition aNearestPositions

    aLoop aShardingNode {nodePosition = aNewPosition}


--makeShardingNode :: MyNodeId -> Point -> IO ()
makeShardingNode aMyNodeId  aChanRequest aChanOfNetLevel aMyNodePosition= do
    aShardingNode <- initOfShardingNode aChanOfNetLevel aChanRequest aMyNodeId aMyNodePosition
    void $ forkIO $ aLoop aShardingNode
  where
    aLoop :: ShardingNode -> IO ()
    aLoop aShardingNode = readChan aChanRequest >>= \case
        ShiftAction | shiftIsNeed aShardingNode ->
            shiftTheShardingNode aChanOfNetLevel aLoop aShardingNode


             --NewPosiotionResponse
        _ -> undefined
{-
InitAction
|   NewNodeInNetAction          NodeId Point
-- TODO create index for new node by NodeId
|   BlockIndexCreateAction      NodeId
|   BlockIndexAcceptAction      [BlockHash]
|   BlocksAcceptAction          [(BlockHash, Block)]
---
|   CleanBlocksAction -- clean local blocks
--- ShiftAction => NewPosiotionResponse
|   NewBlockInNetAction         BlockHash Block
|   ShiftAction
|   TheNodeHaveNewCoordinates   NodeId NodePosition
---- NeighborListRequest => NeighborListAcceptAction
|   NeighborListAcceptAction   [(NodeId, NodePosition)]
|   TheNodeIsDead               NodeId

-}
--------------------------------------------------------------------------------

--------------------------TODO-TO-REMOVE-------------------------------------------
findNodeDomain :: MyNodePosition -> S.Set NodePosition -> Distance Point
findNodeDomain aMyPosition aPositions = if
    | length aNearestPoints < 4 -> maxBound
    | otherwise                 ->
        last . sort $ distanceTo aMyPosition <$> aNearestPoints
  where
    aNearestPoints = findNearestNeighborPositions aMyPosition aPositions
