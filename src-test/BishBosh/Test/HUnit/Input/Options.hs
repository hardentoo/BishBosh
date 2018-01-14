{-
	Copyright (C) 2018 Dr. Alistair Ward

	This file is part of BishBosh.

	BishBosh is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	BishBosh is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with BishBosh.  If not, see <http://www.gnu.org/licenses/>.
-}
{- |
 [@AUTHOR@]	Dr. Alistair Ward

 [@DESCRIPTION@]	Static tests.
-}

module BishBosh.Test.HUnit.Input.Options(
-- * Constants
	testCases
) where

import			BishBosh.Data.Float()	-- HXT.XmlPickler.
import			Control.Category((>>>))
import qualified	BishBosh.Data.Exception	as Data.Exception
import qualified	BishBosh.Input.Options	as Input.Options
import qualified	BishBosh.Types		as T
import qualified	Control.Exception
import qualified	Data.List
import qualified	Data.Maybe
import qualified	Paths_bishbosh		as Paths	-- Either local stub, or package-instance auto-generated by 'Setup build'.
import qualified	System.Environment
import qualified	System.FilePath
import qualified	Test.HUnit
import qualified	Text.XML.HXT.Core	as HXT
import qualified	ToolShed.System.File
import			System.FilePath((</>), (<.>))
import			Test.HUnit((@?))

-- | Check the sanity of the implementation, by validating a list of static test-cases.
testCases :: Test.HUnit.Test
testCases	= Test.HUnit.test [
	Test.HUnit.TestCase $ let
		inputSysConfig :: HXT.SysConfigList
		inputSysConfig	= [
			HXT.withRemoveWS	HXT.yes,	-- Remove white-space, e.g. any indentation which might have been introduced by 'HXT.withIndent'.
			HXT.withStrictInput	HXT.yes,	-- Read the input file strictly (cf. lazily), this ensures closing the files correctly even if not read completely.
			HXT.withValidate	HXT.yes		-- Validate against any DTD referenced from the XML-file.
		 ]

		maximumTraceLevel :: Int
		maximumTraceLevel	= 0

		fileName :: System.FilePath.FilePath
		fileName	= "bishbosh_both" <.> "xml"
	in do
		dataDir		<- fmap System.FilePath.normalise Paths.getDataDir
		executablePath	<- fmap System.FilePath.normalise System.Environment.getExecutablePath

		let
			searchPath	= Data.List.nub . map (</> "config" </> "Raw") $ [
				".",
				dataDir	-- The installation-directory.
			 ] ++ Data.List.unfoldr (
				\filePath -> let
					directory	= System.FilePath.takeDirectory filePath
				in if directory `elem` map return {-to List-monad-} ['.', System.FilePath.pathSeparator]
					then Nothing
					else Just (directory, directory)
			 ) executablePath
		 in ToolShed.System.File.locate fileName searchPath >>= Data.Maybe.maybe (
			Control.Exception.throw . Data.Exception.mkSearchFailure . showString "BishBosh.Test.HUnit.Input.Options.testCases:\tfailed to locate " . shows fileName . showString " in " $ shows searchPath "."
		 ) (
			\path -> do
				optionsList	<- HXT.runX {-which returns a list-} $ HXT.setTraceLevel maximumTraceLevel >>> HXT.xunpickleDocument HXT.xpickle inputSysConfig path

				Data.Maybe.maybe False (== head optionsList) (
					(HXT.unpickleDoc HXT.xpickle . HXT.pickleDoc HXT.xpickle) =<< Data.Maybe.listToMaybe (
						optionsList :: [
							Input.Options.Options T.Y {-column-} T.CriterionWeight T.PieceSquareValue T.RankValue T.X {-row-} T.X T.Y
						]
					)
				 ) @? "Input.Options.pickler failed."
		 ) . Data.Maybe.listToMaybe
 ]

