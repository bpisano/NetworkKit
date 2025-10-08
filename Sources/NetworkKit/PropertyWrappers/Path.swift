//
//  Path.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 07/07/2025.
//

import Foundation

/// A property wrapper that marks a property as a path parameter in an HTTP request.
///
/// Use `@Path` to indicate that a property should be used to replace path parameters
/// in the request URL. Path parameters are denoted by `:parameterName` in the path string
/// and are replaced with the actual values at runtime.
///
/// ## Usage
///
/// ```swift
/// @Get("/users/:id/posts/:postId")
/// struct GetUserRequest: HttpRequest {
///     @Path
///     var id: String
///
///     @Path
///     var postId: String
/// }
///
/// // Usage
/// let request = GetUserRequest(
///   id: "123",
///   postId: "456"
/// )
/// // Results in path: "/users/123/posts/456"
/// ```
///
/// ## Path Parameter Format
///
/// Path parameters in the URL should be prefixed with a colon (`:`):
/// - `:id` - will be replaced with the value of the `id` property
/// - `:userId` - will be replaced with the value of the `userId` property
/// - `:postId` - will be replaced with the value of the `postId` property
///
/// ## Requirements
///
/// - The property must be of type `String`
/// - The property name must match the path parameter name (without the colon)
/// - The property must be marked with `@Path`
@propertyWrapper
public struct Path: Sendable {
    /// The wrapped string value that will replace the path parameter.
    public var wrappedValue: String

    /// Creates a path parameter wrapper with the specified string value.
    ///
    /// - Parameter wrappedValue: The string value that will replace the path parameter
    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }
}
