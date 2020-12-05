module Msg.Encode exposing (..)

{-| Generated by elm-json-interop.
-}

import Json.Encode as E
import Msg.Msg as A
import User.Encode as User_User exposing (user)
import Utils.Basics.Encode as BE


msg : A.Msg -> E.Value
msg a =
    case a of
        A.PressedEnter ->
            E.object [ ( "type", E.int 0 ) ]

        A.ChangedDraft b ->
            E.object [ ( "type", E.int 1 ), ( "a", E.string b ) ]

        A.ReceivedMessages b ->
            E.object [ ( "type", E.int 2 ), ( "a", E.list (\b_ -> type_ (\b__ -> user b__) (\b__ -> E.string b__) b_) b ) ]

        A.ClickedExit ->
            E.object [ ( "type", E.int 3 ) ]


type_ encodeA encodeB a =
    E.object [ ( "bool", E.bool a.bool ), ( "int", E.int a.int ), ( "float", E.float a.float ), ( "char", BE.char a.char ), ( "string", E.string a.string ), ( "tuple", (\( a_tuple_a, a_tuple_b ) -> E.list identity [ encodeA a_tuple_a, encodeB a_tuple_b ]) a.tuple ), ( "list", E.list (\a_list_ -> E.object [ ( "a", encodeA a_list_.a ), ( "b", encodeB a_list_.b ) ]) a.list ), ( "array", E.array (\a_array_ -> E.object [ ( "a", encodeA a_array_.a ), ( "b", encodeB a_array_.b ) ]) a.array ), ( "record", E.object [ ( "a", encodeA a.record.a ), ( "b", encodeB a.record.b ) ] ), ( "maybe", BE.maybe (\a_maybe_ -> encodeA a_maybe_) a.maybe ), ( "result", BE.result (\a_result_ -> E.int a_result_) (\a_result_ -> encodeA a_result_) a.result ), ( "set", E.set (\a_set_ -> E.int a_set_) a.set ), ( "dict", BE.dict (\a_dict_ -> E.int a_dict_) (\a_dict_ -> encodeA a_dict_) a.dict ) ]
