module Utils.Task_ exposing (..)

{-| <https://github.com/avh4/elm-format/issues/568#issuecomment-554753735>
-}

import Json.Decode as Decode exposing (Decoder)
import Task exposing (..)


{-| -}
fromMaybe : x -> Maybe a -> Task x a
fromMaybe x a =
    case a of
        Just b ->
            Task.succeed b

        Nothing ->
            Task.fail x


{-| -}
fromResult : Result x a -> Task x a
fromResult a =
    case a of
        Ok b ->
            Task.succeed b

        Err b ->
            Task.fail b



--


{-| -}
andThenDecode : Decoder a -> Task String Decode.Value -> Task String a
andThenDecode decoder a =
    a
        |> Task.andThen
            (\v ->
                v
                    |> Decode.decodeValue decoder
                    |> Result.mapError Decode.errorToString
                    |> fromResult
            )



--


{-| -}
andThen2 :
    (a -> b -> Task x result)
    -> Task x a
    -> Task x b
    -> Task x result
andThen2 fn a b =
    andThen
        (\a_ ->
            andThen
                (\b_ ->
                    fn
                        a_
                        b_
                )
                b
        )
        a


{-| -}
andThen3 :
    (a -> b -> c -> Task x result)
    -> Task x a
    -> Task x b
    -> Task x c
    -> Task x result
andThen3 fn a b c =
    andThen
        (\a_ ->
            andThen
                (\b_ ->
                    andThen
                        (\c_ ->
                            fn
                                a_
                                b_
                                c_
                        )
                        c
                )
                b
        )
        a


{-| -}
andThen4 :
    (a -> b -> c -> d -> Task x result)
    -> Task x a
    -> Task x b
    -> Task x c
    -> Task x d
    -> Task x result
andThen4 fn a b c d =
    andThen
        (\a_ ->
            andThen
                (\b_ ->
                    andThen
                        (\c_ ->
                            andThen
                                (\d_ ->
                                    fn
                                        a_
                                        b_
                                        c_
                                        d_
                                )
                                d
                        )
                        c
                )
                b
        )
        a


{-| -}
andThen5 :
    (a -> b -> c -> d -> e -> Task x result)
    -> Task x a
    -> Task x b
    -> Task x c
    -> Task x d
    -> Task x e
    -> Task x result
andThen5 fn a b c d e =
    andThen
        (\a_ ->
            andThen
                (\b_ ->
                    andThen
                        (\c_ ->
                            andThen
                                (\d_ ->
                                    andThen
                                        (\e_ ->
                                            fn
                                                a_
                                                b_
                                                c_
                                                d_
                                                e_
                                        )
                                        e
                                )
                                d
                        )
                        c
                )
                b
        )
        a


{-| -}
andThen6 :
    (a -> b -> c -> d -> e -> f -> Task x result)
    -> Task x a
    -> Task x b
    -> Task x c
    -> Task x d
    -> Task x e
    -> Task x f
    -> Task x result
andThen6 fn a b c d e f =
    andThen
        (\a_ ->
            andThen
                (\b_ ->
                    andThen
                        (\c_ ->
                            andThen
                                (\d_ ->
                                    andThen
                                        (\e_ ->
                                            andThen
                                                (\f_ ->
                                                    fn
                                                        a_
                                                        b_
                                                        c_
                                                        d_
                                                        e_
                                                        f_
                                                )
                                                f
                                        )
                                        e
                                )
                                d
                        )
                        c
                )
                b
        )
        a


{-| -}
andThen7 :
    (a -> b -> c -> d -> e -> f -> g -> Task x result)
    -> Task x a
    -> Task x b
    -> Task x c
    -> Task x d
    -> Task x e
    -> Task x f
    -> Task x g
    -> Task x result
