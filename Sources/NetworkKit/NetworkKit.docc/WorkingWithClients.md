# Working with Clients

Learn how to configure and customize HTTP clients for different environments and use cases.

## Overview

In NetworkKit, a ``Client`` represents a server environment with its base URL and configuration. Clients handle request execution, middleware processing, and response handling, while keeping your request definitions environment-agnostic.

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
let request = GetUsersRequest(page: 1)
let response = try await client.perform(request)
let users = response.data
```

### Different Response Types

#### Decoded Responses

For requests that return structured data:

```swift
@Get("/users/:id")
@Response(User.self)
struct GetUserRequest {
    @Path var id: String
}

let response: Response<User> = try await client.perform(request)
let user = response.data
```

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
    DispatchQueue.main.async {
        progressBar.progress = Float(progress.fractionCompleted)
    }
}
```

## Middleware

Middleware allows you to modify requests before they're sent. This is perfect for adding authentication, logging, or custom headers.

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

Interceptors allow you to modify responses after they're received but before they're processed.

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
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 200,
           let transformedData = transformData(data) {
            return (transformedData, response)
        }
        
        return (data, response)
    }
    
    private func transformData(_ data: Data) -> Data? {
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

## Error Handling

### Network Errors

```swift
do {
    let response = try await client.perform(request)
    // Handle success
} catch let error as HTTPError {
    switch error.statusCode {
    case 400:
        // Bad request
        break
    case 401:
        // Unauthorized
        break
    case 404:
        // Not found
        break
    case 500...599:
        // Server error
        break
    default:
        // Other HTTP error
        break
    }
} catch let error as URLError {
    switch error.code {
    case .notConnectedToInternet:
        // No internet connection
        break
    case .timedOut:
        // Request timed out
        break
    default:
        // Other network error
        break
    }
} catch {
    // Other errors (parsing, etc.)
}
```

### Custom Error Types

```swift
enum APIError: Error {
    case invalidResponse
    case serverMaintenance
    case rateLimited(retryAfter: TimeInterval)
}

struct APIErrorInterceptor: Interceptor {
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
        case 429:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                .flatMap(TimeInterval.init) ?? 60
            throw APIError.rateLimited(retryAfter: retryAfter)
        case 503:
            throw APIError.serverMaintenance
        default:
            return (data, response)
        }
    }
}
```
