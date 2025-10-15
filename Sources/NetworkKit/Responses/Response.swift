//
//  Response.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 07/07/2025.
//

import Foundation

/// A wrapper for HTTP response data that provides convenient access to response metadata.
///
/// `Response<T>` encapsulates both the response data and metadata (status code, headers, etc.)
/// in a single, easy-to-use structure. It automatically extracts HTTP-specific information
/// from the underlying `URLResponse`.
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
/// print("Status: \(response.statusCode)")
/// print("User: \(response.data.name)")
/// print("Content-Type: \(response.headers["Content-Type"] ?? "unknown")")
/// ```
///
/// ## Properties
///
/// - `data`: The decoded response data of type `T`
/// - `urlResponse`: The original `URLResponse` object
/// - `statusCode`: The HTTP status code (200 for non-HTTP responses)
/// - `headers`: A dictionary of response headers
///
/// - Note: For non-HTTP responses (like file URLs), the status code defaults to 200
///   and headers defaults to an empty dictionary.
public struct Response<T> {
    /// The raw response data.
    ///
    /// This contains the complete response body as received from the server.
    public let data: Data

    /// The original URLResponse object.
    ///
    /// This provides access to the complete response information, including
    /// any properties not exposed by the convenience properties.
    public let urlResponse: URLResponse

    /// The HTTP status code of the response.
    ///
    /// For HTTP responses, this contains the actual status code from the server.
    /// For non-HTTP responses (like file URLs), this defaults to 200.
    public let statusCode: Int

    /// A dictionary of response headers.
    ///
    /// This contains all headers returned by the server, with header names as keys
    /// and header values as string values. For non-HTTP responses, this is empty.
    public let headers: [String: String]

    private let decoder: JSONDecoder

    /// Creates a response with the specified data and URLResponse.
    ///
    /// This initializer automatically extracts HTTP-specific information from the
    /// URLResponse and provides convenient access to status codes and headers.
    ///
    /// - Parameters:
    ///   - data: The decoded response data
    ///   - response: The original URLResponse object
    public init(data: Data, response: URLResponse, decoder: JSONDecoder) {
        self.data = data
        self.urlResponse = response
        self.decoder = decoder
        if let response = response as? HTTPURLResponse {
            self.statusCode = response.statusCode
            self.headers = response.allHeaderFields.reduce(into: [String: String]()) {
                $0[$1.key as? String ?? ""] = $1.value as? String ?? ""
            }
        } else {
            self.statusCode = 200
            self.headers = [:]
        }
    }

    /// Decodes the response data to a specified type.
    ///
    /// This method uses the client JSONDecoder to decode the raw response data.
    /// Use this method if the response returned an error and you still want to
    /// attempt to decode the data.
    /// - Parameter type: The type to decode the data to. Must conform to Decodable.
    /// - Returns: The decoded object of the specified type.
    func decodedData<D: Decodable>(as type: D.Type) throws -> D {
        try decoder.decode(D.self, from: data)
    }
}

extension Response where T == Void {
    /// Creates a response with no data, only response metadata.
    ///
    /// This initializer is useful for requests where you only care about the
    /// response status and headers, not the body content.
    ///
    /// - Parameter response: The original URLResponse object
    public init(response: URLResponse) {
        self.init(data: .init(), response: response, decoder: .init())
    }
}

extension Response where T: Decodable {
    /// The decoded response data of type `T`, if decoding was successful.
    ///
    /// This property attempts to decode the raw `data` using the provided `decoder`.
    public var decodedData: T {
        get throws {
            try decoder.decode(T.self, from: data)
        }
    }
}

/// Makes Response conform to Sendable when its data type is Sendable.
///
/// This allows Response objects to be safely passed across concurrency boundaries
/// when the contained data type is thread-safe.
extension Response: Sendable where T: Sendable {}

/// A type alias for responses that contain no data.
///
/// `EmptyResponse` is equivalent to `Response<Void>` and is used for requests
/// where you only need the response metadata (status code, headers) but not
/// the response body.
///
/// ## Usage
///
/// ```swift
/// let response: EmptyResponse = try await client.perform(DeleteUserRequest(id: "123"))
/// if response.statusCode == 204 {
///     print("User deleted successfully")
/// }
/// ```
public typealias EmptyResponse = Response<Void>
