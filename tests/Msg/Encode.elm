module Msg.Encode exposing (..)

{-| Generated by elm-json-interop.
-}

import Id.Encode as Id exposing (id)
import Json.Encode as E
import Msg as A
import User.Encode as User exposing (user)
import Utils.Json.Encode_ as E_


msg : A.Msg -> E.Value
msg a =
    case a of
        A.PressedEnter ->
            E.object [ ( "_", E.int 0 ) ]

        A.ChangedDraft b ->
            E.object [ ( "_", E.int 1 ), ( "a", E.string b ) ]

        A.ReceivedMessages b ->
            E.object [ ( "_", E.int 2 ), ( "a", E.list (\b_ -> E_.tuple (\b__ -> id b__) (\b__ -> message (\b___ -> user b___) (\b___ -> E.string b___) b__) b_) b ) ]

        A.ClickedExit ->
            E.object [ ( "_", E.int 3 ) ]


message encodeA encodeB a =
    E.object [ ( "bool", E.bool a.bool ), ( "int", E.int a.int ), ( "float", E.float a.float ), ( "char", E_.char a.char ), ( "string", E.string a.string ), ( "unit", E_.unit a.unit ), ( "tuple", E_.tuple (\a_tuple_ -> encodeA a_tuple_) (\a_tuple_ -> encodeB a_tuple_) a.tuple ), ( "tuple3", E_.tuple3 (\a_tuple3_ -> encodeA a_tuple3_) (\a_tuple3_ -> encodeB a_tuple3_) (\a_tuple3_ -> encodeB a_tuple3_) a.tuple3 ), ( "list", E.list (\a_list_ -> E.object [ ( "a", encodeA a_list_.a ), ( "b", encodeB a_list_.b ) ]) a.list ), ( "array", E.array (\a_array_ -> E.object [ ( "a", encodeA a_array_.a ), ( "b", encodeB a_array_.b ) ]) a.array ), ( "record", E.object [] ), ( "maybe", E_.maybe (\a_maybe_ -> encodeA a_maybe_) a.maybe ), ( "result", E_.result (\a_result_ -> E.int a_result_) (\a_result_ -> encodeA a_result_) a.result ), ( "set", E.set (\a_set_ -> E.int a_set_) a.set ), ( "dict", E_.dict (\a_dict_ -> E.int a_dict_) (\a_dict_ -> encodeA a_dict_) a.dict ) ]