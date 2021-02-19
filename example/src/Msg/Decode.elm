module Msg.Decode exposing (..)

{-| Generated by elm-json-interop.
-}

import Json.Decode as D exposing (Decoder)
import Msg as A
import User.Decode as User exposing (user)
import Utils.Json.Decode_ as D_


msg : Decoder A.Msg
msg =
    D.field "_" D.int
        |> D.andThen
            (\i___ ->
                case i___ of
                    0 ->
                        D.succeed A.PressedEnter

                    1 ->
                        D.map A.ChangedDraft (D.field "a" D.string)

                    2 ->
                        D.map A.ReceivedMessages (D.field "a" (D.list (type_ user D.string)))

                    3 ->
                        D.succeed A.ClickedExit

                    _ ->
                        D.fail ("I can't decode " ++ "Msg" ++ ", unknown variant with index " ++ String.fromInt i___ ++ ".")
            )


type_ aDecoder bDecoder =
    D_.map15 (\a b c d e f g h i j k l m n o -> { bool = a, int = b, float = c, char = d, string = e, unit = f, tuple2 = g, tuple3 = h, list = i, array = j, record = k, maybe = l, result = m, set = n, dict = o }) (D.field "bool" D.bool) (D.field "int" D.int) (D.field "float" D.float) (D.field "char" D_.char) (D.field "string" D.string) (D.field "unit" D_.unit) (D.field "tuple2" (D_.tuple aDecoder bDecoder)) (D.field "tuple3" (D_.tuple3 aDecoder bDecoder bDecoder)) (D.field "list" (D.list (D.map2 (\a b -> { a = a, b = b }) (D.field "a" aDecoder) (D.field "b" bDecoder)))) (D.field "array" (D.array (D.map2 (\a b -> { a = a, b = b }) (D.field "a" aDecoder) (D.field "b" bDecoder)))) (D.field "record" (D.succeed {})) (D_.maybeField "maybe" (D_.maybe aDecoder)) (D.field "result" (D_.result D.int aDecoder)) (D.field "set" (D_.set D.int)) (D.field "dict" (D_.dict D.int aDecoder))
