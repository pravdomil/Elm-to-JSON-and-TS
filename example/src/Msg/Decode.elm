module Msg.Decode exposing (..)

{-| Generated by elm-json-interop.
-}

import Json.Decode as D exposing (Decoder)
import Msg.Msg as A
import User.Decode as User_User exposing (user)
import Utils.Basics.Decode_ as BD


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
    BD.map15 (\a b c d e f g h i j k l m n o -> { bool = a, int = b, float = c, char = d, string = e, unit = f, tuple2 = g, tuple3 = h, list = i, array = j, record = k, maybe = l, result = m, set = n, dict = o }) (D.field "bool" D.bool) (D.field "int" D.int) (D.field "float" D.float) (D.field "char" BD.char) (D.field "string" D.string) (D.field "unit" BD.unit) (D.field "tuple2" (BD.tuple aDecoder bDecoder)) (D.field "tuple3" (BD.tuple3 aDecoder bDecoder bDecoder)) (D.field "list" (D.list (D.map2 (\a b -> { a = a, b = b }) (D.field "a" aDecoder) (D.field "b" bDecoder)))) (D.field "array" (D.array (D.map2 (\a b -> { a = a, b = b }) (D.field "a" aDecoder) (D.field "b" bDecoder)))) (D.field "record" (D.succeed {})) (BD.maybeField "maybe" (BD.maybe aDecoder)) (D.field "result" (BD.result D.int aDecoder)) (D.field "set" (BD.set D.int)) (D.field "dict" (BD.dict D.int aDecoder))
