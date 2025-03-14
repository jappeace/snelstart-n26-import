{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE RecordWildCards #-}

-- | Go from various formats to snelstart (ing)
module SnelstartImport.Convert
  ( toING
  )
where

import SnelstartImport.ING
import SnelstartImport.N26
import Data.Text(Text)


toING :: Text -> N26 -> ING
toING ownAccoun N26{..} = ING {
  datum = unDate date,
  naamBescrhijving = payee,
  rekening = ownAccoun,
  tegenRekening  = accountNumber,
  mutatieSoort = toType transactionType , -- eg ook voor code
  bijAf = if amountEur < 0 then Af else Bij,
  bedragEur = abs amountEur ,
  mededeling = paymentReference
  }

toType :: TransactionType -> MutatieSoort
toType = \case
  MastercardPayment -> Diversen
  OutgoingTransfer -> Overschijving
  Income -> Overschijving
  N26Referal -> Diversen
  DirectDebit -> Overschijving
