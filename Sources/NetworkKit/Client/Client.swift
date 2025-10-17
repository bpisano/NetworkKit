//
//  Client.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 07/07/2025.
//

import Foundation

/// A concrete implementation of `HttpClient` that provides network request functionality.
///
/// `Client` is the main entry point for making HTTP requests in NetworkKit. It encapsulates
/// all the configuration needed for network communication, including the base URL, encoders,
/// decoders, logging, middleware, and interceptors.
///
/// ## Usage
///
/// ```swift
/// // Create a client with a URL
/// let client = Client(URL(string: "https://api.example.com")!)
///
/// // Create a client with a string literal
/// let client = Client("https://api.example.com")
///
/// // Create a client with components
/// let client = Client(
///     scheme: "https",
///     host: "api.example.com",
///     port: 443,
///     path: "/v1"
/// )
///
/// // Perform a request
/// let response = try await client.perform(GetUserRequest(id: "123"))
/// ```
///
/// ## Configuration
///
/// You can customize the client's behavior by modifying its properties:
///
/// ```swift
/// var client = Client("https://api.example.com")
/// client.encoder.dateEncodingStrategy = .iso8601
/// client.decoder.dateDecodingStrategy = .iso8601
/// client.logger = CustomLogger()
/// client.middlewares = [AuthenticationMiddleware()]
/// client.interceptors = [RetryInterceptor()]
/// ```
public struct Client: HttpClient, Sendable {
    /// The base URL for all requests made by this client.
    ///
    /// This URL is used as the foundation for all requests. Individual request paths
    /// are appended to this base URL to form the complete request URL.
    public let baseUrl: URL

    /// The JSON encoder used for encoding request bodies.
    ///
    /// This encoder is used when request bodies need to be serialized to JSON.
    /// You can customize encoding behavior by modifying this property.
    public var encoder: JSONEncoder = .init()

    /// The JSON decoder used for decoding response bodies.
    ///
    /// This decoder is used when response bodies need to be deserialized from JSON.
    /// You can customize decoding behavior by modifying this property.
    public var decoder: JSONDecoder = .init()

    /// The URL session used for making network requests.
    ///
    /// By default, this is set to `URLSession.shared`. You can provide a custom
    /// session if you need specific configuration (e.g., custom timeout, caching, etc.).
    public var session: URLSession = .shared

    /// The logger used for logging request and response information.
    ///
    /// By default, this is set to `ClientLogger.default`, which provides
    /// comprehensive logging using the system logger. Set to `nil` to disable logging.
    public var logger: ClientLogger? = .default

    /// An array of middleware that can modify requests before they are sent.
    ///
    /// Middleware is executed in the order they appear in this array. Each middleware
    /// can modify the request (e.g., add headers, modify the body, etc.).
    public var middlewares: [Middleware] = []

    /// An array of interceptors that can modify responses after they are received.
    ///
    /// Interceptors are executed in the order they appear in this array. Each interceptor
    /// can modify the response data or response object.
    public var interceptors: [Interceptor] = []

    /// Creates a client with the specified base URL.
    ///
    /// - Parameter baseUrl: The base URL for all requests made by this client
    public init(_ baseUrl: URL) {
        self.baseUrl = baseUrl
    }

    /// Creates a client with the specified URL string.
    ///
    /// This initializer creates a URL from the provided string and initializes the client.
    /// The string must be a valid URL format.
    ///
    /// - Parameter string: A static string representing the base URL
    public init(_ string: StaticString) {
        self.baseUrl = URL(string: "\(string)")!
    }

    /// Creates a client with URL components.
    ///
    /// This initializer allows you to specify the individual components of the URL.
    /// If the URL cannot be constructed from the provided components, the initializer
    /// returns `nil`.
    ///
    /// - Parameters:
    ///   - scheme: The URL scheme (e.g., "https", "http")
    ///   - host: The host name or IP address
    ///   - port: The port number (optional, defaults to the standard port for the scheme)
    ///   - path: The path component (optional, defaults to empty string)
    /// - Returns: A configured client, or `nil` if the URL cannot be constructed
    public init?(
        scheme: String = "https",
        host: String,
        port: Int? = nil,
        path: String = ""
    ) {
        guard let url = URL(string: "\(scheme)://\(host)\(port.map { ":\($0)" } ?? "")\(path)")
        else {
            return nil
        }
        self.baseUrl = url
    }
}
