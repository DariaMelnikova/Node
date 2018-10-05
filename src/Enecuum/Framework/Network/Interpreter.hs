module Enecuum.Framework.Network.Interpreter where


-- | Interpret NetworkSendingL. Does nothing ATM.
{-
interpretNetworkSendingL
    :: L.NetworkSendingL a
    -> Eff '[L.LoggerL, SIO, Exc SomeException] a

interpretNetworkSendingL (L.Multicast cfg req) = L.logInfo "L.Multicast cfg req"

-- | Interpret NetworkListeningL (with NetworkSendingL in stack). Does nothing ATM.
interpretNetworkListeningL
    :: L.NetworkListeningL a
    -> Eff '[L.NetworkSendingL, L.LoggerL, SIO, Exc SomeException] a
interpretNetworkListeningL (L.WaitForSingleResponse cfg timeout) = do
    L.logInfo "L.WaitForSingleResponse cfg timeout"
    pure Nothing

-- | Interpret NetworkListeningL. Does nothing ATM.
interpretNetworkListeningL'
    :: L.NetworkListeningL a
    -> Eff '[L.LoggerL, SIO, Exc SomeException] a
interpretNetworkListeningL' (L.WaitForSingleResponse cfg timeout) = do
    L.logInfo "L.WaitForSingleResponse cfg timeout"
    pure Nothing

-- | Interpret NetworkSyncL. Runs underlying NetworkListeningL and NetworkSendingL interpreters.
interpretNetworkSyncL
    :: L.NetworkSyncL a
    -> Eff '[L.NetworkListeningL, L.NetworkSendingL, L.LoggerL, SIO, Exc SomeException] a
interpretNetworkSyncL (L.Synchronize sending listening) = do
    L.logInfo "Synchronize"
    raise $ raise $ handleRelay pure ( (>>=) . interpretNetworkSendingL  )    sending
    raise $ raise $ handleRelay pure ( (>>=) . interpretNetworkListeningL' ) listening
    -}