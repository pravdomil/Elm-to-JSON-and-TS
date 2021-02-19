module User.Encode exposing (..)

{-| Generated by elm-json-interop.
-}

import Json.Encode as E
import User as A
import Utils.Json.Encode_ as E_


user : A.User -> E.Value
user a =
    case a of
        A.Regular b c ->
            E.object [ ( "_", E.int 0 ), ( "a", E.string b ), ( "b", E.int c ) ]

        A.Visitor b ->
            E.object [ ( "_", E.int 1 ), ( "a", E.string b ) ]

        A.Anonymous ->
            E.object [ ( "_", E.int 2 ) ]
