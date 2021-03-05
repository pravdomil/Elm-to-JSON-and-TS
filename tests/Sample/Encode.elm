module Sample.Encode exposing (..)

{-| Generated by elm-json-interop.
-}

import Json.Encode as E
import Sample exposing (..)
import Sample2.Encode
import Utils.Json.Encode_ as E_ exposing (Encoder)


type0 : Encoder Type0
type0 =
    \v1 ->
        case v1 of
            Type0 ->
                E.object [ ( "_", E.int 0 ) ]


type1 : Encoder Type1
type1 =
    \(Type1 v1) -> E.string v1


type2 : Encoder Type2
type2 =
    \v1 ->
        case v1 of
            Type2 v2 v3 ->
                E.object [ ( "_", E.int 0 ), ( "a", E.string v2 ), ( "b", E.string v3 ) ]


type10 : Encoder Type10
type10 =
    \v1 ->
        case v1 of
            Type10 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 ->
                E.object [ ( "_", E.int 0 ), ( "a", E.string v2 ), ( "b", E.string v3 ), ( "c", E.string v4 ), ( "d", E.string v5 ), ( "e", E.string v6 ), ( "f", E.string v7 ), ( "g", E.string v8 ), ( "h", E.string v9 ), ( "i", E.string v10 ), ( "j", E.string v11 ) ]


record0 : Encoder Record0
record0 =
    \v1 -> E.object []


record1 : Encoder Record1
record1 =
    \v1 ->
        E.object
            [ ( "a"
              , E.string v1.a
              )
            ]


record2 : Encoder Record2
record2 =
    \v1 ->
        E.object
            [ ( "a"
              , E.string v1.a
              )
            , ( "b"
              , E.string v1.b
              )
            ]


record10 : Encoder Record10
record10 =
    \v1 ->
        E.object
            [ ( "a"
              , E.string v1.a
              )
            , ( "b"
              , E.string v1.b
              )
            , ( "c"
              , E.string v1.c
              )
            , ( "d"
              , E.string v1.d
              )
            , ( "e"
              , E.string v1.e
              )
            , ( "f"
              , E.string v1.f
              )
            , ( "g"
              , E.string v1.g
              )
            , ( "h"
              , E.string v1.h
              )
            , ( "i"
              , E.string v1.i
              )
            , ( "j"
              , E.string v1.j
              )
            ]


typeQualified : Encoder TypeQualified
typeQualified =
    Sample2.Encode.sampleType2


typeQualifiedViaAlias : Encoder TypeQualifiedViaAlias
typeQualifiedViaAlias =
    identity


typeUnqualified : Encoder TypeUnqualified
typeUnqualified =
    identity


sampleType : Encoder comparable -> (Encoder b -> (Encoder c -> Encoder (SampleType comparable b c)))
sampleType comparable b c =
    \v1 ->
        case v1 of
            Foo ->
                E.object [ ( "_", E.int 0 ) ]

            Bar v2 ->
                E.object [ ( "_", E.int 1 ), ( "a", E_.tuple3 comparable b c v2 ) ]

            Bas v2 v3 v4 ->
                E.object
                    [ ( "_", E.int 2 )
                    , ( "a"
                      , (\v5 ->
                            E.object
                                [ ( "a"
                                  , comparable v5.a
                                  )
                                ]
                        )
                            v2
                      )
                    , ( "b"
                      , (\v5 ->
                            E.object
                                [ ( "b"
                                  , b v5.b
                                  )
                                ]
                        )
                            v3
                      )
                    , ( "c"
                      , (\v5 ->
                            E.object
                                [ ( "c"
                                  , c v5.c
                                  )
                                ]
                        )
                            v4
                      )
                    ]


sampleRecord : Encoder comparable -> (Encoder b -> (Encoder c -> Encoder (SampleRecord comparable b c)))
sampleRecord comparable b c =
    \v1 ->
        E.object
            [ ( "unit"
              , E_.unit v1.unit
              )
            , ( "bool"
              , E.bool v1.bool
              )
            , ( "int"
              , E.int v1.int
              )
            , ( "float"
              , E.float v1.float
              )
            , ( "char"
              , E_.char v1.char
              )
            , ( "string"
              , E.string v1.string
              )
            , ( "list"
              , E.list comparable v1.list
              )
            , ( "array"
              , E.array comparable v1.array
              )
            , ( "maybe"
              , E_.maybe comparable v1.maybe
              )
            , ( "result"
              , E_.result comparable b v1.result
              )
            , ( "set"
              , E.set comparable v1.set
              )
            , ( "dict"
              , E_.dict comparable b v1.dict
              )
            , ( "tuple"
              , E_.tuple comparable b v1.tuple
              )
            , ( "tuple3"
              , E_.tuple3 comparable b c v1.tuple3
              )
            , ( "record"
              , (\v2 ->
                    E.object
                        [ ( "a"
                          , comparable v2.a
                          )
                        , ( "b"
                          , b v2.b
                          )
                        , ( "c"
                          , c v2.c
                          )
                        ]
                )
                    v1.record
              )
            ]
