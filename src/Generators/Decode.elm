module Generators.Decode exposing (fileToElmDecoderModule)

import Elm.Syntax.Declaration exposing (Declaration(..))
import Elm.Syntax.Documentation exposing (Documentation)
import Elm.Syntax.File exposing (File)
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node(..))
import Elm.Syntax.Type exposing (Type, ValueConstructor)
import Elm.Syntax.TypeAlias exposing (TypeAlias)
import Elm.Syntax.TypeAnnotation exposing (RecordDefinition, RecordField, TypeAnnotation(..))
import String exposing (join)
import Utils exposing (encodeJsonString, fileToModuleName, letterByInt, moduleImports, moduleNameToString, normalizeRecordFieldName)


{-| To get Elm module for decoding types in file.
-}
fileToElmDecoderModule : File -> String
fileToElmDecoderModule f =
    join "\n"
        [ "module Generated." ++ fileToModuleName f ++ "Decode exposing (..)"
        , ""
        , "import " ++ fileToModuleName f ++ " as A"
        , "import Generated.Basics.BasicsDecode exposing (..)"
        , "import Json.Decode exposing (..)"
        , f.imports
            |> moduleImports
                (\v vv ->
                    "import Generated." ++ moduleNameToString v ++ "Decode exposing (" ++ (vv |> List.map decoderName |> join ", ") ++ ")"
                )
            |> join "\n"
        , ""
        , f.declarations |> List.filterMap decoderFromDeclaration |> join "\n\n"
        , ""
        ]


{-| To maybe get decoder from declaration.
-}
decoderFromDeclaration : Node Declaration -> Maybe String
decoderFromDeclaration a =
    case a |> Node.value of
        AliasDeclaration b ->
            Just (decoderFromTypeAlias b)

        CustomTypeDeclaration b ->
            Just (decoderFromCustomType b)

        _ ->
            Nothing


{-| To get decoder from type alias.
-}
decoderFromTypeAlias : TypeAlias -> String
decoderFromTypeAlias a =
    decoderFromType ("\n  " ++ decoderFromTypeAnnotation a.typeAnnotation) a


{-| To get decoder from custom type.
-}
decoderFromCustomType : Type -> String
decoderFromCustomType a =
    let
        cases : String
        cases =
            a.constructors |> List.map decoderFromCustomTypeConstructor |> join "\n    "

        fail : String
        fail =
            "\n    _ -> fail <| \"I can't decode \" ++ " ++ encodeJsonString (Node.value a.name) ++ " ++ \", what \" ++ tag ++ \" means?\""
    in
    decoderFromType ("\n  index 0 string |> andThen (\\tag -> case tag of\n    " ++ cases ++ fail ++ "\n  )") a


{-| To get decoder from custom type constructor.
-}
decoderFromCustomTypeConstructor : Node ValueConstructor -> String
decoderFromCustomTypeConstructor (Node _ a) =
    let
        name : String
        name =
            Node.value a.name

        arguments : String
        arguments =
            a.arguments |> List.indexedMap (tupleMap 1) |> join " "

        decoder : String
        decoder =
            case a.arguments of
                [] ->
                    "succeed A." ++ name

                _ ->
                    mapFn (List.length a.arguments) ++ " A." ++ name ++ " " ++ arguments
    in
    encodeJsonString name ++ " -> " ++ decoder


{-| To get decoder from type.
-}
decoderFromType : String -> { a | documentation : Maybe (Node Documentation), name : Node String, generics : List (Node String) } -> String
decoderFromType body a =
    let
        name : String
        name =
            Node.value a.name

        lazyDecoded : Bool
        lazyDecoded =
            a.documentation
                |> Maybe.map (\v -> v |> Node.value |> String.toLower |> String.contains "lazy decode")
                |> Maybe.withDefault False

        maybeWrapInLazy : String -> String
        maybeWrapInLazy b =
            case lazyDecoded of
                True ->
                    " lazy (\\_ ->" ++ b ++ "\n  )"

                False ->
                    b

        signature : String
        signature =
            case a.generics of
                [] ->
                    decoderName name ++ " : Decoder A." ++ name ++ "\n"

                _ ->
                    ""

        declaration : String
        declaration =
            decoderName name ++ generics ++ " =" ++ maybeWrapInLazy body

        generics : String
        generics =
            case a.generics of
                [] ->
                    ""

                _ ->
                    " " ++ (a.generics |> List.map (\v -> "t_" ++ Node.value v) |> join " ")
    in
    signature ++ declaration


