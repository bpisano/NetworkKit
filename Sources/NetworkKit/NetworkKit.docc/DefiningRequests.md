# Defining Requests

Learn how to create powerful, type-safe HTTP requests using NetworkKit's macro system.

## Overview

NetworkKit uses Swift macros to transform simple struct definitions into fully-featured HTTP requests. This declarative approach eliminates boilerplate code while providing compile-time safety.

## Table of Contents

- [Basic Request Structure](#basic-request-structure)
- [HTTP Method Macros](#http-method-macros)
  - [GET](#get)
  - [POST](#post)
  - [PUT](#put)
  - [PATCH](#patch)
  - [DELETE](#delete)
  - [HEAD](#head)
  - [OPTIONS](#options)
  - [CONNECT](#connect)
  - [TRACE](#trace)
- [Response Types](#response-types)
  - [External Response Types](#external-response-types)
  - [Internal Response Types](#internal-response-types)
  - [Empty Responses](#empty-responses)
- [Request Parameters](#request-parameters)
  - [Path Parameters](#path-parameters)
  - [Query Parameters](#query-parameters)
  - [Request Bodies](#request-bodies)
- [Custom Headers](#custom-headers)
- [MultipartForm](#multipartform)
- [Best Practices](#best-practices)

## Basic Request Structure

Every HTTP request in NetworkKit is the blueprint of a server interaction. It uses a declarative syntax and Swift macros to define the HTTP method, endpoint, parameters, and response type.

```swift
@Post("/path/:parameter")
@Response(ResponseType.self)
struct MyRequest {
    @Path
    var parameter: String

    @Body
    struct Body: HttpBody {
        let someKey: String
    }
}


let request = MyRequest(
    parameter: "value", 
    body: .init(
        someKey: "data"
    )
)
```

## HTTP Method Macros

NetworkKit supports all standard HTTP methods through dedicated macros:

### GET

Use `@Get` for retrieving data:

```swift
@Get("/users/:id")
@Response(User.self)
struct GetUserRequest {
    @Path
    var id: String
}
```

### POST

Use `@Post` for creating resources:

```swift
@Post("/users")
@Response(User.self)
struct CreateUserRequest {
    @Body
    struct Body: HttpBody {
        let name: String
        let email: String
    }
}
```

### PUT

Use `@Put` for updating entire resources:

```swift
@Put("/users/:id")
@Response(User.self)
struct UpdateUserRequest {
    @Path
    var id: String
    
    @Body
    struct Body: HttpBody {
        let name: String
        let email: String
    }
}
```

### PATCH

Use `@Patch` for partial updates:

```swift
@Patch("/users/:id")
@Response(User.self)
struct PatchUserRequest {
    @Path
    var id: String
    
    @Body
    struct Body: HttpBody {
        let name: String?
        let email: String?
    }
}
```

### DELETE

Use `@Delete` for removing resources:

```swift
@Delete("/users/:id")
struct DeleteUserRequest {
    @Path
    var id: String
}
```

### HEAD

Use `@Head` for checking if a resource exists without retrieving its content:

```swift
@Head("/users/:id")
struct CheckUserRequest {
    @Path
    var id: String
}
```

### OPTIONS

Use `@Options` for discovering allowed methods on a resource:

```swift
@Options("/users")
struct OptionsUserRequest {
}
```

### CONNECT

Use `@Connect` for establishing a tunnel to a server:

```swift
@Connect("/proxy")
struct ConnectProxyRequest {
    @Query
    var host: String
    
    @Query
    var port: Int
}
```

### TRACE

Use `@Trace` for performing a message loop-back test:

```swift
@Trace("/debug")
struct TraceRequest {
}
```

## Response Types

### External Response Types

Specify the response type using the `@Response` macro:

```swift
@Get("/user/:id")
@Response(User.self)
struct GetUserRequest {
    @Path
    var id: String
}
```

> Make sure your type conforms to `Decodable`.

### Internal Response Types

Define response types directly within your request:

```swift
@Get("/user/:id")
struct GetUserRequest {
    @Path
    var id: String

    @Response
    struct User {
        let id: String
        let name: String
    }
}
```

> Don't provide any arguments to the `@Response` macro when used internally.

### Empty Responses

For requests that don't return data:

```swift
@Delete("/users/:id")
struct DeleteUserRequest {
    @Path
    var id: String

    // No @Response needed
}
```

## Request Parameters

### Path Parameters

Use `@Path` for URL path parameters:

```swift
@Get("/users/:id/posts/:postId")
struct GetPostRequest {
    @Path
    var id: String
    
    @Path
    var postId: String
}
```

The property names must match the parameter names in the path (`:id` → `id`, `:postId` → `postId`).

### Query Parameters

Use `@Query` for URL query parameters:

```swift
@Get("/search")
struct SearchRequest {
    @Query
    let query: String
    
    @Query
    let page: Int
    
    @Query("page_size")  // Custom parameter name
    let pageSize: Int
}
```

Query parameter types must conform to `CustomStringConvertible`.

### Request Bodies

Use `@Body` to define request bodies:

```swift
@Post("/users")
struct CreateUserRequest {
    @Body
    struct UserData {
        let name: String
        let email: String
        let age: Int
    }
}
```

You can also use existing types:

```swift
@Post("/users")
struct CreateUserRequest {
    let body: User  // User must conform to HttpBody
}
```

## Custom Headers

Add custom headers to your requests:

```swift
@Get("/protected")
struct ProtectedRequest {
    let headers: [String: String?] = [
        "Authorization": "Bearer token123",
        "X-API-Version": "2.0"
    ]
}
```

## MultipartForm

Use `MultipartForm` for file uploads:

```swift
@Post("/upload")
struct UploadFileRequest {
    let imageData: Data
    let description: String
    
    var body: some HttpBody {
        MultipartForm {
            DataField(
                "file",
                data: imageData,
                mimeType: .jpegImage,
                fileName: "image.jpg"
            )
            TextField("description", value: description)
        }
    }
}
```

## Best Practices

### 1. Use Descriptive Names

```swift
// Good
@Get("/users/:userId/orders")
struct GetUserOrdersRequest {
    @Path
    var userId: String
}

// Avoid
@Get("/users/:userId/orders")
struct Request {
    @Path
    var userId: String
}
```

### 2. Group Related Requests

```swift
enum UserAPI {
    @Get("/users/:id")
    @Response(User.self)
    struct Get {
        @Path
        var id: String
    }
    
    @Post("/users")
    @Response(User.self)
    struct Create {
        @Body
        struct UserData {
            let name: String
            let email: String
        }
    }
}
```
