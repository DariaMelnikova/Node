{-# LANGUAGE DuplicateRecordFields  #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE TemplateHaskell        #-}

module Enecuum.Framework.Lens where

import           Control.Lens             ( makeFieldsNoPrefix )

import           Enecuum.Framework.Domain

makeFieldsNoPrefix ''NetworkRequest
makeFieldsNoPrefix ''NetworkResponse
makeFieldsNoPrefix ''NodeConfig