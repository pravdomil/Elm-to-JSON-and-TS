module Generated.User.Encode exposing (..)

import Generated.Basics.Encode as BE
import Json.Encode as E
import User as A


user : A.User -> E.Value
user a =
    case a of
        A.Regular b c ->
            E.object [ ( "type", E.string "Regular" ), ( "a", E.string b ), ( "b", E.int c ) ]

        A.Visitor b ->
            E.object [ ( "type", E.string "Visitor" ), ( "a", E.string b ) ]

        A.Anonymous ->
            E.object [ ( "type", E.string "Anonymous" ) ]
