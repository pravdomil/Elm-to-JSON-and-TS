module Generators.Decode exposing (toElmDecoder)

import Elm.Syntax.Declaration exposing (Declaration(..))
import Elm.Syntax.Documentation exposing (Documentation)
import Elm.Syntax.File exposing (File)
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node(..))
import Elm.Syntax.Type exposing (Type, ValueConstructor)
import Elm.Syntax.TypeAlias exposing (TypeAlias)
import Elm.Syntax.TypeAnnotation exposing (RecordDefinition, RecordField, TypeAnnotation(..))
import String exposing (join)
import Utils exposing (getImports, mapFn, moduleNameFromFile, moduleNameToString, normalizeRecordFieldName, stringFromAlphabet, toJsonString, tupleConstructor)


toElmDecoder : File -> String
toElmDecoder f =
    join "\n"
        [ "module Generated." ++ moduleNameFromFile f ++ "Decode exposing (..)"
        , ""
        , "import " ++ moduleNameFromFile f ++ " as A"
        , "import Generated.Basics.BasicsDecode exposing (..)"
        , "import Json.Decode exposing (..)"
        , f.imports
            |> getImports (\n i -> "import Generated." ++ moduleNameToString n ++ "Decode exposing (" ++ i ++ ")") decoderName
            |> join "\n"
        , ""
        , f.declarations |> List.filterMap fromDeclaration |> join "\n\n"
        , ""
        ]


fromDeclaration : Node Declaration -> Maybe String
fromDeclaration (Node _ a) =
    case a of
        AliasDeclaration b ->
            Just <| fromTypeAlias b

        CustomTypeDeclaration b ->
            Just <| fromCustomType b

        _ ->
            Nothing


fromType : { a | documentation : Maybe (Node Documentation), name : Node String, generics : List (Node String) } -> String -> String
fromType a body =
    let
        lazyDecoded =
            a.documentation |> Maybe.map Node.value |> Maybe.withDefault "" |> String.toLower |> String.contains "lazy decode"

        name =
            Node.value a.name

        signature =
            case a.generics of
                [] ->
                    decoderName name ++ " : Decoder A." ++ name ++ "\n"

                _ ->
                    ""

        generics =
            case a.generics of
                [] ->
                    ""

                _ ->
                    (++) " " <| join " " <| List.map (\(Node _ v) -> "t_" ++ v) a.generics

        declaration =
            decoderName name ++ generics ++ " ="
    in
    [ signature
    , declaration
    , case lazyDecoded of
        True ->
            " lazy (\\_ ->" ++ body ++ "\n  )"

        False ->
            body
    ]
        |> join ""


fromTypeAlias : TypeAlias -> String
fromTypeAlias a =
    fromType a ("\n  " ++ fromTypeAnnotation a.typeAnnotation)


fromCustomType : Type -> String
fromCustomType a =
    let
        cases =
            join "\n    " <| List.map fromCustomTypeConstructor a.constructors

        fail =
            "\n    _ -> fail <| \"I can't decode \" ++ " ++ toJsonString (Node.value a.name) ++ " ++ \", what \" ++ tag ++ \" means?\""
    in
    fromType a ("\n  index 0 string |> andThen (\\tag -> case tag of\n    " ++ cases ++ fail ++ "\n  )")


fromCustomTypeConstructor : Node ValueConstructor -> String
fromCustomTypeConstructor (Node _ a) =
    let
        name =
            "A." ++ Node.value a.name

        len =
            List.length a.arguments

        tup =
            List.indexedMap (tupleMap 1) a.arguments

        val =
            case a.arguments of
                [] ->
                    "succeed " ++ name

                _ ->
                    mapFn len ++ " " ++ name ++ " " ++ join " " tup
    in
    toJsonString (Node.value a.name) ++ " -> " ++ val


fromTypeAnnotation : Node TypeAnnotation -> String
fromTypeAnnotation (Node _ a) =
    let
        result =
            case a of
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
    in
    "(" ++ result ++ ")"


fromTyped : Node ( ModuleName, String ) -> List (Node TypeAnnotation) -> String
fromTyped (Node _ ( name, str )) nodes =
    let
        generics =
            case nodes of
                [] ->
                    ""

                _ ->
                    (++) " " <| join " " <| List.map fromTypeAnnotation nodes

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
    mapFn len ++ " " ++ tupleConstructor len ++ " " ++ join " " tup


tupleMap : Int -> Int -> Node TypeAnnotation -> String
tupleMap offset i a =
    "(index " ++ String.fromInt (offset + i) ++ " " ++ fromTypeAnnotation a ++ ")"


fromRecord : RecordDefinition -> String
fromRecord a =
    let
        len =
            List.length a

        args =
            List.indexedMap (\i _ -> stringFromAlphabet i) a

        fields =
            List.indexedMap (\i (Node _ ( Node _ b, _ )) -> b ++ " = " ++ stringFromAlphabet i) a

        lambda =
            "(\\" ++ join " " args ++ " -> { " ++ join ", " fields ++ " })"
    in
    mapFn len ++ " " ++ lambda ++ " " ++ (join " " <| List.map fromRecordField a)


fromRecordField : Node RecordField -> String
fromRecordField (Node _ ( Node _ a, b )) =
    let
        maybeField =
            case Node.value b of
                Typed (Node _ ( _, "Maybe" )) _ ->
                    "(\\maybeField -> oneOf [ maybeField, succeed Nothing ]) <| "

                _ ->
                    ""
    in
    "(" ++ maybeField ++ "field " ++ toJsonString (normalizeRecordFieldName a) ++ " " ++ fromTypeAnnotation b ++ ")"


decoderName : String -> String
decoderName a =
    firstToLowerCase a ++ "Decoder"


firstToLowerCase : String -> String
firstToLowerCase a =
    case String.toList a of
        first :: rest ->
            Char.toLower first :: rest |> String.fromList

        _ ->
            a
