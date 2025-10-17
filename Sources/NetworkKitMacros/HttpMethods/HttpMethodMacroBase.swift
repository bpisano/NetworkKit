//
//  HttpMethodMacroBase.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 07/07/2025.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// Protocol that defines the requirements for HTTP method macros
protocol HttpMethodMacro: MemberMacro, ExtensionMacro {
    /// The HTTP method name (e.g., "get", "post", "delete")
    static var httpMethodName: String { get }

    /// The capitalized macro name for error messages (e.g., "Get", "Post", "Delete")
    static var macroName: String { get }
}

/// Shared implementation for all HTTP method macros
enum HttpMethodMacroBase {

    // MARK: - MemberMacro Implementation

    static func expansion<T: HttpMethodMacro>(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext,
        for macroType: T.Type
    ) throws -> [DeclSyntax] {

        // Extract the path from the macro
        guard
            let path = extractPath(
                from: node,
                context: context,
                declaration: declaration,
                macroName: macroType.macroName
            )
        else {
            return []
        }

        // Determine access modifier based on the declaration
        let accessModifier = determineAccessModifier(from: declaration)

        // Find all @Query-annotated properties
        let queryIdentifiers = findQueryProperties(in: declaration)

        // Find all @Path-annotated properties
        let pathIdentifiers = findPathProperties(in: declaration)

        // Find the @Body struct
        let bodyType = findBodyType(in: declaration)

        // Check if there's already a body property defined
        let hasExistingBody = hasExistingBodyProperty(in: declaration)

        // Find @Response type (either external or internal)
        let responseType = findResponseType(in: declaration)

        // Check if @Response macro is present (either external or internal)
        let hasResponseMacro = hasResponseMacroAttribute(in: declaration)

        // Check if external @Response macro is present
        let hasExternalResponseMacro = hasExternalResponseMacroAttribute(in: declaration)

        // Generate the required declarations
        return generateDeclarations(
            path: path,
            responseType: responseType,
            accessModifier: accessModifier,
            method: macroType.httpMethodName,
            queryIdentifiers: queryIdentifiers,
            pathIdentifiers: pathIdentifiers,
            bodyType: bodyType,
            hasExistingBody: hasExistingBody,
            hasResponseMacro: hasResponseMacro,
            hasExternalResponseMacro: hasExternalResponseMacro,
            declaration: declaration
        )
    }

    // MARK: - ExtensionMacro Implementation

