module Neorg.Parser.Tag where

import Control.Monad
import Data.List (intersperse)
import Data.Map qualified as M
import Data.Maybe
import Data.Text (Text, pack)
import Neorg.Document
import Neorg.Parser.Base
import Neorg.Parser.Combinators
import Text.Megaparsec

tagBreak :: Parser ()
tagBreak = try $ lookAhead $ do
  atBeginningOfLine >>= guard
  char '@'
  void tagName

verbatimRangedTag :: Parser VerbatimRangedTag
verbatimRangedTag = do
  (whitespaceToSkip, name) <- try $ do
    char '@'
    liftA2
      (,)
      (pred . pred . unPos . sourceColumn <$> getSourcePos)
      tagName
  guard $ name /= "end"
  let maybeTag = M.lookup name definedTags
  tagType <- fromMaybe undefinedTagType maybeTag
  newline
  !content <- withinTag '@' whitespaceToSkip takeLine
  pure $ VerbatimRangedTagCons tagType $ mconcat $ intersperse "\n" $ filter (/= "") content

withinTag :: Char -> Int -> Parser a -> Parser [a]
withinTag tagChar tagOffset lineParser = lexeme content
  where
    content = do
      lineWhitespace <|> (spaces >> followedBy newline)
      choice
        [ try ([] <$ (char tagChar >> text "end")),
          liftA2 (:) (lineParser >-> newline) content
        ]

    lineWhitespace = text $ pack $ replicate tagOffset ' '

tagName :: Parser Text
tagName = lexemeSpaces $ takeWhile1Chars (Just "Tag name") (`notElem` (" \n" :: String))

textParameter :: Parser Text
textParameter = lexemeSpaces $ takeWhile1Chars (Just "Tag paremter") (`notElem` (" \n" :: String))

-- Arbitrary tag, discards all params
undefinedTagType :: Parser VerbatimRangedTagType
undefinedTagType = VerbatimRangedTagUntyped <$ takeLine

definedTags :: M.Map Text (Parser VerbatimRangedTagType)
definedTags = M.fromList [codeTag]
  where
    codeTag = ("code", VerbatimRangedTagCode <$> optional textParameter)
