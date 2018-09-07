{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE AllowAmbiguousTypes #-}

module Enecuum.Framework.NodeSpec where

import Enecuum.Prelude

import           Test.Hspec

import qualified Enecuum.Domain                as D
import qualified Enecuum.Language              as L

import Enecuum.Framework.TestData.Nodes
import Enecuum.Framework.Testing.Runtime
import Enecuum.Framework.Testing.Types
import qualified Enecuum.Core.Testing.Runtime.Lens as RLens
import qualified Enecuum.Framework.Testing.Lens as RLens

spec :: Spec
spec = describe "Master Node test" $
  it "Master Node test" $ do

    runtime <- createTestRuntime

    bootNodeRuntime   :: NodeRuntime <- startNode runtime bootNodeAddr    bootNode
    masterNodeRuntime :: NodeRuntime <- startNode runtime masterNode1Addr masterNode

    eResponse <- sendRequest runtime bootNodeAddr $ HelloRequest1 masterNode1Addr
    eResponse `shouldBe` (Right $ HelloResponse1 "Hello, dear. master node 1 addr")

    let tMsgs = runtime ^. RLens.loggerRuntime . RLens.messages
    msgs <- readTVarIO tMsgs
    msgs `shouldBe`
      [ "CloseConnection conn"
      , "SendRequest conn req"
      , "OpenConnection cfg"
      , "Serving handlersF"
      , "CloseConnection conn"
      , "SendRequest conn req"
      , "OpenConnection cfg"
      , "L.WaitForSingleResponse cfg timeout"
      , "L.Multicast cfg req"
      , "Synchronize"
      , "Eval Network"
      , "Initialization"
      , "Node tag: masterNode"
      , "Serving handlersF"
      , "Initialization"
      , "Node tag: bootNode"
      ]
