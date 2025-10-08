//
//  ResponseMacro.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 07/07/2025.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct ResponseMacro: MemberMacro, ExtensionMacro {

    // MARK: - MemberMacro Implementation

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // Check if this is external usage (with argument) or internal usage (without argument)
        if let arguments = node.arguments?.as(LabeledExprListSyntax.self), !arguments.isEmpty {
            // External usage: @Response(SomeType.self) on HttpRequest struct
            // Let the HTTP method macro handle the typealias generation for proper ordering
            return []
        } else {
            // Internal usage: @Response on nested struct/class inside HttpRequest
            return try handleInternalUsage(node: node, context: context, declaration: declaration)
        }
    }

    // MARK: - ExtensionMacro Implementation

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {

        // Only apply Decodable extension for internal usage (no arguments)
        guard node.arguments?.as(LabeledExprListSyntax.self)?.isEmpty != false else {
            return []
        }

        let typeName = type.trimmedDescription
        return [
            try ExtensionDeclSyntax("extension \(raw: typeName): Decodable {}")
        ]
    }

    // MARK: - Helper Methods

    /// Handles external usage: @Response(SomeType.self) applied to HttpRequest struct
    private static func handleExternalUsage(
        arguments: LabeledExprListSyntax,
        context: some MacroExpansionContext,
        declaration: some DeclGroupSyntax
    ) throws -> [DeclSyntax] {

        // Extract the response type from the first argument
        guard let firstArg = arguments.first else {
            context.diagnose(
                .init(
                    node: declaration,
                    message: MacroExpansionErrorMessage(
                        "@Response requires a type argument when used externally"
                    )
                )
            )
            return []
        }

        let responseType: String

        // Handle different expression types
        if let memberAccess = firstArg.expression.as(MemberAccessExprSyntax.self),
            let base = memberAccess.base
        {
            // Handle SomeType.self
            responseType = base.description.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            // Handle direct type references
            responseType = firstArg.expression.description.trimmingCharacters(
                in: .whitespacesAndNewlines)
        }

        // Determine access modifier based on the declaration
        let accessModifier = determineAccessModifier(from: declaration)

        // Generate the Response typealias
        let typealiasDecl = DeclSyntax(
            stringLiteral: "\(accessModifier)typealias Response = \(responseType)")

        return [typealiasDecl]
    }

    /// Handles internal usage: @Response applied to nested type inside HttpRequest
    private static func handleInternalUsage(
        node: AttributeSyntax,
        context: some MacroExpansionContext,
        declaration: some DeclGroupSyntax
    ) throws -> [DeclSyntax] {

        // Get the name of the nested type
        guard
            declaration.as(StructDeclSyntax.self) != nil
                || declaration.as(ClassDeclSyntax.self) != nil
        else {
            context.diagnose(
                .init(
                    node: declaration,
                    message: MacroExpansionErrorMessage(
                        "@Response can only be applied to struct or class declarations"
                    )
                )
            )
            return []
        }

        // We need to find the parent HttpRequest struct to add the typealias
        // For now, we'll return empty and let the parent struct handle this via findResponseType
        return []
    }

    /// Determines the access modifier based on the declaration modifiers
    private static func determineAccessModifier(from declaration: some DeclGroupSyntax) -> String {
        let isPublic = declaration.modifiers.contains { modifier in
            modifier.name.text == "public"
        }
        let isPrivate = declaration.modifiers.contains { modifier in
            modifier.name.text == "private"
        }
        let isFileprivate = declaration.modifiers.contains { modifier in
            modifier.name.text == "fileprivate"
        }

        if isPublic {
            return "public "
        } else if isFileprivate {
            return "fileprivate "
        } else if isPrivate {
            return "fileprivate "  // Private structs need at least fileprivate for protocol requirements
        } else {
            // For internal or no explicit modifier, don't add any prefix
            return ""
        }
    }
}
