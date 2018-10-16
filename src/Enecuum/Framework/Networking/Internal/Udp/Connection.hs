{-# LANGUAGE LambdaCase#-}
module Enecuum.Framework.Networking.Internal.Udp.Connection
    ( close
    , send
    , startServer
    , stopServer
    , openConnect
    , sendUdpMsg
    ) where

import           Enecuum.Prelude
import           Enecuum.Framework.Networking.Internal.Connection
import           Data.Aeson
import           Control.Concurrent.Chan
import           Control.Concurrent.STM.TChan
import           Control.Concurrent.STM.TMVar

import           Enecuum.Legacy.Service.Network.Base
import           Data.Aeson.Lens
import           Control.Concurrent.Async
import qualified Enecuum.Framework.Domain.Networking as D
import           Enecuum.Framework.Networking.Internal.Client
import           Enecuum.Framework.Networking.Internal.Udp.Server 
import qualified Network.Socket as S hiding (recv, send, sendAll)
import qualified Network.Socket.ByteString.Lazy as S
import           Control.Monad.Extra

instance NetworkConnection D.Udp where
    startServer port handlers insertConnect loger = do
        chan <- atomically newTChan
        void $ forkIO $ runUDPServer chan port $ \msg msgChan sockAddr -> do
            let host       = D.sockAddrToHost sockAddr
                connection = D.Connection $ D.Address host port
    
            insertConnect connection (D.ServerUdpConnectionVar sockAddr msgChan)
            runHandlers   connection handlers loger msg
        pure chan

    send (D.ClientUdpConnectionVar conn) msg = sendWithTimeOut conn msg
    send (D.ServerUdpConnectionVar sockAddr chan) msg = do
        var <- atomically $ do
            var <- newEmptyTMVar
            writeTChan chan $ D.SendUdpMsgTo sockAddr msg var
            pure var
        readBool 5000 var

    close (D.ClientUdpConnectionVar conn) = writeComand conn D.Close >> closeConn conn
    close (D.ServerUdpConnectionVar _ _)  = pure ()

    openConnect addr handlers loger = do
        conn <- atomically (newTMVar =<< newTChan)
        void $ forkIO $ do
            tryML
                (runClient UDP addr $ \sock -> void $ race
                    (readMessages (D.Connection addr) handlers loger sock)
                    (connectManager conn sock))
                (atomically $ closeConn conn)
        pure $ D.ClientUdpConnectionVar conn


runHandlers :: D.Connection D.Udp -> Handlers D.Udp -> (Text -> IO ()) -> LByteString -> IO ()
runHandlers netConn handlers loger msg = case decode msg of
    Just (D.NetworkMsg tag val) -> whenJust (handlers ^. at tag) $
        \handler -> handler val netConn
    Nothing                     -> loger $ "Error in decoding en msg: " <> show msg

writeComand :: TMVar (TChan D.Comand) -> D.Comand -> STM ()
writeComand conn cmd = unlessM (isEmptyTMVar conn) $ do
    chan <- readTMVar conn
    writeTChan chan cmd

-- close connection
closeConn :: TMVar (TChan D.Comand) -> STM ()
closeConn conn = unlessM (isEmptyTMVar conn) $ void $ takeTMVar conn

-- | Read comand to connect manager
readCommand :: TMVar (TChan D.Comand) -> IO (Maybe D.Comand)
readCommand conn = atomically $ do
    ok <- isEmptyTMVar conn
    if ok
        then pure Nothing
        else do
            chan <- readTMVar conn
            Just <$> readTChan chan

sendUdpMsg :: D.Address -> LByteString -> IO Bool
sendUdpMsg addr msg = if length msg > D.packetSize
    then pure False 
    else do
        runClient UDP addr $ \sock -> S.sendAll sock msg
        pure True

readMessages :: D.Connection D.Udp -> Handlers D.Udp -> (Text -> IO ()) -> S.Socket -> IO ()
readMessages conn handlers loger sock = tryMR (S.recv sock $ toEnum D.packetSize) $ \msg -> do 
    runHandlers conn handlers loger msg
    readMessages conn handlers loger sock

-- | Manager for controlling of WS connect.
connectManager :: TMVar (TChan D.Comand) -> S.Socket -> IO ()
connectManager conn sock = readCommand conn >>= \case
    -- close connection
    Just D.Close      -> atomically $ unlessM (isEmptyTMVar conn) $ void $ takeTMVar conn
    -- send msg to alies node
    Just (D.Send val var) -> do
        tryM (S.sendAll sock val) (atomically $ closeConn conn) $
            \_ -> do
                atomically $ putTMVar var True
                connectManager conn sock
    -- conect is closed, stop of command reading
    Nothing           -> pure ()
