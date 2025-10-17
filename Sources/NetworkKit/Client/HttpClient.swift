//
//  HttpClient.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 07/07/2025.
//

import Foundation

/// A protocol that defines the interface for HTTP clients in NetworkKit.
///
/// `HttpClient` provides the core functionality for making HTTP requests and processing
/// responses. It defines the configuration properties and methods needed for network
/// communication.
///
/// ## Usage
///
/// ```swift
/// let client: HttpClient = Client("https://api.example.com")
/// let response = try await client.perform(GetUserRequest(id: "123"))
/// ```
///
/// ## Configuration Properties
///
/// - `baseUrl`: The base URL for all requests
/// - `encoder`: JSON encoder for request bodies
/// - `decoder`: JSON decoder for response bodies
/// - `logger`: Logger for request/response logging
/// - `middlewares`: Array of request middleware
/// - `interceptors`: Array of response interceptors
public protocol HttpClient {
    /// The base URL for all requests made by this client.
    var baseUrl: URL { get }

    /// The JSON encoder used for encoding request bodies.
    var encoder: JSONEncoder { get set }

    /// The JSON decoder used for decoding response bodies.
    var decoder: JSONDecoder { get set }

    /// The URL session used to perform network requests.
    var session: URLSession { get set }

    /// The logger used for logging request and response information.
    var logger: ClientLogger? { get set }

    /// An array of middleware that can modify requests before they are sent.
    var middlewares: [Middleware] { get set }

    /// An array of interceptors that can modify responses after they are received.
    var interceptors: [Interceptor] { get set }
}

extension HttpClient {
    /// Default JSON encoder implementation.
    ///
    /// Returns a new `JSONEncoder` instance with default configuration.
    public var encoder: JSONEncoder { .init() }

    /// Default JSON decoder implementation.
    ///
    /// Returns a new `JSONDecoder` instance with default configuration.
    public var decoder: JSONDecoder { .init() }

    /// Default URL session implementation.
    ///
    /// Returns the shared URL session instance.
    public var session: URLSession { .shared }

    /// Default logger implementation.
    ///
    /// Returns the default client logger that provides comprehensive logging.
    public var logger: ClientLogger? { .default }

    /// Default middleware array implementation.
    ///
    /// Returns an empty array, meaning no middleware will be applied by default.
    public var middlewares: [Middleware] { [] }

    /// Default interceptor array implementation.
    ///
    /// Returns an empty array, meaning no interceptors will be applied by default.
    public var interceptors: [Interceptor] { [] }

    /// Performs an HTTP request and decodes the response to the specified type.
    ///
    /// This method sends the request, processes any middleware and interceptors,
    /// and automatically decodes the response body to the expected response type defined by the request.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// struct User: Codable {
    ///     let id: String
    ///     let name: String
    /// }
    ///
    /// let response = try await client.perform(GetUserRequest(id: "123"))
    /// let user = response.data  // User type
    /// ```
    ///
    /// - Parameters:
    ///   - request: The HTTP request to perform. The request type must conform to `HttpRequest` and specify its expected response type.
    ///   - onProgress: Optional closure called with progress updates during the request.
    /// - Returns: A `Response<Request.Response>` containing the decoded data and response metadata.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func perform<Request: HttpRequest>(
        _ request: Request,
        onProgress: ((Progress) -> Void)? = nil
    ) async throws -> Response<Request.Response> {
        let (data, response) = try await send(request, onProgress: onProgress)
        return .init(data: data, response: response, decoder: decoder)
    }

    /// Performs an HTTP request and returns the raw response data.
    ///
    /// This method is useful when you need to handle the response data manually
    /// or when the response format is not known at compile time.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let response = try await client.performRaw(GetDataRequest())
    /// let data = response.data  // Raw Data
    /// ```
    ///
    /// - Parameters:
    ///   - request: The HTTP request to perform
    ///   - onProgress: Optional closure called with progress updates during the request
    /// - Returns: A `Response<Data>` containing the raw response data and metadata
    /// - Throws: An error if the request fails
    public func performRaw<Request: HttpRequest>(
        _ request: Request,
        onProgress: ((Progress) -> Void)? = nil
    ) async throws -> Response<Data> {
        let (data, response) = try await send(request, onProgress: onProgress)
        return .init(data: data, response: response, decoder: decoder)
    }

    /// Internal method that handles the core request execution logic.
    ///
    /// This method orchestrates the request lifecycle:
    /// 1. Builds the URLRequest from the HttpRequest
    /// 2. Applies middleware modifications
    /// 3. Logs the outgoing request
    /// 4. Performs the actual network request
    /// 5. Applies interceptor modifications
    /// 6. Logs the response
    ///
    /// - Parameters:
    ///   - request: The HTTP request to perform
    ///   - onProgress: Optional closure called with progress updates during the request
    /// - Returns: A tuple containing the response data and URLResponse
    /// - Throws: An error if any step in the request lifecycle fails
    @discardableResult
    private func send<Request: HttpRequest>(
        _ request: Request,
        onProgress: ((Progress) -> Void)? = nil
    ) async throws -> (data: Data, response: URLResponse) {
        // Build the request
        let requestBuilder: RequestBuilder = .init()
        var urlRequest: URLRequest = try requestBuilder.build(client: self, request: request)

        // Modify the request with the middlewares
        for middleware in middlewares {
            try await middleware.modify(request: &urlRequest)
        }

        logger?.logPerform(request: urlRequest)

        // Perform the request
        let requestPerformer: RequestPerformer = .init()
        var (data, response) = try await requestPerformer.perform(
            urlRequest: urlRequest,
            with: session,
            onProgress: onProgress
        )

        // Intercept the response
        for interceptor in interceptors {
            (data, response) = try await interceptor.intercept(
                data: data,
                response: response,
                client: self,
                request: request
            )
        }

        logger?.logResponse(request: urlRequest, response: response, data: data)

        return (data, response)
    }
}
