module Utils.Utils exposing (..)

import Elm.Syntax.File exposing (File)
import Elm.Syntax.Module as Module exposing (Module)
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node(..))
import Json.Encode as Encode
import Regex
import String exposing (join)


{-| To encode string into JSON string.
-}
encodeJsonString : String -> String
encodeJsonString a =
    Encode.string a |> Encode.encode 0


{-| To get letter from alphabet by number.
-}
letterByInt : Int -> String
letterByInt a =
    a + 97 |> Char.fromCode |> String.fromChar


{-| To get module name from file.
-}
fileToModuleName : File -> String
fileToModuleName a =
    Node.value a.moduleDefinition |> Module.moduleName |> moduleNameToString


{-| To get string from module name.
-}
moduleNameToString : ModuleName -> String
moduleNameToString a =
    a |> join "."


{-| To wrap string in parentheses.
-}
wrapInParentheses : String -> String
wrapInParentheses a =
    "(" ++ a ++ ")"


{-| To do simple regular expression replace.
-}
regexReplace : String -> (String -> String) -> String -> String
regexReplace regex replacement a =
    a
        |> Regex.replace
            (regex |> Regex.fromString |> Maybe.withDefault Regex.never)
            (.match >> replacement)


{-| To convert first letter of string to lower case.
-}
firstToLowerCase : String -> String
firstToLowerCase a =
    case String.toList a of
        first :: rest ->
            String.fromList (Char.toLower first :: rest)

        _ ->
            a
