module Enecuum.Framework.Networking.Internal.TCP.Server (runServer, ServerComand (..)) where

import           Control.Concurrent (forkFinally)
import           Control.Concurrent.Async (race)
import           Control.Monad
import           Enecuum.Prelude
import           Network            (PortID (..), listenOn)
import           Network.Socket
import           Control.Concurrent.STM.TChan

data ServerComand = StopServer

-- | Run TCP server.
runServer :: TChan ServerComand -> PortNumber -> (Socket -> IO()) -> IO ()
runServer chan aPortNumber aPlainHandler = do
    sock <- listenOn $ PortNumber aPortNumber
    let acceptConnect = forever $ do
            (conn, _) <- accept sock
            void $ forkFinally (aPlainHandler conn) (\_ -> close conn)
    void $ race (void $ atomically $ readTChan chan) acceptConnect