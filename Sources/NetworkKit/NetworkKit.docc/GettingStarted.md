# Getting Started

Learn how to set up and use NetworkKit in your Swift project.

## Overview

NetworkKit is a modern, type-safe networking library for Swift that uses powerful macros to simplify HTTP request creation. This guide will walk you through the basic setup and your first API call.

## Installation

### Swift Package Manager

Add NetworkKit to your project using Swift Package Manager:

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/bpisano/network-kit`
3. Select the version you want to use
4. Add the package to your target

Alternatively, add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/bpisano/network-kit", from: "1.2.0")
]
```

## Basic Setup

### Import NetworkKit

Start by importing NetworkKit in your Swift files:

```swift
import NetworkKit
```

### Create Your First Client

A client represents a server environment (like dev, staging, or production):

```swift
let client = Client("https://api.example.com")
```

You can create multiple clients for different environments:

```swift
let devClient = Client("https://dev-api.example.com")
let prodClient = Client("https://api.example.com")
```

### Define Your First Request

Use NetworkKit's macros to define type-safe HTTP requests:

```swift
@Get("/users")
@Response([User].self)
struct GetUsersRequest {
    @Query
    var page: Int = 1
    
    @Query
    var limit: Int = 20
}
```

### Define Your Response Model

Make sure your response types conform to `Decodable`:

```swift
struct User: Decodable {
    let id: String
    let name: String
    let email: String
}
```

### Make Your First Request

Now you can perform the request:

```swift
let request = GetUsersRequest(page: 1, limit: 10)

do {
    let response = try await client.perform(request)
    let users = response.data // This is [User]
    print("Fetched \(users.count) users")
} catch {
    print("Request failed: \(error)")
}
```

## What's Next?

Now that you have NetworkKit set up, explore these topics:

- <doc:DefiningRequests> - Learn how to create more complex requests
- <doc:WorkingWithClients> - Discover advanced client configuration
- ``Middleware`` - Add authentication and logging to your requests
- ``MultipartForm`` - Upload files and form data

## Common Patterns

### Error Handling

```swift
do {
    let response = try await client.perform(request)
    // Handle success
} catch let error as HTTPError {
    // Handle HTTP errors (4xx, 5xx)
    print("HTTP Error: \(error.statusCode)")
} catch {
    // Handle other errors (network, parsing, etc.)
    print("Error: \(error)")
}
```

### Progress Tracking

```swift
let response = try await client.perform(request) { progress in
    print("Progress: \(Int(progress.fractionCompleted * 100))%")
}
```

### Environment Configuration

```swift
#if DEBUG
let client = Client("https://dev-api.example.com")
#else
let client = Client("https://api.example.com")
#endif
```
