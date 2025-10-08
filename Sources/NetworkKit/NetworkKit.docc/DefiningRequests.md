# Defining Requests

Learn how to create powerful, type-safe HTTP requests using NetworkKit's macro system.

## Overview

NetworkKit uses Swift macros to transform simple struct definitions into fully-featured HTTP requests. This declarative approach eliminates boilerplate code while providing compile-time safety.

## Basic Request Structure

Every HTTP request in NetworkKit is defined as a struct that uses HTTP method macros:

```swift
@Get("/path")
@Response(ResponseType.self)
struct MyRequest {
    // Request properties go here
}
```

## HTTP Method Macros

NetworkKit supports all standard HTTP methods through dedicated macros:

### GET Requests

Use `@Get` for retrieving data:

```swift
@Get("/users/:id")
@Response(User.self)
struct GetUserRequest {
    @Path
    var id: String
}
```

### POST Requests

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

### PUT Requests

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

### PATCH Requests

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

### DELETE Requests

Use `@Delete` for removing resources:

```swift
@Delete("/users/:id")
struct DeleteUserRequest {
    @Path
    var id: String
}
```

## Response Types

### External Response Types

Specify the response type using the `@Response` macro:

```swift
@Get("/users")
@Response([User].self)
struct GetUsersRequest {
    // Request properties
}
```

> Make sure your type conforms to `Decodable`.

### Internal Response Types

Define response types directly within your request:

```swift
@Get("/users")
struct GetUsersRequest {
    @Response
    struct UserList {
        let users: [User]
        let totalCount: Int
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
    // No @Response needed - defaults to Empty
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
    var query: String
    
    @Query
    var page: Int
    
    @Query("page_size")  // Custom parameter name
    var pageSize: Int
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

## Advanced Features

### Multiple Query Parameters

```swift
@Get("/api/data")
struct DataRequest {
    @Query
    var startDate: String
    
    @Query
    var endDate: String
    
    @Query
    var categories: [String]  // Will be serialized as comma-separated
    
    @Query
    var includeMetadata: Bool
}
```

### File Uploads

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
    @Path var userId: String
}

// Avoid
@Get("/users/:userId/orders")
struct Request {
    @Path var userId: String
}
```

### 2. Group Related Requests

```swift
enum UserAPI {
    @Get("/users/:id")
    @Response(User.self)
    struct Get {
        @Path var id: String
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