    static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let extensionDecl = try ExtensionDeclSyntax("extension \(type.trimmed): HttpRequest {}")
        return [extensionDecl]
    }

    // MARK: - Helper Methods

    /// Extracts the path from the macro attribute (now only expects path, no 'of:' parameter)
    private static func extractPath(
        from node: AttributeSyntax,
        context: some MacroExpansionContext,
        declaration: some DeclGroupSyntax,
        macroName: String
    ) -> String? {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            context.diagnose(
                .init(
                    node: declaration,
                    message: MacroExpansionErrorMessage(
                        "@\(macroName) requires a string literal path argument")
                )
            )
            return nil
        }

        // Extract path (first and only argument)
        guard let firstArg = arguments.first,
            let pathExpr = firstArg.expression.as(StringLiteralExprSyntax.self),
            let path = pathExpr.segments.first?.description.trimmingCharacters(
                in: .init(charactersIn: "\""))
        else {
            context.diagnose(
                .init(
                    node: declaration,
                    message: MacroExpansionErrorMessage(
                        "@\(macroName) requires a string literal path argument")
                )
            )
            return nil
        }

        return path
    }

    /// Finds the response type from @Response macro (either external or internal usage)
    private static func findResponseType(in declaration: some DeclGroupSyntax) -> String? {
        // First, check for external @Response macro on the struct itself
        if let responseType = findExternalResponseMacro(in: declaration) {
            return responseType
        }

        // Then, check for internal @Response macro on nested types
        if let responseType = findInternalResponseMacro(in: declaration) {
            return responseType
        }

        return nil
    }

    /// Finds external @Response macro applied to the HttpRequest struct
    private static func findExternalResponseMacro(in declaration: some DeclGroupSyntax) -> String? {
        for attr in declaration.attributes {
            guard let attribute = attr.as(AttributeSyntax.self),
                attribute.attributeName.trimmed.description == "Response",
                let arguments = attribute.arguments?.as(LabeledExprListSyntax.self),
                let firstArg = arguments.first
            else { continue }

            // Handle different expression types
            if let memberAccess = firstArg.expression.as(MemberAccessExprSyntax.self),
                let base = memberAccess.base
            {
                // Handle SomeType.self
                return base.description.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                // Handle direct type references
                return firstArg.expression.description.trimmingCharacters(
                    in: .whitespacesAndNewlines)
            }
        }
        return nil
    }

    /// Finds internal @Response macro on nested types inside HttpRequest
    private static func findInternalResponseMacro(in declaration: some DeclGroupSyntax) -> String? {
        for member in declaration.memberBlock.members {
            let nestedDecl: (any DeclGroupSyntax)?
            let typeName: String

            if let structDecl = member.decl.as(StructDeclSyntax.self) {
                nestedDecl = structDecl
                typeName = structDecl.name.text
            } else if let classDecl = member.decl.as(ClassDeclSyntax.self) {
                nestedDecl = classDecl
                typeName = classDecl.name.text
            } else {
                continue
            }

            guard let decl = nestedDecl else { continue }

            for attr in decl.attributes {
                guard let attribute = attr.as(AttributeSyntax.self),
                    attribute.attributeName.trimmed.description == "Response"
                else { continue }

                // Check if this is internal usage (no arguments)
                if attribute.arguments?.as(LabeledExprListSyntax.self)?.isEmpty != false {
                    return typeName
                }
            }
        }
        return nil
    }

    /// Checks if external @Response macro is present on the struct itself
    private static func hasExternalResponseMacroAttribute(in declaration: some DeclGroupSyntax)
        -> Bool
    {
        for attr in declaration.attributes {
            guard let attribute = attr.as(AttributeSyntax.self),
                attribute.attributeName.trimmed.description == "Response",
                let arguments = attribute.arguments?.as(LabeledExprListSyntax.self),
                !arguments.isEmpty
            else { continue }
            return true
        }
        return false
    }

    /// Checks if @Response macro is present (either external or internal)
    private static func hasResponseMacroAttribute(in declaration: some DeclGroupSyntax) -> Bool {
        // Check for external @Response macro on the struct itself
        for attr in declaration.attributes {
            guard let attribute = attr.as(AttributeSyntax.self),
                attribute.attributeName.trimmed.description == "Response"
            else { continue }
            return true
        }

        // Check for internal @Response macro on nested types
        for member in declaration.memberBlock.members {
            let nestedDecl: (any DeclGroupSyntax)?

            if let structDecl = member.decl.as(StructDeclSyntax.self) {
                nestedDecl = structDecl
            } else if let classDecl = member.decl.as(ClassDeclSyntax.self) {
                nestedDecl = classDecl
            } else {
                continue
            }

            guard let decl = nestedDecl else { continue }

            for attr in decl.attributes {
                guard let attribute = attr.as(AttributeSyntax.self),
                    attribute.attributeName.trimmed.description == "Response"
                else { continue }
                return true
            }
        }

        return false
    }

    /// Determines the access modifier based on the declaration modifiers
    private static func determineAccessModifier(from declaration: some DeclGroupSyntax) -> String {
        let isPublic = declaration.modifiers.contains { modifier in
            modifier.name.text == "public"
        }
        return isPublic ? "public " : ""
    }

    /// Finds all properties annotated with @Query in the declaration
    private static func findQueryProperties(in declaration: some DeclGroupSyntax) -> [String] {
        var queryIdentifiers: [String] = []

        for member in declaration.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                let binding = varDecl.bindings.first,
                let pattern = binding.pattern.as(IdentifierPatternSyntax.self)
            else { continue }

            // Check if this property has a @Query attribute
            if hasQueryAttribute(varDecl) {
                queryIdentifiers.append(pattern.identifier.text)
            }
        }

        return queryIdentifiers
    }

    /// Finds all properties annotated with @Path in the declaration
    private static func findPathProperties(in declaration: some DeclGroupSyntax) -> [String] {
        var pathIdentifiers: [String] = []

        for member in declaration.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                let binding = varDecl.bindings.first,
                let pattern = binding.pattern.as(IdentifierPatternSyntax.self)
            else { continue }

            // Check if this property has a @Path attribute
            if hasPathAttribute(varDecl) {
                pathIdentifiers.append(pattern.identifier.text)
            }
        }

        return pathIdentifiers
    }

    /// Checks if a variable declaration has a @Query attribute
    private static func hasQueryAttribute(_ varDecl: VariableDeclSyntax) -> Bool {
        for attr in varDecl.attributes {
            guard let attribute = attr.as(AttributeSyntax.self) else { continue }

            let attributeName = attribute.attributeName.description.trimmingCharacters(
                in: .whitespacesAndNewlines)
            if attributeName == "Query" {
                return true
            }
        }
        return false
    }

    /// Checks if a variable declaration has a @Path attribute
    private static func hasPathAttribute(_ varDecl: VariableDeclSyntax) -> Bool {
        for attr in varDecl.attributes {
            guard let attribute = attr.as(AttributeSyntax.self) else { continue }

            let attributeName = attribute.attributeName.description.trimmingCharacters(
                in: .whitespacesAndNewlines)
            if attributeName == "Path" {
                return true
            }
        }
        return false
    }

    /// Finds the name of the nested type annotated with @Body
    private static func findBodyType(in declaration: some DeclGroupSyntax) -> String? {
        for member in declaration.memberBlock.members {
            guard let structDecl = member.decl.as(StructDeclSyntax.self) else { continue }

            for attr in structDecl.attributes {
                guard let attribute = attr.as(AttributeSyntax.self),
                    attribute.attributeName.trimmed.description == "Body"
                else { continue }

                return structDecl.name.text
            }
        }

        return nil
    }

    /// Checks if the struct already has a body property defined
    private static func hasExistingBodyProperty(in declaration: some DeclGroupSyntax) -> Bool {
        for member in declaration.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                let binding = varDecl.bindings.first,
                let pattern = binding.pattern.as(IdentifierPatternSyntax.self)
            else { continue }

            if pattern.identifier.text == "body" {
                return true
            }
        }
        return false
    }

    /// Generates all required declarations for the HTTP request
    private static func generateDeclarations(
        path: String,
        responseType: String?,
        accessModifier: String,
        method: String,
        queryIdentifiers: [String],
        pathIdentifiers: [String],
        bodyType: String?,
        hasExistingBody: Bool,
        hasResponseMacro: Bool,
        hasExternalResponseMacro: Bool,
        declaration: some DeclGroupSyntax
    ) -> [DeclSyntax] {
        var declarations: [DeclSyntax] = []

        // Add response type alias based on the scenario:
        // 1. If external @Response macro exists, extract the type and generate typealias
        // 2. If internal @Response macro exists, use the internal response type
        // 3. Otherwise, default to Empty

        if hasExternalResponseMacro {
            // Extract type from external @Response macro
            if let externalResponseType = findExternalResponseMacro(in: declaration) {
                let typealiasDecl = DeclSyntax(
                    stringLiteral: "\(accessModifier)typealias Response = \(externalResponseType)")
                declarations.append(typealiasDecl)
            }
        } else if let responseType = responseType {
            // Internal @Response macro case - use the internal type
            let typealiasDecl = DeclSyntax(
                stringLiteral: "\(accessModifier)typealias Response = \(responseType)")
            declarations.append(typealiasDecl)
        } else {
            // No @Response macro case - default to Empty
            let typealiasDecl = DeclSyntax(
                stringLiteral: "\(accessModifier)typealias Response = Empty")
            declarations.append(typealiasDecl)
        }

        let pathDecl = DeclSyntax(stringLiteral: "\(accessModifier)let path: String = \"\(path)\"")
        let methodDecl = DeclSyntax(
            stringLiteral: "\(accessModifier)let method: HttpMethod = .\(method)")
        let queryParametersDecl = generateQueryParametersDeclaration(
            accessModifier: accessModifier,
            queryIdentifiers: queryIdentifiers
        )
        let pathParametersDecl = generatePathParametersDeclaration(
            accessModifier: accessModifier,
            pathIdentifiers: pathIdentifiers
        )

        declarations.append(contentsOf: [
            pathDecl, methodDecl, queryParametersDecl, pathParametersDecl,
        ])

        // Add body property if there's a body type
        if let bodyType = bodyType {
            let bodyDecl = DeclSyntax(stringLiteral: "\(accessModifier)let body: \(bodyType)")
            declarations.append(bodyDecl)
        } else if !hasExistingBody {
            // Add default empty body if no body type is specified and no existing body property
            let emptyBodyDecl = DeclSyntax(stringLiteral: "\(accessModifier)let body = EmptyBody()")
            declarations.append(emptyBodyDecl)
        }

        return declarations
    }

    /// Generates the queryParameters computed property declaration
    private static func generateQueryParametersDeclaration(
        accessModifier: String,
        queryIdentifiers: [String]
    ) -> DeclSyntax {
        let queryParamLines: [String] = queryIdentifiers.map { identifier in
            "_query\(identifier.prefix(1).uppercased() + identifier.dropFirst())"
        }

        return """
            \(raw: accessModifier)var queryParameters: [QueryParameter] {
                [
                    \(raw: queryParamLines.joined(separator: ",\n"))
                ]
            }
            """
    }

    /// Generates the pathParameters computed property declaration
    private static func generatePathParametersDeclaration(
        accessModifier: String,
        pathIdentifiers: [String]
    ) -> DeclSyntax {
        let pathParamLines: [String] = pathIdentifiers.map { identifier in
            "_path\(identifier.prefix(1).uppercased() + identifier.dropFirst())"
        }

        return """
            \(raw: accessModifier)var pathParameters: [PathParameter] {
                [
                    \(raw: pathParamLines.joined(separator: ",\n"))
                ]
            }
            """
    }
}
