{-# LANGUAGE DuplicateRecordFields #-}

module Enecuum.Framework.Testing.Types where

import Enecuum.Prelude

import qualified Data.Map as Map

import qualified Enecuum.Domain                as D
import           Enecuum.Core.Testing.Runtime.Types

data ControlRequest = ControlRpcRequest D.RpcRequest
data ControlResponse = ControlRpcResponse D.RpcResponse

data NodeRpcServerControl = NodeRpcServerControl
  { _request  :: TMVar ControlRequest
  , _response :: TMVar ControlResponse
  }

data NodeRpcServerHandle = NodeRpcServerHandle
  { _threadId :: ThreadId
  , _control  :: NodeRpcServerControl
  }

data NodeRuntime = NodeRuntime
  { _loggerRuntime :: LoggerRuntime
  , _address       :: D.NodeAddress
  , _tag           :: TVar D.NodeTag
  , _rpcServer     :: TMVar NodeRpcServerHandle
  }

data TestRuntime = TestRuntime
  { _loggerRuntime :: LoggerRuntime
  , _nodes         :: TMVar (Map.Map D.NodeAddress NodeRuntime)
  }
