{-# LANGUAGE NoImplicitPrelude      #-}
{-# LANGUAGE GADTs                  #-}
{-# LANGUAGE FlexibleContexts       #-}
{-# LANGUAGE RankNTypes             #-}
{-# LANGUAGE TypeOperators          #-}
{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE TypeFamilies           #-}
{-# LANGUAGE TypeFamilyDependencies #-}
{-# LANGUAGE MultiParamTypeClasses  #-}
{-# LANGUAGE FunctionalDependencies #-}

module Enecuum.Core.HGraph.Language (
    -- * Data
      HGraphL(..)
    , W(..)
    , HNodeContent
    , HGraphModel
    , HNodeRef
    , HNode(..)
    -- * Clases
    , ToContent(..)
    , ToNodeRef(..)
    -- * Functions
    , newNode'
    , newNode
    , newLink'
    , newLink
    , deleteLink'
    , deleteLink
    , deleteNode'
    , deleteNode
    , getNode
    ) where

import           Universum
import           Eff
import           Eff.Exc
import           Eff.SafeIO

import           Enecuum.Core.HGraph.StringHashable

data HGraphL node a where
    NewNode     :: HNodeContent node -> HGraphL node (W node Bool)
    DeleteNode  :: HNodeRef node -> HGraphL node (W node Bool)
    NewLink     :: HNodeRef node -> HNodeRef node -> HGraphL node (W node Bool)
    DeleteLink  :: HNodeRef node -> HNodeRef node -> HGraphL node (W node Bool)
    GetNode     :: HNodeRef node -> HGraphL node (Maybe node)

newtype W a b = W b

data family HNodeContent a

data family HNodeRef a

type HGraphModel node = '[HGraphL node, SIO, Exc SomeException]

data HNode ref content = HNode
    { _nodeHash    :: StringHash
    , _nodeRef     :: HNodeRef (HNode ref content)
    , _nodeContent :: HNodeContent (HNode ref content)
    , _nodeLinks   :: Map StringHash (HNodeRef (HNode ref content))
    , _noderLinks  :: Map StringHash (HNodeRef (HNode ref content))
    }

class StringHashable (HNodeContent config) => ToContent config b | config -> b where
    toContent   :: b -> HNodeContent config
    fromContent :: HNodeContent config -> b

class ToNodeRef config b where
    toNodeRef   :: b -> HNodeRef config

newLink', deleteLink'
    :: (ToNodeRef node b, ToNodeRef node c)
    => c -> b -> Eff (HGraphModel node) (W node Bool)
newLink' a b     = send $ NewLink (toNodeRef a) (toNodeRef b)
deleteLink' a b  = send $ DeleteLink (toNodeRef a) (toNodeRef b)

newLink, deleteLink
    :: (ToNodeRef node c, ToNodeRef node b)
    => c -> b -> Eff (HGraphModel node) ()
newLink a b = void $ newLink' a b
deleteLink a b = void $ deleteLink' a b

newNode' :: ToContent node c => c -> Eff (HGraphModel node) (W node Bool)
newNode' = send . NewNode . toContent

newNode :: ToContent node c => c -> Eff (HGraphModel node) ()
newNode = void . newNode'

deleteNode' :: ToNodeRef node h => h -> Eff (HGraphModel node) (W node Bool)
deleteNode' = send . DeleteNode . toNodeRef

deleteNode :: ToNodeRef node h => h -> Eff (HGraphModel node) ()
deleteNode = void . deleteNode'

getNode :: ToNodeRef node h => h -> Eff (HGraphModel node) (Maybe node)
getNode = send . GetNode . toNodeRef
