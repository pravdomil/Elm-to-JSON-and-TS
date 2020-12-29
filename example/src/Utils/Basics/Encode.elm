module Utils.Basics.Encode exposing (..)

{-| Generated by elm-json-interop.
-}

import Dict exposing (Dict)
import Json.Encode as E


{-| To encode char.
-}
char : Char -> E.Value
char a =
    String.fromChar a |> E.string


{-| -}
unit : () -> E.Value
unit _ =
    E.object []


{-| -}
tuple : (a -> E.Value) -> (b -> E.Value) -> ( a, b ) -> E.Value
tuple encodeA encodeB ( a, b ) =
    E.object [ ( "a", encodeA a ), ( "b", encodeB b ) ]


{-| -}
tuple3 : (a -> E.Value) -> (b -> E.Value) -> (c -> E.Value) -> ( a, b, c ) -> E.Value
tuple3 encodeA encodeB encodeC ( a, b, c ) =
    E.object [ ( "a", encodeA a ), ( "b", encodeB b ), ( "c", encodeC c ) ]


{-| To encode maybe.
-}
maybe : (a -> E.Value) -> Maybe a -> E.Value
maybe encode a =
    case a of
        Just b ->
            encode b

        Nothing ->
            E.null


{-| To encode dictionary.
-}
dict : (comparable -> E.Value) -> (v -> E.Value) -> Dict comparable v -> E.Value
dict encodeKey encodeValue a =
    a
        |> Dict.toList
        |> E.list (\( k, v ) -> E.list identity [ encodeKey k, encodeValue v ])


{-| To encode result.
-}
result : (e -> E.Value) -> (v -> E.Value) -> Result e v -> E.Value
result encodeError encodeValue a =
    case a of
        Ok b ->
            E.object [ ( "_", E.int 0 ), ( "a", encodeValue b ) ]

        Err b ->
            E.object [ ( "_", E.int 1 ), ( "a", encodeError b ) ]
