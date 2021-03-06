module Sample2.Decode exposing (..)

{-| Generated by elm-json-interop.
-}

import Json.Decode as D exposing (Decoder)
import Sample2 exposing (..)
import Utils.Json.Decode_ as D_


sampleType2 : Decoder SampleType2
sampleType2 =
    D.field "_" D.int
        |> D.andThen
            (\i___ ->
                case i___ of
                    0 ->
                        D.succeed SampleType2

                    _ ->
                        D.fail ("I can't decode \"SampleType2\", unknown variant with index " ++ String.fromInt i___ ++ ".")
            )
