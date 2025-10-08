# ``NetworkKit``

A modern, type-safe networking library for Swift that simplifies HTTP requests with powerful macros and flexible architecture.

## Overview

NetworkKit provides a declarative approach to building HTTP requests using Swift macros. It separates concerns between **clients** (server environments) and **requests** (API endpoints), making your networking code more maintainable and testable.

### Key Features

- **Type-Safe Requests**: Define HTTP requests using Swift structs with automatic type checking
- **Powerful Macros**: Use `@Get`, `@Post`, `@Put`, `@Delete`, and other HTTP method macros to eliminate boilerplate
- **Flexible Response Handling**: Automatic JSON decoding with the `@Response` macro
- **Environment Separation**: Use the same requests across different server environments (dev, staging, prod)
- **Middleware & Interceptors**: Customize request/response processing with a clean plugin architecture
- **Multipart Form Support**: Built-in support for file uploads and form data

## Quick Start

### 1. Create a Client

A client represents a server environment with its base URL and configuration:

```swift
let client = Client("https://api.example.com")
```

### 2. Define a Request

Use macros to define type-safe HTTP requests:

```swift
@Get("/users/:id")
@Response(User.self)
struct GetUserRequest {
    @Path
    var id: String

    @Query
    var includePosts: Bool
}
```

### 3. Make the Request

```swift
let request = GetUserRequest(id: "123", includePosts: true)
let response = try await client.perform(request)
let user = response.data
```

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:DefiningRequests>
- <doc:WorkingWithClients>

### HTTP Methods

- ``Get(_:)``
- ``Post(_:)``
- ``Put(_:)``
- ``Delete(_:)``
- ``Patch(_:)``
- ``Head(_:)``
- ``Options(_:)``
- ``Connect(_:)``
- ``Trace(_:)``

### Request Components

- ``Response(_:)``
- ``Response()``
- ``Query(_:)``
- ``Body()``
- ``Path``

### Core Types

- ``HttpRequest``
- ``Client``
- ``HttpMethod``
- ``HttpBody``
- ``QueryParameter``
- ``Response``

### Advanced Features

- ``Middleware``
- ``Interceptor``
- ``ClientLogger``
- ``MultipartForm``

### Utilities

- ``Empty``
- ``EmptyBody``
- ``MimeType``
