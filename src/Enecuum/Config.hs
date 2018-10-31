{-# LANGUAGE UndecidableInstances  #-}
{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Enecuum.Config where

import           Enecuum.Prelude

import qualified Data.ByteString.Lazy          as L
import qualified Data.Aeson                    as A


import           Enecuum.Core.Types.Logger     (LoggerConfig(..))
import           System.FilePath.Windows       (dropFileName)
import           System.Directory (createDirectoryIfMissing)
import           Enecuum.Framework.Domain.Networking
import           Enecuum.Language (NodeDefinitionL)

data Config node = Config
    { bootNodeAddress :: Text
    , node            :: node
    , scenario        :: NodeScenario node
    , nodeConfig      :: NodeConfig node
    , extPort         :: Int
    , loggerConfig    :: LoggerConfig
    , clientConfig    :: Maybe ClientConfig
    }
    deriving (Generic)

instance (FromJSON node, FromJSON (NodeScenario node), FromJSON (NodeConfig node)) => FromJSON (Config node)

class Node node where
    type NodeConfig   node :: *
    data NodeScenario node :: *
    parseConfig :: LByteString -> Maybe (Config (NodeConfig node))
    getScenario :: NodeConfig node -> NodeScenario node
    getNode     :: NodeScenario node -> NodeConfig node -> NodeDefinitionL ()

type FullConfig node = Config (NodeConfig node)

-- data NodeRole = PoW | PoA | Client | GraphNode
--   deriving (Generic, FromJSON, Show, Read, Eq, Ord )

-- data Scenario = LedgerBalance | SyncChain | SyncKblock | Full
--   deriving (Generic, FromJSON, Show, Read, Eq, Ord)
    
-- data ScenarioRole = Receiver | Transmitter | Soly | Good | Bad
--   deriving (Generic, FromJSON, Show, Read, Eq, Ord)

-- data ScenarioNode = ScenarioNode
--   { nodeRole     :: NodeRole
--   , scenario     :: Scenario
--   , scenarioRole :: ScenarioRole
--   } deriving (Generic, FromJSON, Show, Read, Eq, Ord)

data ClientConfig = ClientConfig 
  {  host :: String
  ,  port :: Int
  } deriving (Generic, FromJSON, Show, Read, Eq, Ord)

-- data Config = Config
--   { bootNodeAddress :: Text
--   , scenarioNode :: [ScenarioNode]
--   , extPort :: Int
--   , loggerConfig :: LoggerConfig
--   , clientConfig :: Maybe ClientConfig
--   }
--   deriving (Generic, FromJSON)

withConfig :: FilePath -> (LByteString -> IO ()) -> IO ()
withConfig configName act = act =<< L.readFile configName

-- withConfig :: FilePath -> (Config -> IO ()) -> IO ()
-- withConfig configName act = act =<< getConfigBase configName

-- getConfigBase :: FilePath -> IO Config
-- getConfigBase configName = do
--     configContents <- L.readFile configName
--     case A.decode configContents of
--         Nothing     -> error "Please, specify config file correctly"
--         Just config -> pure config

tryParseConfig
    :: (FromJSON node, FromJSON (NodeScenario node), FromJSON (NodeConfig node))
    => LByteString
    -> Maybe (Config node)
tryParseConfig = A.decode

-- readClientConfig :: Config -> Maybe Address
-- readClientConfig (Config _ _ _ _ (Just config)) = Just $ Address (host config) (toEnum $ port config)
-- readClientConfig _ = Nothing


-- logConfig :: FilePath -> IO LoggerConfig
-- logConfig configName = do
--     config <- getConfigBase configName
--     let logConf@(LoggerConfig _ _ logFile _) = loggerConfig config
--         dir = dropFileName logFile
--     createDirectoryIfMissing True dir
--     pure logConf
