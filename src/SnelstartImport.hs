{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE RecordWildCards #-}

module SnelstartImport
  ( main,
  )
where

import qualified Data.ByteString.Lazy as BS
import SnelstartImport.ING
import SnelstartImport.N26
import Data.Vector(toList)
import SnelstartImport.Options
import Paths_snelstart_import (version)
import           Options.Applicative
import Text.Printf
import Data.Version (showVersion)
import SnelstartImport.Web
import SnelstartImport.Convert

currentVersion :: String
currentVersion = showVersion version

readSettings :: IO (ProgramOptions)
readSettings = customExecParser (prefs showHelpOnError) $ info
  (helper <*> parseProgram)
  (fullDesc <> header (printf "Snelstart importer %s" currentVersion) <> progDesc
    "Converts various banks and programs to something snelstart understands"
  )


main :: IO ()
main = do
  putStrLn ""
  putStrLn "starting snelstart import"
  putStrLn ""

  settings <- readSettings
  case settings of
    Convert cli -> convertCli cli
    Webserver options -> webMain options

convertCli :: CliOptions -> IO ()
convertCli options = do
  result <- readN26 (cliInputFile options)
  case result of
    Left x -> error x
    Right n26Vec -> BS.writeFile (cliOutputFile options) $ let
        n26 :: [ING]
        n26 = n26ToING (cliOwnAccount options) <$> toList n26Vec
      in
        writeCsv n26
