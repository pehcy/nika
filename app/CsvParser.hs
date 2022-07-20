{-# language OverloadedStrings #-}
{-# language ScopedTypeVariables #-}

module CsvParser where

import Data.ByteString (ByteString)
import Data.Vector (Vector)

import qualified Data.ByteString.Lazy as ByteStringLazy
import qualified Data.Csv as Csv
import qualified Data.Vector as Vector
import Control.Monad (when)

data PerfData = PerfData
    { _branchName :: ByteString
    , _wallTime   :: Int
    } deriving (Eq, Show)

data ComparisonBranch = ComparisonBranch (ByteString, ByteString) deriving (Show)

data CsvError
    = TooLittleInput
    | TooLittleDifferentBranchNames
    | BranchTooLittleInput ByteString
    | MoreThanTwoBranches

instance Show CsvError where
    show TooLittleInput = "There are too little data to calculate the mean of the wall time."
    show TooLittleDifferentBranchNames = "There are less than 2 different branch names in the csv file."
    show (BranchTooLittleInput branchName) = "There are too little data to calculate the mean of the wall time for branch: " ++ show branchName
    show MoreThanTwoBranches = "There are more than 2 different branch names in the csv file."

instance Csv.FromNamedRecord PerfData where
    parseNamedRecord r = PerfData <$> r Csv..: "branchName" <*> r Csv..: "wallTime"

main1 :: IO ()
main1 = do
    csvData <- ByteStringLazy.readFile "perf.csv"
    case Csv.decodeByName csvData of
        Left err -> putStrLn err
        Right (_, v :: Vector PerfData) -> print (checkCsv v)

numOfSample :: Int
numOfSample = 2

checkCsv :: Vector PerfData -> Either CsvError (ComparisonBranch, Vector PerfData)
checkCsv xs = if Vector.length xs < numOfSample * 2 then Left TooLittleInput else checkIfThirdBranchNameExist xs
  where
    checkIfThirdBranchNameExist :: Vector PerfData -> Either CsvError (ComparisonBranch, Vector PerfData)
    checkIfThirdBranchNameExist xs = do
        let branchNames = fmap _branchName xs
        let firstBranchName = Vector.head branchNames
        case Vector.find (/= firstBranchName) branchNames of
            Nothing -> Left TooLittleDifferentBranchNames
            Just secondBranchName -> case Vector.find (\bn -> (bn /= firstBranchName) && (bn /= secondBranchName)) branchNames of
                Just x -> Left MoreThanTwoBranches
                Nothing -> do
                    let branchSamples = (checkBranchInputIsSufficient numOfSample xs) <$> [firstBranchName, secondBranchName]
                    case branchSamples of
                        [True, False] -> Left $ BranchTooLittleInput firstBranchName
                        [False, True] -> Left $ BranchTooLittleInput secondBranchName
                        [False, False] -> Left $ BranchTooLittleInput firstBranchName
                        [True, True] ->  Right (ComparisonBranch (firstBranchName, secondBranchName), xs)
                        otherwise -> undefined

    checkBranchInputIsSufficient :: Int -> Vector PerfData -> ByteString -> Bool
    checkBranchInputIsSufficient n xs branchName = Vector.length (Vector.filter (\x -> _branchName x == branchName) xs) >= n
