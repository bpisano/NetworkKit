//
//  RequestPerformer.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 07/07/2025.
//

import Foundation

/// A struct responsible for performing HTTP requests and handling progress updates.
///
/// `RequestPerformer` encapsulates the actual network request execution logic,
/// including progress tracking and data accumulation. It uses `URLSession.shared`
/// to perform requests and provides progress updates through a callback.
///
/// ## Usage
///
/// ```swift
/// let performer = RequestPerformer()
/// let (data, response) = try await performer.perform(
///     urlRequest: request,
///     onProgress: { progress in
///         print("Download progress: \(progress.fractionCompleted)")
///     }
/// )
/// ```
///
/// ## Features
///
/// - **Progress Tracking**: Provides real-time progress updates during downloads
/// - **Data Accumulation**: Automatically accumulates response data
/// - **Async/Await Support**: Modern Swift concurrency support
/// - **Error Handling**: Proper error propagation from URLSession
/// - **Memory Efficient**: Uses streaming data processing for large responses
/// 
struct RequestPerformer: Sendable {
    /// Performs an HTTP request and returns the response data and metadata.
    ///
    /// This method executes the request using `URLSession.shared.bytes(for:)` to
    /// enable progress tracking. It accumulates the response data and provides
    /// progress updates through the optional callback.
    ///
    /// ## Progress Updates
    ///
    /// The `onProgress` closure is called with a `Progress` object that contains:
    /// - `totalUnitCount`: The expected total size of the response
    /// - `completedUnitCount`: The number of bytes received so far
    /// - `fractionCompleted`: The completion percentage (0.0 to 1.0)
    ///
    /// ## Data Handling
    ///
    /// The method automatically accumulates all response data into a single `Data`
    /// object, regardless of the response size. For very large responses, consider
    /// using a custom implementation that processes data in chunks.
    ///
    /// - Parameters:
    ///   - urlRequest: The URLRequest to perform
    ///   - session: The URLSession to use for the request
    ///   - onProgress: Optional closure called with progress updates during the request
    /// - Returns: A tuple containing the response data and URLResponse
    /// - Throws: An error if the request fails or data cannot be processed
    func perform(
        urlRequest: URLRequest,
        with session: URLSession,
        onProgress: ((Progress) -> Void)? = nil
    ) async throws -> (data: Data, response: URLResponse) {
        let (bytes, response) = try await session.bytes(for: urlRequest)
        let length: Int = Int(response.expectedContentLength)
        var data: Data = .init(capacity: length)
        var receivedBytesCount: Int64 = 0
        let progress: Progress = .init(totalUnitCount: Int64(length))

        for try await byte in bytes {
            data.append(byte)
            receivedBytesCount += 1
            progress.completedUnitCount = receivedBytesCount
            onProgress?(progress)
        }

        return (data, response)
    }
}
