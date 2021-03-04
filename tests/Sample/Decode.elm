module Sample.Decode exposing (..)

{-| Generated by elm-json-interop.
-}

import Sample as A
import Utils.Json.Decode_ as D_
import Json.Decode as D exposing (Decoder)
import Sample2.Decode as Sample2 exposing (sampleType)

type0 : Decoder A.Type0
type0 =
  D.field "_" D.int |> D.andThen (\i___ -> case i___ of
    0 -> D.succeed A.Type0
    _ -> D.fail ("I can't decode " ++ "Type0" ++ ", unknown variant with index " ++ String.fromInt i___ ++ ".")
  )

type1 : Decoder A.Type1
type1 =
  D.field "_" D.int |> D.andThen (\i___ -> case i___ of
    0 -> D.map A.Type1 (D.field "a" (D.string))
    _ -> D.fail ("I can't decode " ++ "Type1" ++ ", unknown variant with index " ++ String.fromInt i___ ++ ".")
  )

type2 : Decoder A.Type2
type2 =
  D.field "_" D.int |> D.andThen (\i___ -> case i___ of
    0 -> D.map2 A.Type2 (D.field "a" (D.string)) (D.field "b" (D.string))
    _ -> D.fail ("I can't decode " ++ "Type2" ++ ", unknown variant with index " ++ String.fromInt i___ ++ ".")
  )

type10 : Decoder A.Type10
type10 =
  D.field "_" D.int |> D.andThen (\i___ -> case i___ of
    0 -> D_.map10 A.Type10 (D.field "a" (D.string)) (D.field "b" (D.string)) (D.field "c" (D.string)) (D.field "d" (D.string)) (D.field "e" (D.string)) (D.field "f" (D.string)) (D.field "g" (D.string)) (D.field "h" (D.string)) (D.field "i" (D.string)) (D.field "j" (D.string))
    _ -> D.fail ("I can't decode " ++ "Type10" ++ ", unknown variant with index " ++ String.fromInt i___ ++ ".")
  )

record0 : Decoder A.Record0
record0 =
  (D.succeed {})

record1 : Decoder A.Record1
record1 =
  (D.map (\a -> { a = a }) (D.field "a" (D.string)))

record2 : Decoder A.Record2
record2 =
  (D.map2 (\a b -> { a = a, b = b }) (D.field "a" (D.string)) (D.field "b" (D.string)))

record10 : Decoder A.Record10
record10 =
  (D_.map10 (\a b c d e f g h i j -> { a = a, b = b, c = c, d = d, e = e, f = f, g = g, h = h, i = i, j = j }) (D.field "a" (D.string)) (D.field "b" (D.string)) (D.field "c" (D.string)) (D.field "d" (D.string)) (D.field "e" (D.string)) (D.field "f" (D.string)) (D.field "g" (D.string)) (D.field "h" (D.string)) (D.field "i" (D.string)) (D.field "j" (D.string)))

typeQualified : Decoder A.TypeQualified
typeQualified =
  (Sample2.sampleType)

typeUnqualified : Decoder A.TypeUnqualified
typeUnqualified =
  (sampleType)

sample aDecoder bDecoder cDecoder =
  (D_.map15 (\a b c d e f g h i j k l m n o -> { unit = a, bool = b, int = c, float = d, char = e, string = f, list = g, array = h, maybe = i, result = j, set = k, dict = l, tuple = m, tuple3 = n, record = o }) (D.field "unit" (D_.unit)) (D.field "bool" (D.bool)) (D.field "int" (D.int)) (D.field "float" (D.float)) (D.field "char" (D_.char)) (D.field "string" (D.string)) (D.field "list" (D.list (aDecoder))) (D.field "array" (D.array (aDecoder))) (D_.maybeField "maybe" (D_.maybe (aDecoder))) (D.field "result" (D_.result (aDecoder) (bDecoder))) (D.field "set" (D_.set (aDecoder))) (D.field "dict" (D_.dict (aDecoder) (bDecoder))) (D.field "tuple" (D_.tuple (aDecoder) (bDecoder))) (D.field "tuple3" (D_.tuple3 (aDecoder) (bDecoder) (cDecoder))) (D.field "record" (D.succeed {})))