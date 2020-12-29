module Generators.Decode exposing (fromFile)

import Elm.Syntax.Declaration exposing (Declaration(..))
import Elm.Syntax.Documentation exposing (Documentation)
import Elm.Syntax.File exposing (File)
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node(..))
import Elm.Syntax.Range exposing (emptyRange)
import Elm.Syntax.Type exposing (Type, ValueConstructor)
import Elm.Syntax.TypeAlias exposing (TypeAlias)
import Elm.Syntax.TypeAnnotation exposing (RecordDefinition, RecordField, TypeAnnotation(..))
import Utils.Imports as Imports
import Utils.Utils exposing (dropLast, fileToModuleName, isIdType, letterByInt, toFunctionName, toJsonString, wrapInParentheses)


{-| To get Elm module for decoding types in file.
-}
fromFile : File -> String
fromFile a =
    [ "module " ++ (a |> fileToModuleName |> dropLast |> String.join ".") ++ ".Decode exposing (..)"
    , ""
    , "{-| Generated by elm-json-interop."
    , "-}"
    , ""
    , "import " ++ (a |> fileToModuleName |> String.join ".") ++ " as A"
    , "import Utils.Basics.Decode_ as D_"
    , "import Json.Decode as D exposing (Decoder)"
    , a.imports |> Imports.fromList "Decode"
    , ""
    , a.declarations |> List.filterMap fromDeclaration |> String.join "\n\n"
    , ""
    ]
        |> String.join "\n"


{-| To maybe get decoder from declaration.
-}
fromDeclaration : Node Declaration -> Maybe String
fromDeclaration a =
    case a |> Node.value of
        AliasDeclaration b ->
            Just (fromTypeAlias b)

        CustomTypeDeclaration b ->
            Just (fromCustomType b)

        _ ->
            Nothing


{-| To get decoder from type alias.
-}
fromTypeAlias : TypeAlias -> String
fromTypeAlias a =
    a |> fromType ("\n  " ++ fromTypeAnnotation a.typeAnnotation)


{-| To get decoder from custom type.
-}
fromCustomType : Type -> String
fromCustomType a =
    let
        cases : String
        cases =
            a.constructors
                |> List.indexedMap fromCustomTypeConstructor
                |> String.join "\n    "

        fail : String
        fail =
            "\n    _ -> D.fail (\"I can't decode \" ++ " ++ toJsonString (Node.value a.name) ++ " ++ \", unknown variant with index \" ++ String.fromInt i___ ++ \".\")"
    in
    a |> fromType ("\n  D.field \"_\" D.int |> D.andThen (\\i___ -> case i___ of\n    " ++ cases ++ fail ++ "\n  )")


{-| To get decoder from custom type constructor.
-}
fromCustomTypeConstructor : Int -> Node ValueConstructor -> String
fromCustomTypeConstructor i (Node _ a) =
    let
        name : String
        name =
            Node.value a.name

        arguments : String
        arguments =
            a.arguments
                |> List.indexedMap
                    (\i_ v ->
                        let
                            fieldName : String
                            fieldName =
                                if isIdType v then
                                    "_id"

                                else
                                    letterByInt i_
                        in
                        fromRecordField (Node emptyRange ( Node emptyRange fieldName, v ))
                    )
                |> String.join " "

        decoder : String
        decoder =
            case a.arguments of
                [] ->
                    "D.succeed A." ++ name

                _ ->
                    mapFn (List.length a.arguments) ++ " A." ++ name ++ " " ++ arguments
    in
    String.fromInt i ++ " -> " ++ decoder


{-| To get decoder from type.
-}
fromType : String -> { a | documentation : Maybe (Node Documentation), name : Node String, generics : List (Node String) } -> String
fromType body a =
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
                    " D.lazy (\\_ ->" ++ b ++ "\n  )"

                False ->
                    b

        signature : String
        signature =
            case a.generics of
                [] ->
                    toFunctionName name ++ " : Decoder A." ++ name ++ "\n"

                _ ->
                    ""

        declaration : String
        declaration =
            toFunctionName name ++ generics ++ " =" ++ maybeWrapInLazy body

        generics : String
        generics =
            case a.generics of
                [] ->
                    ""

                _ ->
                    " " ++ (a.generics |> List.map (\v -> Node.value v ++ "Decoder") |> String.join " ")
    in
    signature ++ declaration


