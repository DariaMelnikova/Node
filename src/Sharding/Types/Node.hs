{-# LANGUAGE TemplateHaskell, MultiParamTypeClasses, GADTs #-}
--{-# OPTIONS_GHC -fno-Wtype-defaults #-}


module Sharding.Types.Node where

import              Node.Data.NodeTypes
import              Sharding.ShardDB.ShardIndex
import              Sharding.Types.ShardTypes
import              Sharding.Space.Point

import              Control.Concurrent.Chan

import              Lens.Micro.TH
import              Data.Word
import qualified    Data.Set            as S
import qualified    Data.Map            as M
import              System.Clock


data ShardingNode = ShardingNode {
        _nodeNeighbors      :: S.Set Neighbor
    ,   _shardingNodeId     :: MyNodeId
    ,   _nodePosition       :: MyNodePosition
    ,   _nodeIndex          :: ShardIndex
    ,   _nodeIndexOfReques  :: M.Map ShardHash (TimeSpec, Chan Shard)
    ,   _nodeDistance       :: Word64 -- think
  }
  deriving Eq


-- sharding

data Neighbor = Neighbor {
        _neighborPosition   :: NodePosition
    ,   _neighborId         :: NodeId
  }
  deriving (Show, Eq, Ord)


makeLenses ''ShardingNode
makeLenses ''Neighbor


data ShardingNodeAction =
    -- TODO think requestShardIndex requestNeededShards, find position
    ---    InitAction
        NewNodeInNetAction          NodeId NodePosition
    -- TODO create index for new node by NodeId
    |   ShardRequestAction          ShardHash (Chan Shard)
    |   ShardIndexAcceptAction      [ShardHash]
    |   ShardIndexCreateAction      (Chan ShardingNodeResponce) NodeId Word64
    |   ShardListCreateAction       (Chan ShardingNodeResponce) NodeId ShardHash
    |   NodePositionAction          (Chan ShardingNodeResponce) NodeId
    |   ShardAcceptAction           Shard
    ---
    |   NewShardInNetAction         Shard
    |   CleanShardsAction -- clean local Shards
    --- ShiftAction => NewPosiotionResponse
    |   ShiftAction
    |   TheNodeHaveNewCoordinates   NodeId NodePosition
    ---- NeighborListRequest => NeighborListAcceptAction
    |   TheNodeIsDead               NodeId


data ShardingNodeResponce where
    ShardIndexResponse    :: [ShardHash]    -> ShardingNodeResponce
    ShardResponse         :: Shard          -> ShardingNodeResponce
    NodePositionResponse  :: MyNodePosition -> ShardingNodeResponce
  deriving (Show)


data ShardingNodeRequestMsg =
        IamAwakeRequst        MyNodeId MyNodePosition -- broadcast for all network
    ---- TODO sending of ShardIndexRequest
    |   ShardIndexRequest     Word64 [NodeId]    -- for neighbors
    |   ShardListRequest      [ShardHash] -- TODO add functionality
    --- ShiftAction => NewPosiotionResponse
    |   NewPosiotionMsg       MyNodePosition
    ---
    |   NeighborListRequest -- ask net level new neighbors
  deriving (Show)


makeEmptyShardingNode :: S.Set Neighbor ->  MyNodeId -> MyNodePosition -> ShardIndex -> ShardingNode
makeEmptyShardingNode aNeighbors aMyNodeId aMyPosition aMyShardIndex = ShardingNode {
        _nodeNeighbors      = aNeighbors
    ,   _shardingNodeId     = aMyNodeId
    ,   _nodePosition       = aMyPosition
    ,   _nodeIndex          = aMyShardIndex
    ,   _nodeDistance       = 1
  }


makeEmptyNeighbor :: NodePosition -> NodeId -> Neighbor
makeEmptyNeighbor aPosition aNodeId = Neighbor {
        _neighborPosition   = aPosition
    ,   _neighborId         = aNodeId
  }


neighborsMemoryDistanse :: Word64
neighborsMemoryDistanse = 6
