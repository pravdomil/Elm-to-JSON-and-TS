module Generators.Encode exposing (fileToElmEncodeModule)

import Elm.Syntax.Declaration exposing (Declaration(..))
import Elm.Syntax.Documentation exposing (Documentation)
import Elm.Syntax.File exposing (File)
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node(..))
import Elm.Syntax.Type exposing (Type, ValueConstructor)
import Elm.Syntax.TypeAlias exposing (TypeAlias)
import Elm.Syntax.TypeAnnotation exposing (RecordDefinition, RecordField, TypeAnnotation(..))
import String exposing (join)
import Utils exposing (Argument, argumentToString, encodeJsonString, fileToModuleName, letterByInt, moduleImports, moduleNameToString, normalizeRecordFieldName)


{-| To get Elm module for encoding types in file.
-}
fileToElmEncodeModule : File -> String
fileToElmEncodeModule a =
    [ "module Generated." ++ fileToModuleName a ++ "Encode exposing (..)"
    , ""
    , "import " ++ fileToModuleName a ++ " as A"
    , "import Generated.Basics.BasicsEncode exposing (..)"
    , "import Json.Encode exposing (..)"
    , a.imports
        |> moduleImports
            (\v vv ->
                "import Generated." ++ moduleNameToString v ++ "Encode exposing (" ++ (vv |> List.map encoderName |> join ", ") ++ ")"
            )
        |> join "\n"
    , ""
    , a.declarations |> List.filterMap declarationToEncoder |> join "\n\n"
    , ""
    ]
        |> join "\n"


{-| To maybe get encoder from declaration.
-}
declarationToEncoder : Node Declaration -> Maybe String
declarationToEncoder a =
    case a |> Node.value of
        AliasDeclaration b ->
            Just <| typeAliasToEncoder b

        CustomTypeDeclaration b ->
            Just <| fromCustomType b

        _ ->
            Nothing


{-| To get encoder from type alias.
-}
typeAliasToEncoder : TypeAlias -> String
typeAliasToEncoder a =
    fromType a ++ " " ++ fromTypeAnnotation (Argument "" 0 "" False) a.typeAnnotation


fromCustomType : Type -> String
fromCustomType a =
    let
        cases =
            join "\n    " <| List.map fromCustomTypeConstructor a.constructors
    in
    fromType a ++ "\n  case a of\n    " ++ cases


fromType : { a | documentation : Maybe (Node Documentation), name : Node String, generics : List (Node String) } -> String
fromType a =
    let
        name =
            Node.value a.name

        signature =
            case a.generics of
                [] ->
                    encoderName name ++ " : A." ++ name ++ " -> Value\n"

                _ ->
                    ""

        generics =
            case a.generics of
                [] ->
                    ""

                _ ->
                    (++) " " <| join " " <| List.map (\(Node _ v) -> "t_" ++ v) a.generics

        declaration =
            encoderName name ++ generics ++ " a ="
    in
    signature ++ declaration


fromCustomTypeConstructor : Node ValueConstructor -> String
fromCustomTypeConstructor (Node _ a) =
    let
        name =
            Node.value a.name

        params =
            case a.arguments of
                [] ->
                    ""

                _ ->
                    " " ++ (join " " <| List.indexedMap (\b _ -> letterByInt (b + 1)) a.arguments)

        map i b =
            fromTypeAnnotation (Argument "" (1 + i) "" False) b

        encoder : String
        encoder =
            String.join ", " <| (::) ("string " ++ encodeJsonString name) <| List.indexedMap map a.arguments
    in
    "A." ++ name ++ params ++ " -> list identity [ " ++ encoder ++ " ]"


fromTypeAnnotation : Argument -> Node TypeAnnotation -> String
fromTypeAnnotation argument (Node _ a) =
    let
        result =
            case a of
                GenericType b ->
                    "t_" ++ b ++ argumentToString argument

                Typed b c ->
                    fromTyped argument b c

                Unit ->
                    "(\\_ -> list identity [])" ++ argumentToString argument

                Tupled b ->
                    fromTuple argument b

                Record b ->
                    fromRecord argument b

                GenericRecord _ (Node _ b) ->
                    fromRecord argument b

                FunctionTypeAnnotation _ _ ->
                    "Debug.todo \"I don't know how to encode function.\""
    in
    "(" ++ result ++ ")"


fromTyped : Argument -> Node ( ModuleName, String ) -> List (Node TypeAnnotation) -> String
fromTyped argument (Node _ ( name, str )) nodes =
    let
        generics =
            case nodes of
                [] ->
                    ""

                _ ->
                    (++) " " <| join " " <| List.map (fromTypeAnnotation { argument | disabled = True }) nodes

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

                "Set" ->
                    "set"

                "Encode.Value" ->
                    "identity"

                "Decode.Value" ->
                    "identity"

                _ ->
                    name ++ [ encoderName str ] |> join "."
    in
    fn ++ generics ++ argumentToString argument


fromTuple : Argument -> List (Node TypeAnnotation) -> String
fromTuple argument a =
    let
        tupleArgument i =
            Argument ("t" ++ argument.prefix) (i + argument.letter + 1) "" False

        arguments =
            join ", " <| List.indexedMap (\i _ -> tupleArgument i |> argumentToString) a

        map i b =
            fromTypeAnnotation (tupleArgument i) b
    in
    "(\\( " ++ arguments ++ " ) -> list identity [ " ++ (join ", " <| List.indexedMap map a) ++ " ])" ++ argumentToString argument


fromRecord : Argument -> RecordDefinition -> String
fromRecord argument a =
    "object [ " ++ (join ", " <| List.map (fromRecordField argument) a) ++ " ]"


fromRecordField : Argument -> Node RecordField -> String
fromRecordField argument (Node _ ( Node _ a, b )) =
    "( " ++ encodeJsonString (normalizeRecordFieldName a) ++ ", " ++ fromTypeAnnotation { argument | suffix = "." ++ a } b ++ " )"


encoderName : String -> String
encoderName a =
    "encode" ++ a
