//
//  HttpRequest.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 07/07/2025.
//

import Foundation

/// A protocol that defines the structure for HTTP requests.
///
/// ```swift
/// struct GetBooksRequest: HttpRequest {
///     typealias Response = [Book]
///     typealias Body = EmptyBody
///
///     let path: String = "/books"
///     let method: HttpMethod = .get
/// }
/// ```
///
/// You can also use `@Get`, `@Post`, `@Put`, `@Delete`, or `@Patch` macros to simplify request creation.
///
/// ```swift
/// @Get("/books/:id")
/// @Response([Book].self)
/// struct GetBooksRequest {
///     @Path
///     var id: String
///
///     @Query
///     var page: Int
///
///     @Query
///     var limit: Int
/// }
/// ```
///
/// ## Associated Types
///
/// - `Response`: The type of the response expected from this request, which must conform to `Decodable`
/// - `Body`: The type of the request body, which must conform to `HttpBody`
///
/// ## Default Implementations
///
/// The protocol provides default implementations for:
/// - `body`: Returns an `EmptyBody` instance
/// - `timeout`: Returns 60 seconds
/// - `cachePolicy`: Returns `.reloadIgnoringLocalCacheData`
/// - `headers`: Returns an empty dictionary
public protocol HttpRequest {
    /// The type of the request body, which must conform to `HttpBody`
    associatedtype Body: HttpBody

    /// The type of the response expected from this request.
    ///
    /// This type must conform to `Decodable`.
    associatedtype Response: Decodable

    /// The path component of the URL for this request.
    ///
    /// This should be a relative path that will be appended to the base URL
    /// of the HTTP client. For example: "/users/123" or "/api/books"
    var path: String { get }

    /// The HTTP method to use for this request.
    ///
    /// Common values include `.get`, `.post`, `.put`, `.delete`, etc.
    var method: HttpMethod { get }

    /// The path parameters to include in the request.
    ///
    /// These parameters will be used to replace path placeholders in the URL path.
    var pathParameters: [PathParameter] { get }

    /// The query parameters to include in the request.
    ///
    /// These parameters will be encoded in the URL as query string parameters.
    var queryParameters: [QueryParameter] { get }

    /// The body of the HTTP request.
    ///
    /// This can be any type that conforms to `HttpBody`. For requests that
    /// don't need a body (like GET requests), the default implementation
    /// returns an `EmptyBody` instance.
    var body: Body { get }

    /// The HTTP headers to include with this request.
    ///
    /// Headers are specified as key-value pairs where the value can be `nil`
    /// to indicate that the header should not be included. The default
    /// implementation returns an empty dictionary.
    ///
    /// ## Example
    /// ```swift
    /// let headers: [String: String?] = [
    ///     "Authorization": "Bearer token123",
    ///     "Content-Type": "application/json",
    ///     "Accept": "application/json"
    /// ]
    /// ```
    var headers: [String: String?] { get }

    /// The timeout interval for this request in seconds.
    ///
    /// The default implementation returns 60 seconds. This value determines
    /// how long the network request will wait before timing out.
    var timeout: TimeInterval { get }

    /// The cache policy to use for this request.
    ///
    /// The default implementation returns `.reloadIgnoringLocalCacheData`,
    /// which means the request will always fetch fresh data from the server
    /// and ignore any cached responses.
    var cachePolicy: URLRequest.CachePolicy { get }
}

extension HttpRequest {
    public var queryParameters: [QueryParameter] {
        []
    }

    public var pathParameters: [PathParameter] {
        []
    }

    public var timeout: TimeInterval {
        60
    }

    public var cachePolicy: URLRequest.CachePolicy {
        .reloadIgnoringLocalCacheData
    }

    public var headers: [String: String?] {
        [:]
    }
}
