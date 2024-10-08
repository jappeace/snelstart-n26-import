{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE QuasiQuotes #-}

module SnelstartN26Import
  ( main,
  )
where

import NeatInterpolation
import qualified Data.ByteString.Lazy as BS
import SnelstartN26Import.Snelstart
import SnelstartN26Import.N26
import Data.Text (Text)
import Data.Text.Encoding (encodeUtf8)
import Data.Vector(toList)
import Data.Csv(EncodeOptions (..), defaultEncodeOptions, Quoting (..), encodeWith)
import Data.ByteString.Lazy (ByteString)

toType :: TransactionType -> MutatieSoort
toType = \case
  MastercardPayment -> Diversen
  OutgoingTransfer -> Overschijving
  Income -> Overschijving
  N26Referal -> Diversen
  DirectDebit -> Overschijving

toSnelstart :: Text -> N26 -> Snelstart
toSnelstart ownAccoun N26{..} = Snelstart {
  datum = unDate date,
  naamBescrhijving = payee,
  rekening = ownAccoun,
  tegenRekening  = accountNumber,
  mutatieSoort = toType transactionType , -- eg ook voor code
  bijAf = if amountEur < 0 then Af else Bij,
  bedragEur = abs amountEur ,
  mededeling = paymentReference
  }

main :: IO ()
main = do
  result <- readN26 "input.csv"
  case result of
    Left x -> error x
    Right n26Vec -> BS.writeFile "out.csv" $ let
        n26 :: [Snelstart ]
        n26 = toSnelstart "DE92100110012623092722" <$> toList n26Vec
        data' :: ByteString
        data' = encodeWith opts n26
        header = encodeUtf8 $ [text|"Datum","Naam / Omschrijving","Rekening","Tegenrekening","Code","Af Bij","Bedrag (EUR)","Mutatiesoort","Mededelingen"|] <> "\n"
      in
        BS.fromStrict header <> data'

opts :: EncodeOptions
opts = defaultEncodeOptions { encQuoting = QuoteAll}
