module Enecuum.Core.Random.Interpreter where

import qualified Enecuum.Core.Language            as L
import           Enecuum.Prelude
import           System.Entropy
import           System.Random                    hiding (next)
import qualified Enecuum.Core.Crypto.Interpreter as I
import           Data.UUID.V1 (nextUUID)

-- | Interpret RandomL language.
interpretERandomL :: L.ERandomF a -> IO a
interpretERandomL (L.EvalCoreCrypto a next) = do
    r <- I.runCryptoL a
    pure $ next r
interpretERandomL (L.GetRandomInt k next) = do
    r <- randomRIO k
    pure $ next r
interpretERandomL (L.GetRandomByteString k next) = do
    r<- getEntropy k
    pure $ next r
interpretERandomL (L.NextUUID next) = do
    r <- fromJust <$> nextUUID 
    pure $ next r

runERandomL :: L.ERandomL a -> IO a
runERandomL = foldFree interpretERandomL






