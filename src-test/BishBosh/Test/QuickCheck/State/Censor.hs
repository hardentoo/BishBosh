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

 [@DESCRIPTION@]	Defines /QuickCheck/-properties.
-}

module BishBosh.Test.QuickCheck.State.Censor(
-- * Constants
	results
) where

import			Control.Arrow((&&&))
import qualified	BishBosh.Model.Game			as Model.Game
import qualified	BishBosh.State.Board			as State.Board
import qualified	BishBosh.State.Censor			as State.Censor
import qualified	BishBosh.Test.QuickCheck.Model.Game	as Test.QuickCheck.Model.Game
import qualified	Test.QuickCheck
-- import		Test.QuickCheck((==>))

-- | The constant test-results.
results :: IO [Test.QuickCheck.Result]
results	= sequence [
	let
		f :: Test.QuickCheck.Model.Game.Game -> Test.QuickCheck.Property
		f = Test.QuickCheck.label "Censor.prop_countPiecesByLogicalColour" . uncurry (==) . (
			State.Censor.countPiecesByLogicalColour . State.Board.getMaybePieceByCoordinates &&& State.Censor.countPiecesByLogicalColour . State.Board.getCoordinatesByRankByLogicalColour
		 ) . Model.Game.getBoard
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 256 } f,
	let
		f :: Test.QuickCheck.Model.Game.Game -> Test.QuickCheck.Property
		f = Test.QuickCheck.label "Censor.prop_countPieces" . uncurry (==) . (
			State.Censor.countPieces . State.Board.getMaybePieceByCoordinates &&& State.Censor.countPieces . State.Board.getCoordinatesByRankByLogicalColour
		 ) . Model.Game.getBoard
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 256 } f,
	let
		f :: Test.QuickCheck.Model.Game.Game -> Test.QuickCheck.Property
		f = Test.QuickCheck.label "Censor.prop_countPieces/bounds" . uncurry (&&) . (
			(> 2) &&& (<= 32)
		 ) . State.Censor.countPieces . State.Board.getCoordinatesByRankByLogicalColour . Model.Game.getBoard
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 256 } f,
	let
		f :: Test.QuickCheck.Model.Game.Game -> Test.QuickCheck.Property
		f = Test.QuickCheck.label "Censor.prop_countPieceDifferenceByRank" . uncurry (==) . (
			State.Censor.countPieceDifferenceByRank . State.Board.getMaybePieceByCoordinates &&& State.Censor.countPieceDifferenceByRank . State.Board.getCoordinatesByRankByLogicalColour
		 ) . Model.Game.getBoard
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 256 } f,
{-
	let
		f :: Test.QuickCheck.Model.Game.Game -> Test.QuickCheck.Property
		f game = Model.Game.isTerminated game ==> Test.QuickCheck.label "Censor.prop_hasInsufficientMaterial" . uncurry (==) . (
			State.Censor.hasInsufficientMaterial . State.Board.getMaybePieceByCoordinates &&& State.Censor.hasInsufficientMaterial . State.Board.getCoordinatesByRankByLogicalColour
		 ) $ Model.Game.getBoard game
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs {
		Test.QuickCheck.maxDiscardRatio	= 2048,
		Test.QuickCheck.maxSuccess	= 8
	} f,
-}
	let
		f :: Test.QuickCheck.Model.Game.Game -> Test.QuickCheck.Property
		f = Test.QuickCheck.label "Censor.prop_hasBothKings" . uncurry (==) . (
			State.Censor.hasBothKings . State.Board.getMaybePieceByCoordinates &&& State.Censor.hasBothKings . State.Board.getCoordinatesByRankByLogicalColour
		 ) . Model.Game.getBoard
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 256 } f,
	let
		f :: Test.QuickCheck.Model.Game.Game -> Test.QuickCheck.Property
		f = Test.QuickCheck.label "Censor.prop_(getNPieces == countPieces)" . uncurry (==) . (
			State.Board.getNPieces &&& State.Censor.countPieces . State.Board.getCoordinatesByRankByLogicalColour
		 ) . Model.Game.getBoard
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 256 } f,
	let
		f :: Test.QuickCheck.Model.Game.Game -> Test.QuickCheck.Property
		f	= Test.QuickCheck.label "Censor.prop_(getNPiecesDifferenceByRank == countPieceDifferenceByRank)" . uncurry (==) . (
			State.Board.getNPiecesDifferenceByRank &&& State.Censor.countPieceDifferenceByRank . State.Board.getCoordinatesByRankByLogicalColour
		 ) . Model.Game.getBoard
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 256 } f
 ]