{-| To get decoder from type annotation.
-}
fromTypeAnnotation : Node TypeAnnotation -> String
fromTypeAnnotation a =
    (case a |> Node.value of
        GenericType b ->
            b ++ "Decoder"

        Typed b c ->
            fromTyped b c

        Unit ->
            "D_.unit"

        Tupled nodes ->
            fromTuple nodes

        Record b ->
            fromRecord b

        GenericRecord _ _ ->
            -- https://www.reddit.com/r/elm/comments/atitkl/using_extensible_record_with_json_decoder/
            "Debug.todo \"I don't know how to decode extensible record.\""

        FunctionTypeAnnotation _ _ ->
            "Debug.todo \"I don't know how to decode function.\""
    )
        |> wrapInParentheses


{-| To get decoder from typed.
-}
fromTyped : Node ( ModuleName, String ) -> List (Node TypeAnnotation) -> String
fromTyped (Node _ ( moduleName, name )) arguments =
    let
        fn : String
        fn =
            case moduleName ++ [ name ] |> String.join "." of
                "Bool" ->
                    "D.bool"

                "Int" ->
                    "D.int"

                "Float" ->
                    "D.float"

                "String" ->
                    "D.string"

                "Maybe" ->
                    "D_.maybe"

                "List" ->
                    "D.list"

                "Array" ->
                    "D.array"

                "Char" ->
                    "D_.char"

                "Result" ->
                    "D_.result"

                "Set" ->
                    "D_.set"

                "Dict" ->
                    "D_.dict"

                "Encode.Value" ->
                    "D.value"

                "Decode.Value" ->
                    "D.value"

                _ ->
                    (if moduleName |> List.isEmpty then
                        ""

                     else
                        (moduleName |> String.join "_") ++ "."
                    )
                        ++ toFunctionName name

        arguments_ : String
        arguments_ =
            case arguments of
                [] ->
                    ""

                _ ->
                    " " ++ (arguments |> List.map fromTypeAnnotation |> String.join " ")
    in
    fn ++ arguments_


{-| To get decoder from tuple.
-}
fromTuple : List (Node TypeAnnotation) -> String
fromTuple a =
    let
        fn : String
        fn =
            if a |> List.length |> (==) 2 then
                "D_.tuple"

            else
                "D_.tuple3"
    in
    fn ++ " " ++ (a |> List.map fromTypeAnnotation |> String.join " ")


{-| To get decoder from record.
-}
fromRecord : RecordDefinition -> String
fromRecord a =
    let
        parameters : String
        parameters =
            a
                |> List.indexedMap (\i _ -> letterByInt i)
                |> String.join " "

        fields : String
        fields =
            a
                |> List.indexedMap (\i b -> (b |> Node.value |> Tuple.first |> Node.value) ++ " = " ++ letterByInt i)
                |> String.join ", "

        constructorFn : String
        constructorFn =
            "(\\" ++ parameters ++ " -> { " ++ fields ++ " })"
    in
    if a |> List.length |> (==) 0 then
        "D.succeed {}"

    else
        mapFn (List.length a) ++ " " ++ constructorFn ++ " " ++ (a |> List.map fromRecordField |> String.join " ")


{-| To get decoder from record field.
-}
fromRecordField : Node RecordField -> String
fromRecordField (Node _ ( Node _ a, b )) =
    let
        decoder : String
        decoder =
            case Node.value b of
                Typed (Node _ ( _, "Maybe" )) _ ->
                    "D_.maybeField"

                _ ->
                    "D.field"

        fieldName : String
        fieldName =
            if a == "id" && isIdType b then
                "_id"

            else
                a
    in
    "(" ++ decoder ++ " " ++ toJsonString fieldName ++ " " ++ fromTypeAnnotation b ++ ")"



--


{-| To get map function name by argument count.
-}
mapFn : Int -> String
mapFn a =
    if a == 1 then
        "D.map"

    else if a <= 8 then
        "D.map" ++ String.fromInt a

    else
        "D_.map" ++ String.fromInt a
