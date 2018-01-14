{-# OPTIONS_GHC -fno-warn-orphans #-}
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

 [@DESCRIPTION@]	Implements 'Test.QuickCheck.Arbitrary' & defines /QuickCheck/-properties.
-}

module BishBosh.Test.QuickCheck.Attribute.Direction(
-- * Constants
	results
) where

import			Control.Arrow((&&&))
import qualified	BishBosh.Attribute.Direction	as Attribute.Direction
import qualified	BishBosh.Property.Opposable	as Property.Opposable
import qualified	BishBosh.Property.Orientated	as Property.Orientated
import qualified	BishBosh.Property.Reflectable	as Property.Reflectable
import qualified	Test.QuickCheck
import qualified	ToolShed.Test.ReversibleIO

instance Test.QuickCheck.Arbitrary Attribute.Direction.Direction where
	arbitrary	= Test.QuickCheck.elements Attribute.Direction.range

-- | The constant test-results for this data-type.
results :: IO [Test.QuickCheck.Result]
results	= sequence [
	let
		f :: Attribute.Direction.Direction -> Test.QuickCheck.Property
		f	= Test.QuickCheck.label "Direction.prop_readPrependedWhiteSpace" . ToolShed.Test.ReversibleIO.readPrependedWhiteSpace
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 256 } f,
	let
		f :: String -> Test.QuickCheck.Property
		f garbage	= Test.QuickCheck.label "Direction.prop_read" $ case (reads garbage :: [(Attribute.Direction.Direction, String)]) of
			[_]	-> True
			_	-> True	-- Unless the read-implementation throws an exception.
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 256 } f,
	let
		f :: Attribute.Direction.Direction -> String -> Test.QuickCheck.Property
		f direction	= Test.QuickCheck.label "Direction.prop_readTrailingGarbage" . ToolShed.Test.ReversibleIO.readTrailingGarbage (`elem` "ewEW") direction
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 256 } f,
	let
		f :: Attribute.Direction.Direction -> Test.QuickCheck.Property
		f	= Test.QuickCheck.label "Direction.prop_reflectOnX" . uncurry (==) . (id &&& Property.Reflectable.reflectOnX . Property.Reflectable.reflectOnX)
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 16 } f,
	let
		f :: Attribute.Direction.Direction -> Test.QuickCheck.Property
		f	= Test.QuickCheck.label "Direction.prop_reflectOnY" . uncurry (==) . (id &&& Property.Reflectable.reflectOnY . Property.Reflectable.reflectOnY)
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 16 } f,
	let
		f :: Attribute.Direction.Direction -> Test.QuickCheck.Property
		f	= Test.QuickCheck.label "Direction.prop_getOpposite" . uncurry (==) . (Property.Opposable.getOpposite . Property.Opposable.getOpposite &&& id)
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 16 } f,
	let
		f :: Attribute.Direction.Direction -> Test.QuickCheck.Property
		f	= Test.QuickCheck.label "Direction.prop_getOpposite/Reflectable" . uncurry (==) . (Property.Opposable.getOpposite &&& Property.Reflectable.reflectOnY . Property.Reflectable.reflectOnX)
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 16 } f,
	let
		f :: Attribute.Direction.Direction -> Test.QuickCheck.Property
		f	= Test.QuickCheck.label "Direction.prop_areAligned" . uncurry Attribute.Direction.areAligned . (id &&& Property.Opposable.getOpposite)
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 16 } f,
	let
		f :: Attribute.Direction.Direction -> Test.QuickCheck.Property
		f	= Test.QuickCheck.label "Direction.prop_isParallel" . uncurry (/=) . (Property.Orientated.isDiagonal &&& Property.Orientated.isParallel)
	in Test.QuickCheck.quickCheckWithResult Test.QuickCheck.stdArgs { Test.QuickCheck.maxSuccess = 16 } f
 ]