{-| To get decoder from type annotation.
-}
decoderFromTypeAnnotation : Node TypeAnnotation -> String
decoderFromTypeAnnotation (Node _ a) =
    (case a of
        GenericType b ->
            "t_" ++ b

        Typed b c ->
            fromTyped b c

        Unit ->
            "succeed ()"

        Tupled nodes ->
            fromTuple nodes

        Record b ->
            fromRecord b

        GenericRecord _ (Node _ b) ->
            fromRecord b

        FunctionTypeAnnotation _ _ ->
            "Debug.todo \"I don't know how to decode function.\""
    )
        |> wrapInParentheses


fromTyped : Node ( ModuleName, String ) -> List (Node TypeAnnotation) -> String
fromTyped (Node _ ( name, str )) nodes =
    let
        generics =
            case nodes of
                [] ->
                    ""

                _ ->
                    (++) " " <| join " " <| List.map decoderFromTypeAnnotation nodes

        fn =
            case name ++ [ str ] |> join "." of
                "Int" ->
                    "int"

                "Float" ->
                    "float"

                "Bool" ->
                    "bool"

                "String" ->
                    "string"

                "List" ->
                    "list"

                "Array" ->
                    "array"

                "Maybe" ->
                    "nullable"

                "Encode.Value" ->
                    "value"

                "Decode.Value" ->
                    "value"

                _ ->
                    name ++ [ decoderName str ] |> join "."
    in
    fn ++ generics


fromTuple : List (Node TypeAnnotation) -> String
fromTuple a =
    let
        len =
            List.length a

        tup =
            List.indexedMap (tupleMap 0) a
    in
    mapFn len ++ " " ++ tupleFn len ++ " " ++ join " " tup


tupleMap : Int -> Int -> Node TypeAnnotation -> String
tupleMap offset i a =
    "(index " ++ String.fromInt (offset + i) ++ " " ++ decoderFromTypeAnnotation a ++ ")"


fromRecord : RecordDefinition -> String
fromRecord a =
    let
        len =
            List.length a

        args =
            List.indexedMap (\i _ -> letterByInt i) a

        fields =
            List.indexedMap (\i (Node _ ( Node _ b, _ )) -> b ++ " = " ++ letterByInt i) a

        lambda =
            "(\\" ++ join " " args ++ " -> { " ++ join ", " fields ++ " })"
    in
    mapFn len ++ " " ++ lambda ++ " " ++ (join " " <| List.map fromRecordField a)


fromRecordField : Node RecordField -> String
fromRecordField (Node _ ( Node _ a, b )) =
    let
        decoder : String
        decoder =
            case Node.value b of
                Typed (Node _ ( _, "Maybe" )) _ ->
                    "nullableOrMissingField"

                _ ->
                    "field"
    in
    "(" ++ decoder ++ " " ++ encodeJsonString (normalizeRecordFieldName a) ++ " " ++ decoderFromTypeAnnotation b ++ ")"



--


{-| To wrap string in parentheses.
-}
wrapInParentheses : String -> String
wrapInParentheses a =
    "(" ++ a ++ ")"


{-| To get decoder name.
-}
decoderName : String -> String
decoderName a =
    firstToLowerCase a ++ "Decoder"


{-| To convert first letter of string to lower case.
-}
firstToLowerCase : String -> String
firstToLowerCase a =
    case String.toList a of
        first :: rest ->
            String.fromList (Char.toLower first :: rest)

        _ ->
            a


{-| To get function for constructing tuples by number.
-}
tupleFn : Int -> String
tupleFn len =
    case len of
        2 ->
            "Tuple.pair"

        3 ->
            "(\\a b c -> (a, b, c))"

        _ ->
            ""


{-| To get map function name by argument count.
-}
mapFn : Int -> String
mapFn a =
    case a of
        1 ->
            "map"

        b ->
            "map" ++ String.fromInt b
