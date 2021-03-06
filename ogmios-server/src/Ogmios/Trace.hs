--  This Source Code Form is subject to the terms of the Mozilla Public
--  License, v. 2.0. If a copy of the MPL was not distributed with this
--  file, You can obtain one at http://mozilla.org/MPL/2.0/.
{-# OPTIONS_GHC -fno-warn-partial-fields #-}

module Ogmios.Trace
    ( TraceOgmios (..)
    ) where

import Prelude

import Cardano.BM.Data.Severity
    ( Severity (..) )
import Cardano.BM.Data.Tracer
    ( HasPrivacyAnnotation (..), HasSeverityAnnotation (..) )
import Cardano.Chain.Slotting
    ( EpochSlots (..) )
import Cardano.Network.Protocol.NodeToClient
    ( ApplyErr, Block )
import Cardano.Network.Protocol.NodeToClient.Trace
    ( TraceClient )
import Control.Exception
    ( IOException, SomeException )
import Data.ByteString
    ( ByteString )
import Ogmios.Health
    ( Health )
import Ogmios.Health.Trace
    ( TraceHealth )
import Ogmios.Metrics.Trace
    ( TraceMetrics )
import Ouroboros.Consensus.Byron.Ledger
    ( GenTx )
import Ouroboros.Network.Magic
    ( NetworkMagic )

data TraceOgmios where
    OgmiosClient
        :: TraceClient (GenTx Block) ApplyErr
        -> TraceOgmios

    OgmiosHealth
        :: { health :: TraceHealth (Health Block) }
        -> TraceOgmios

    OgmiosMetrics
        :: { metrics :: TraceMetrics }
        -> TraceOgmios

    OgmiosStarted
        :: { host :: String, port :: Int }
        -> TraceOgmios

    OgmiosNetwork
        :: { networkMagic :: NetworkMagic, slotsPerEpoch :: EpochSlots }
        -> TraceOgmios

    OgmiosConnectionAccepted
        :: { userAgent :: ByteString }
        -> TraceOgmios

    OgmiosConnectionEnded
        :: { userAgent :: ByteString }
        -> TraceOgmios

    OgmiosSocketNotFound
        :: { path :: FilePath }
        -> TraceOgmios

    OgmiosFailedToConnect
        :: { ioException :: IOException }
        -> TraceOgmios

    OgmiosUnknownException
        :: { exception :: SomeException }
        -> TraceOgmios

deriving instance Show TraceOgmios

instance HasPrivacyAnnotation TraceOgmios
instance HasSeverityAnnotation TraceOgmios where
    getSeverityAnnotation = \case
        OgmiosClient  msg -> getSeverityAnnotation msg
        OgmiosHealth  msg -> getSeverityAnnotation msg
        OgmiosMetrics msg -> getSeverityAnnotation msg

        OgmiosStarted{}              -> Info
        OgmiosNetwork{}              -> Info
        OgmiosConnectionAccepted{}   -> Info
        OgmiosConnectionEnded{}      -> Info
        OgmiosSocketNotFound{}       -> Warning
        OgmiosFailedToConnect{}      -> Error
        OgmiosUnknownException{}     -> Error