andThen7 fn a b c d e f g =
    andThen
        (\a_ ->
            andThen
                (\b_ ->
                    andThen
                        (\c_ ->
                            andThen
                                (\d_ ->
                                    andThen
                                        (\e_ ->
                                            andThen
                                                (\f_ ->
                                                    andThen
                                                        (\g_ ->
                                                            fn
                                                                a_
                                                                b_
                                                                c_
                                                                d_
                                                                e_
                                                                f_
                                                                g_
                                                        )
                                                        g
                                                )
                                                f
                                        )
                                        e
                                )
                                d
                        )
                        c
                )
                b
        )
        a


{-| -}
andThen8 :
    (a -> b -> c -> d -> e -> f -> g -> h -> Task x result)
    -> Task x a
    -> Task x b
    -> Task x c
    -> Task x d
    -> Task x e
    -> Task x f
    -> Task x g
    -> Task x h
    -> Task x result
andThen8 fn a b c d e f g h =
    andThen
        (\a_ ->
            andThen
                (\b_ ->
                    andThen
                        (\c_ ->
                            andThen
                                (\d_ ->
                                    andThen
                                        (\e_ ->
                                            andThen
                                                (\f_ ->
                                                    andThen
                                                        (\g_ ->
                                                            andThen
                                                                (\h_ ->
                                                                    fn
                                                                        a_
                                                                        b_
                                                                        c_
                                                                        d_
                                                                        e_
                                                                        f_
                                                                        g_
                                                                        h_
                                                                )
                                                                h
                                                        )
                                                        g
                                                )
                                                f
                                        )
                                        e
                                )
                                d
                        )
                        c
                )
                b
        )
        a


{-| -}
andThen9 :
    (a -> b -> c -> d -> e -> f -> g -> h -> i -> Task x result)
    -> Task x a
    -> Task x b
    -> Task x c
    -> Task x d
    -> Task x e
    -> Task x f
    -> Task x g
    -> Task x h
    -> Task x i
    -> Task x result
andThen9 fn a b c d e f g h i =
    andThen
        (\a_ ->
            andThen
                (\b_ ->
                    andThen
                        (\c_ ->
                            andThen
                                (\d_ ->
                                    andThen
                                        (\e_ ->
                                            andThen
                                                (\f_ ->
                                                    andThen
                                                        (\g_ ->
                                                            andThen
                                                                (\h_ ->
                                                                    andThen
                                                                        (\i_ ->
                                                                            fn
                                                                                a_
                                                                                b_
                                                                                c_
                                                                                d_
                                                                                e_
                                                                                f_
                                                                                g_
                                                                                h_
                                                                                i_
                                                                        )
                                                                        i
                                                                )
                                                                h
                                                        )
                                                        g
                                                )
                                                f
                                        )
                                        e
                                )
                                d
                        )
                        c
                )
                b
        )
        a


{-| -}
andThen10 :
    (a -> b -> c -> d -> e -> f -> g -> h -> i -> j -> Task x result)
    -> Task x a
    -> Task x b
    -> Task x c
    -> Task x d
    -> Task x e
    -> Task x f
    -> Task x g
    -> Task x h
    -> Task x i
    -> Task x j
    -> Task x result
andThen10 fn a b c d e f g h i j =
    andThen
        (\a_ ->
            andThen
                (\b_ ->
                    andThen
                        (\c_ ->
                            andThen
                                (\d_ ->
                                    andThen
                                        (\e_ ->
                                            andThen
                                                (\f_ ->
                                                    andThen
                                                        (\g_ ->
                                                            andThen
                                                                (\h_ ->
                                                                    andThen
                                                                        (\i_ ->
                                                                            andThen
                                                                                (\j_ ->
                                                                                    fn
                                                                                        a_
                                                                                        b_
                                                                                        c_
                                                                                        d_
                                                                                        e_
                                                                                        f_
                                                                                        g_
                                                                                        h_
                                                                                        i_
                                                                                        j_
                                                                                )
                                                                                j
                                                                        )
                                                                        i
                                                                )
                                                                h
                                                        )
                                                        g
                                                )
                                                f
                                        )
                                        e
                                )
                                d
                        )
                        c
                )
                b
        )
        a