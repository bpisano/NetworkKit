# Working with Clients

Learn how to configure and customize HTTP clients for different environments and use cases.

## Overview

In NetworkKit, a ``Client`` represents a server environment with its base URL and configuration. Clients handle request execution, middleware processing, and response handling, while keeping your request definitions environment-agnostic.

## Table of Contents

- [Creating Clients](#creating-clients)
  - [Basic Client](#basic-client)
  - [Multiple Environments](#multiple-environments)
  - [Environment-Based Configuration](#environment-based-configuration)
- [Performing Requests](#performing-requests)
  - [Basic Request Execution](#basic-request-execution)
  - [Response Types](#response-types)
  - [Progress Tracking](#progress-tracking)
  - [Error Handling](#error-handling)
- [Middleware](#middleware)
  - [Authentication Middleware](#authentication-middleware)
  - [Custom Headers Middleware](#custom-headers-middleware)
  - [Conditional Middleware](#conditional-middleware)
- [Interceptors](#interceptors)
  - [Retry Interceptor](#retry-interceptor)
  - [Response Transformation Interceptor](#response-transformation-interceptor)
  - [Error Handling Interceptor](#error-handling-interceptor)
- [Logging](#logging)
  - [Built-in Logging](#built-in-logging)
  - [Custom Logger](#custom-logger)
  - [Conditional Logging](#conditional-logging)

## Creating Clients

### Basic Client

Create a client with just a base URL:

```swift
let client = Client("https://api.example.com")
```

### Multiple Environments

Create different clients for different environments:

```swift
let developmentClient = Client("https://dev-api.example.com")
let stagingClient = Client("https://staging-api.example.com")
let productionClient = Client("https://api.example.com")
```

### Environment-Based Configuration

Use build configurations to automatically select the right client:

```swift
#if DEBUG
let client = Client("https://dev-api.example.com")
#elseif STAGING
let client = Client("https://staging-api.example.com")
#else
let client = Client("https://api.example.com")
#endif
```

## Performing Requests

### Basic Request Execution

```swift
let request = GetUsersRequest()
let response = try await client.perform(request)
let users = try response.decodedData
```

### Response Types

#### Decoded Responses

For requests that return structured data:

```swift
@Get("/users/:id")
@Response(User.self)
struct GetUserRequest {
    @Path var id: String
}

let response: Response<User> = try await client.perform(request)
let user: User = try response.decodedData
```

> The `response.data` contains raw response data, while `response.decodedData` provides the decoded object. This separation allows you to handle decoding errors independently from network errors.

#### Empty Responses

For requests that don't return data:

```swift
@Delete("/users/:id")
struct DeleteUserRequest {
    @Path var id: String
}

try await client.perform(request) // Returns Void
```

#### Raw Data Responses

For custom response handling:

```swift
let response: Response<Data> = try await client.performRaw(request)
let rawData = response.data
```

### Progress Tracking

Track progress for long-running requests:

```swift
let response = try await client.perform(request) { progress in
    progressBar.progress = Float(progress.fractionCompleted)
}
```

### Error handling

With NetworkKit's Response type, error handling follows a two-stage approach. First, handle network-level errors (timeouts, no internet, etc.) when performing the request. Then, check the response status code and handle server errors before attempting to decode the response data.

```swift
// Throws server related errors such as timeout, no internet, etc.
let response = try await client.perform(request)

// At this point, the server returned a response.
// You can then check the status code and handle accordingly.
if response.statusCode == 500 {
    // Decode the error response body if needed
    let error = try response.decodedData(as: APIError.self)
    throw MyAppError.serverError(error)
}

// Throws client related errors such as decoding issues.
let user = try response.decodedData
```

## Middleware

Middleware allows you to modify requests before they're sent. You can use it for authentication, logging, or custom headers. Here are some middleware examples.

### Authentication Middleware

```swift
struct AuthMiddleware: Middleware {
    let token: String
    
    func modify(request: inout URLRequest) async throws {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}

var client = Client("https://api.example.com")
client.middlewares = [AuthMiddleware(token: "your-jwt-token")]
```

### Custom Headers Middleware

```swift
struct HeadersMiddleware: Middleware {
    let headers: [String: String]
    
    func modify(request: inout URLRequest) async throws {
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}

let commonHeaders = [
    "User-Agent": "MyApp/1.0",
    "Accept": "application/json",
    "X-API-Version": "2.0"
]

client.middlewares.append(HeadersMiddleware(headers: commonHeaders))
```

### Conditional Middleware

```swift
struct ConditionalMiddleware: Middleware {
    func modify(request: inout URLRequest) async throws {
        // Only add API key for certain endpoints
        if request.url?.path.hasPrefix("/api/") == true {
            request.setValue("your-api-key", forHTTPHeaderField: "X-API-Key")
        }
    }
}
```

## Interceptors

Interceptors allow you to modify responses after they're received but before they're processed. Here are some interceptor examples.

### Retry Interceptor

```swift
struct RetryInterceptor: Interceptor {
    let maxRetries: Int
    
    func intercept(
        data: Data,
        response: URLResponse,
        client: HttpClient,
        request: some HttpRequest
    ) async throws -> (data: Data, response: URLResponse) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return (data, response)
        }
        
        if httpResponse.statusCode == 429 { // Rate limited
            // Wait and retry
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            // Implement retry logic here
        }
        
        return (data, response)
    }
}

client.interceptors = [RetryInterceptor(maxRetries: 3)]
```

### Response Transformation Interceptor

```swift
struct ResponseTransformInterceptor: Interceptor {
    func intercept(
        data: Data,
        response: URLResponse,
        client: HttpClient,
        request: some HttpRequest
    ) async throws -> (data: Data, response: URLResponse) {
        // Transform response data if needed
        guard let httpResponse = response as? HTTPURLResponse else { return (data, response) }
        guard httpResponse.statusCode == 200 else { return (data, response) }
        let transformedData = transformData(data)
        return (transformedData, response)
    }
    
    private func transformData(_ data: Data) -> Data {
        // Your transformation logic here
        return data
    }
}
```

### Error Handling Interceptor

```swift
struct ErrorInterceptor: Interceptor {
    func intercept(
        data: Data,
        response: URLResponse,
        client: HttpClient,
        request: some HttpRequest
    ) async throws -> (data: Data, response: URLResponse) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return (data, response)
        }
        
        switch httpResponse.statusCode {
        case 401:
            // Handle unauthorized - maybe refresh token
            throw AuthenticationError.unauthorized
        case 403:
            throw AuthenticationError.forbidden
        case 404:
            throw APIError.notFound
        case 500...599:
            throw APIError.serverError(httpResponse.statusCode)
        default:
            return (data, response)
        }
    }
}
```

## Logging

### Built-in Logging

NetworkKit includes a default logger that you can enable:

```swift
var client = Client("https://api.example.com")
client.logger = DefaultClientLogger()
```

### Custom Logger

Create your own logger to integrate with your logging system:

```swift
struct CustomLogger: ClientLogger {
    func logPerform(request: URLRequest) {
        Logger.network.info("🚀 \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
    }
    
    func logResponse(request: URLRequest, response: URLResponse, data: Data) {
        if let httpResponse = response as? HTTPURLResponse {
            let status = httpResponse.statusCode
            let emoji = status < 400 ? "✅" : "❌"
            Logger.network.info("\(emoji) \(status) - \(data.count) bytes")
        }
    }
    
    func logError(request: URLRequest, error: Error) {
        Logger.network.error("💥 Request failed: \(error.localizedDescription)")
    }
}

client.logger = CustomLogger()
```

### Conditional Logging

```swift
struct ConditionalLogger: ClientLogger {
    func logPerform(request: URLRequest) {
        #if DEBUG
        print("🚀 \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
        #endif
    }
    
    func logResponse(request: URLRequest, response: URLResponse, data: Data) {
        #if DEBUG
        if let httpResponse = response as? HTTPURLResponse {
            print("📥 \(httpResponse.statusCode)")
        }
        #endif
    }
}
```
