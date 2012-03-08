module Main where

import Graphics.UI.WX
import Graphics.UI.WXCore
import System.Process
import GHC.IO.Handle
import Control.Monad.Loops
import Text.Regex.Base
import Text.Regex.TDFA
import Data.String.Utils

substring a z = take a . drop z

readPkg ::  Handle ->  Bool -> IO [[String]]
readPkg handle True = do
	firstLine <- hGetLine handle
	name : version : _ <- return $ split " " firstLine
	description <- hGetLine handle
	condition <- hIsEOF handle
	result <- readPkg handle (not condition)
	return $ [name, version, description] : result
		
readPkg _ False = return []

findPkg :: String -> IO [[String]]
findPkg name = do
	(_, Just output, _, _) <- createProcess $ (proc "yaourt" ["-Ss", "--nocolor", name]){ std_out = CreatePipe }
	condition <- hIsEOF output
	readPkg output (not condition)

search :: String -> ListCtrl () -> IO ()
search query output = do
	itemsDelete output
	results <- findPkg query
	mapM (\x -> itemAppend output x) results
	return ()

searchChanged entry output oldEvent event = do
	oldEvent event
	query <- get entry text
	search query output
	



attachSearchEntryEvents :: Window () ->  Window () -> IO ()
attachSearchEntryEvents searchEntryWindow resultsWindow = do
	oldEvent <- get searchEntry (on keyboard)
	set searchEntry [ on keyboard := searchChanged searchEntry results oldEvent  ]
	where
		searchEntry = objectCast searchEntryWindow :: TextCtrl ()
		results = objectCast resultsWindow :: ListCtrl ()

startApp = do
	frame <- frameLoadRes "wxyaourt.xrc" "MainWindow" []
	results <- windowFindWindow frame "Results"
	set (objectCast results) [ columns := [("Name", AlignLeft, -1), ("Version", AlignLeft, -1), ("Description", AlignLeft, -1)] ]
	--
	searchEntry <- windowFindWindow frame "Search"
	attachSearchEntryEvents searchEntry results
	windowShow frame

main = do
	start startApp
