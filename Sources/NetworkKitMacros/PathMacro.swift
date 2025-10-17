import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct PathMacro: PeerMacro, AccessorMacro, MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first,
            let pattern = binding.pattern.as(IdentifierPatternSyntax.self)
        else {
            context.diagnose(
                .init(
                    node: declaration,
                    message: MacroExpansionErrorMessage(
                        "@Path can only be applied to stored properties.")
                ))
            return []
        }

        let identifier: String = pattern.identifier.text
        let computedName: String =
            "_path" + identifier.prefix(1).uppercased() + identifier.dropFirst()

        // Extract argument if present
        let key: String
        if let arguments = node.arguments?.as(LabeledExprListSyntax.self),
            let firstArg = arguments.first,
            let literal = firstArg.expression.as(StringLiteralExprSyntax.self),
            let firstSegment = literal.segments.first?.as(StringSegmentSyntax.self)
        {
            key = firstSegment.content.text
        } else {
            key = identifier
        }

        let property: DeclSyntax = """
            var \(raw: computedName): PathParameter {
                PathParameter(key: "\(raw: key)", value: \(raw: identifier))
            }
            """

        return [property]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        return []
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        // If no explicit type, insert ": String"
        guard let varDecl = member.as(VariableDeclSyntax.self),
            varDecl.bindings.first?.typeAnnotation == nil
        else {
            return []
        }

        return [AttributeSyntax(stringLiteral: ": String")]
    }
}
