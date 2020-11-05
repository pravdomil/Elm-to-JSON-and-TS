module Main exposing (..)

import Elm.Parser
import Elm.Processing as Processing
import Elm.RawFile exposing (RawFile)
import Elm.Syntax.File exposing (File)
import Generators.Decode exposing (fileToElmDecodeModule)
import Generators.Encode exposing (fileToElmEncodeModule)
import Generators.TypeScript exposing (fileToTypeScriptDeclaration)
import Interop.JsCode exposing (..)
import Parser exposing (deadEndsToString)
import Regex
import String exposing (join, replace)
import Task exposing (Task)
import Utils.TaskUtils exposing (..)


{-| To define main entry point.
-}
main : Program () () ()
main =
    cliProgram
        (run
            |> Task.andThen consoleLog
            |> Task.onError (\v -> consoleError v |> Task.andThen (\_ -> processExit 1))
            |> Task.attempt (\_ -> ())
        )


{-| To show usage or process input files.
-}
run : Task Error String
run =
    Task.andThen
        (\args ->
            case args |> List.drop 2 of
                [] ->
                    Task.fail usage

                a ->
                    a
                        |> List.map processFile
                        |> Task.sequence
                        |> Task.map (join "\n")
        )
        getArguments


{-| To get program usage.
-}
usage : String
usage =
    "Usage: elm-json-interop [File.elm ...]"


{-| To process generate types for file.
-}
processFile : String -> Task Error String
processFile path =
    let
        generateTask : String -> String -> String -> RawFile -> Task Error String
        generateTask binPath fullPath srcFolder rawFile =
            let
                generatedFolder : String
                generatedFolder =
                    fullPath |> replace srcFolder (srcFolder ++ "Generated/") |> dirname

                moduleName : String
                moduleName =
                    fullPath |> basename ".elm"

                file : File
                file =
                    rawFile |> Processing.process Processing.init
            in
            [ mkDir (srcFolder ++ "Generated/Basics")
            , copyFile (binPath ++ "/../src/Generated/Basics/BasicsEncode.elm") (srcFolder ++ "Generated/Basics/BasicsEncode.elm")
            , copyFile (binPath ++ "/../src/Generated/Basics/BasicsDecode.elm") (srcFolder ++ "Generated/Basics/BasicsDecode.elm")
            , copyFile (binPath ++ "/../src/Generated/Basics/Basics.ts") (srcFolder ++ "Generated/Basics/Basics.ts")
            , mkDir generatedFolder
            , writeFile (generatedFolder ++ "/" ++ moduleName ++ "Encode.elm") (fileToElmEncodeModule file)
            , writeFile (generatedFolder ++ "/" ++ moduleName ++ "Decode.elm") (fileToElmDecodeModule file)
            , writeFile (generatedFolder ++ "/" ++ moduleName ++ ".ts") (fileToTypeScriptDeclaration file)
            ]
                |> Task.sequence
                |> Task.map
                    (\_ ->
                        "I have generated Elm encoder, Elm decoder, TypeScript declaration in folder:\n" ++ generatedFolder
                    )
    in
    taskAndThen2
        (\a b ->
            taskAndThen2
                (\c d ->
                    generateTask a b c d
                )
                (srcFolderPathTask b)
                (readAndParseElmFile b)
        )
        dirname__
        (realPath path)


{-| -}
srcFolderPath : String -> Maybe String
srcFolderPath path =
    path
        |> Regex.find ("^.*/src/" |> Regex.fromString |> Maybe.withDefault Regex.never)
        |> List.head
        |> Maybe.map .match


{-| -}
srcFolderPathTask : String -> Task Error String
srcFolderPathTask a =
    a |> srcFolderPath |> maybeToTask "Elm file must be inside \"src\" folder."


{-| -}
readAndParseElmFile : String -> Task Error RawFile
readAndParseElmFile a =
    a
        |> readFile
        |> Task.andThen
            (\v ->
                v
                    |> Elm.Parser.parse
                    |> Result.mapError (\vv -> "I can't parse \"" ++ a ++ "\", because: " ++ deadEndsToString vv ++ ".")
                    |> resultToTask
            )



--


{-| To get basename.
-}
basename : String -> String -> String
basename extension a =
    a
        |> regexReplace "^.*/" ""
        |> (\v ->
                if v |> String.endsWith extension then
                    v |> String.dropRight (extension |> String.length)

                else
                    v
           )


{-| To get dirname.
-}
dirname : String -> String
dirname a =
    a |> regexReplace "/[^/]+$" ""


{-| To do simple regular expression replace.
-}
regexReplace : String -> String -> String -> String
regexReplace regex replacement a =
    a
        |> Regex.replace
            (regex |> Regex.fromString |> Maybe.withDefault Regex.never)
            (\_ -> replacement)
