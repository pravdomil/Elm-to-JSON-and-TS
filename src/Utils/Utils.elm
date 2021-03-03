module Utils.Utils exposing (..)

import Elm.Syntax.File exposing (File)
import Elm.Syntax.Module as Module exposing (Module)
import Elm.Syntax.Node as Node exposing (Node(..))
import Elm.Syntax.TypeAnnotation exposing (TypeAnnotation(..))
import Json.Encode as Encode


{-| To get module name from file.
-}
fileToModuleName : File -> List String
fileToModuleName a =
    Node.value a.moduleDefinition |> Module.moduleName


{-| To wrap string in parentheses.
-}
wrapInParentheses : String -> String
wrapInParentheses a =
    "(" ++ a ++ ")"


{-| -}
isIdType : Node TypeAnnotation -> Bool
isIdType a =
    case a of
        Node _ (Typed (Node _ ( _, "Id" )) _) ->
            True

        _ ->
            False



--


{-| To encode string into JSON string.
-}
toJsonString : String -> String
toJsonString a =
    Encode.string a |> Encode.encode 0
