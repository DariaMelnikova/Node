{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}

module Enecuum.Dsl.Graph.Interpreter where

import           Universum
import           GHC.Exts
import           Control.Monad.Freer
import           Control.Monad.Freer.Internal

import           Enecuum.Dsl.Graph.Language
import           Enecuum.TGraph as G
import           Enecuum.StringHashable

runGraph :: StringHashable c => TVar (TGraph c) -> Eff '[GraphDsl c] w -> IO w
runGraph _ (Val x) = return x
runGraph aGraph (E u q) = case extract u of
    NewNode     x   -> do
        void . atomically $ G.newNode aGraph x
        runGraph aGraph (qApp q ())

    DeleteNode  x   -> do
        void . atomically $ G.deleteNode aGraph x
        runGraph aGraph (qApp q ())

    NewLinck    x y -> do
        void . atomically $ G.newLinck aGraph x y
        runGraph aGraph (qApp q ())

    DeleteLinck x y -> do
        void . atomically $ G.deleteLinck aGraph x y
        runGraph aGraph (qApp q ())

    FindNode    x   -> do
        aRes <- atomically $ do
            aMaybeNode <- G.findNode aGraph x
            case aMaybeNode of
                Just aTNode -> do
                    aNode <- readTVar aTNode
                    return $ Just (aNode^.content, fromList $ keys $ aNode^.links) 
                Nothing -> return Nothing
                
        runGraph aGraph (qApp q aRes)