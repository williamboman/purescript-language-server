module LanguageServer.IdePurescript.Formatting where

import Prelude
import Data.Either (Either(..))
import Data.Foldable (length)
import Data.String.Utils (lines)
import Effect.Aff (Aff, attempt, makeAff)
import Effect.Class (liftEffect)
import LanguageServer.DocumentStore (getDocument)
import LanguageServer.Handlers (DocumentFormattingParams)
import LanguageServer.IdePurescript.Types (ServerState)
import LanguageServer.TextDocument (getText)
import LanguageServer.Types (DocumentStore, Position(..), Range(..), Settings, TextDocumentIdentifier(..), TextEdit(..))
import Node.Buffer (toString)
import Node.ChildProcess (defaultExecOptions, execFile, stdin)
import Node.Encoding (Encoding(..))
import Node.Stream (writeString, end)

getFormattedDocument :: DocumentStore -> Settings -> ServerState -> DocumentFormattingParams -> Aff (Array TextEdit)
getFormattedDocument docs _settings _serverState { textDocument: TextDocumentIdentifier textDocId } = do
  text <- liftEffect $ getText =<< getDocument docs textDocId.uri
  newTextEither <- attempt $ formatWithPurty text
  pure
    $ case newTextEither of
        Left _ -> []
        Right "" -> []
        Right newText -> [ mkTextEdit newText ]

formatWithPurty :: String -> Aff String
formatWithPurty text =
  makeAff \cb -> do
    process <-
      execFile "purty" [ "format", "-" ] (defaultExecOptions)
        ( \{ stdout } -> do
            newText <- toString UTF8 stdout
            cb $ pure newText
        )
    void $ writeString (stdin process) UTF8 text (pure unit)
    end (stdin process) (pure unit)
    pure mempty

mkTextEdit :: String -> TextEdit
mkTextEdit text = TextEdit { range, newText: text }
  where
  range =
    Range
      { start: Position { line: 0, character: 0 }
      , end: Position { line: (length $ lines text) + 1, character: 0 }
      }