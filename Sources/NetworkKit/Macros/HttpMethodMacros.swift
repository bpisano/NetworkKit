//
//  HttpMethodMacros.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 07/07/2025.
//

/// A macro that creates a GET request with the specified path.
///
/// This macro automatically adds the `path`, `method`, and `queryParameters` properties to the struct
/// and makes it conform to `HttpRequest`. Use the `@Response` macro to specify the response type.
///
/// ## Usage
///
/// ```swift
/// // With explicit response type:
/// @Get("/users")
/// @Response([User].self)
/// struct GetUsersRequest {
///     @Query
///     var page: Int
///
///     @Query
///     var limit: Int
/// }
///
/// // With default Empty response:
/// @Get("/users/refresh")
/// struct RefreshUsersRequest {
///     // This will generate: typealias Response = Empty
/// }
/// ```
///
/// - Parameter path: The path for the HTTP request
@attached(
    member, names: named(path), named(method), named(queryParameters), named(body), named(Response))
@attached(extension, conformances: HttpRequest)
public macro Get(_ path: String) =
    #externalMacro(module: "NetworkKitMacros", type: "GetMacro")

/// A macro that creates a POST request with the specified path.
///
/// This macro automatically adds the `path`, `method`, and `queryParameters` properties to the struct
/// and makes it conform to `HttpRequest`. Use the `@Response` macro to specify the response type.
///
/// ## Usage
///
/// ```swift
/// // With explicit response type:
/// @Post("/users")
/// @Response(User.self)
/// struct CreateUserRequest {
///     @Body
///     struct Body: HttpBody {
///         let name: String
///         let email: String
///     }
/// }
///
/// // With default Empty response:
/// @Post("/users/refresh")
/// struct RefreshUsersRequest {
///     // This will generate: typealias Response = Empty
/// }
/// ```
///
/// - Parameter path: The path for the HTTP request
@attached(
    member, names: named(path), named(method), named(queryParameters), named(body), named(Response))
@attached(extension, conformances: HttpRequest)
public macro Post(_ path: String) =
    #externalMacro(module: "NetworkKitMacros", type: "PostMacro")

/// A macro that creates a PUT request with the specified path.
///
/// This macro automatically adds the `path`, `method`, and `queryParameters` properties to the struct
/// and makes it conform to `HttpRequest`. Use the `@Response` macro to specify the response type.
///
/// ## Usage
///
/// ```swift
/// // With explicit response type:
/// @Put("/users/:id")
/// @Response(User.self)
/// struct UpdateUserRequest {
///     @Path
///     var id: String
///
///     @Body
///     struct Body: HttpBody {
///         let name: String
///         let email: String
///     }
/// }
///
/// // With default Empty response:
/// @Put("/users/:id/refresh")
/// struct RefreshUserRequest {
///     @Path
///     var id: String
///     // This will generate: typealias Response = Empty
/// }
/// ```
///
/// - Parameter path: The path for the HTTP request
@attached(
    member, names: named(path), named(method), named(queryParameters), named(body), named(Response))
@attached(extension, conformances: HttpRequest)
public macro Put(_ path: String) =
    #externalMacro(module: "NetworkKitMacros", type: "PutMacro")

/// A macro that creates a PATCH request with the specified path.
///
/// This macro automatically adds the `path`, `method`, and `queryParameters` properties to the struct
/// and makes it conform to `HttpRequest`. Use the `@Response` macro to specify the response type.
///
/// ## Usage
///
/// ```swift
/// // With explicit response type:
/// @Patch("/users/:id")
/// @Response(User.self)
/// struct PatchUserRequest {
///     @Path
///     var id: String
///
///     @Body
///     struct Body: HttpBody {
///         let name: String?
///         let email: String?
///     }
/// }
///
/// // With default Empty response:
/// @Patch("/users/:id/refresh")
/// struct RefreshUserRequest {
///     @Path
///     var id: String
///     // This will generate: typealias Response = Empty
/// }
/// ```
///
/// - Parameter path: The path for the HTTP request
@attached(
    member, names: named(path), named(method), named(queryParameters), named(body), named(Response))
@attached(extension, conformances: HttpRequest)
public macro Patch(_ path: String) =
    #externalMacro(module: "NetworkKitMacros", type: "PatchMacro")

/// A macro that creates a DELETE request with the specified path.
///
/// This macro automatically adds the `path`, `method`, and `queryParameters` properties to the struct
/// and makes it conform to `HttpRequest`. Use the `@Response` macro to specify the response type.
///
/// ## Usage
///
/// ```swift
/// // With explicit response type:
/// @Delete("/users/:id")
/// @Response(DeleteResponse.self)
/// struct DeleteUserRequest {
///     @Path
///     var id: String
/// }
///
/// // With default Empty response:
/// @Delete("/users/:id")
/// struct DeleteUserRequest {
///     @Path
///     var id: String
/// }
/// ```
///
/// - Parameter path: The path for the HTTP request
@attached(
    member, names: named(path), named(method), named(queryParameters), named(body), named(Response))
@attached(extension, conformances: HttpRequest)
public macro Delete(_ path: String) =
    #externalMacro(module: "NetworkKitMacros", type: "DeleteMacro")

/// A macro that creates an OPTIONS request with the specified path.
///
/// This macro automatically adds the `path`, `method`, and `queryParameters` properties to the struct
/// and makes it conform to `HttpRequest`. Use the `@Response` macro to specify the response type.
///
/// ## Usage
///
/// ```swift
/// // With explicit response type:
/// @Options("/users")
/// @Response([String].self)
/// struct OptionsUsersRequest {
///     @Query
///     var includeHidden: Bool
/// }
///
/// // With default Empty response:
/// @Options("/users/refresh")
/// struct RefreshOptionsRequest {
///     // This will generate: typealias Response = Empty
/// }
/// ```
///
/// - Parameter path: The path for the HTTP request
@attached(
    member, names: named(path), named(method), named(queryParameters), named(body), named(Response))
@attached(extension, conformances: HttpRequest)
public macro Options(_ path: String) =
    #externalMacro(module: "NetworkKitMacros", type: "OptionsMacro")

/// A macro that creates a HEAD request with the specified path.
///
/// This macro automatically adds the `path`, `method`, and `queryParameters` properties to the struct
/// and makes it conform to `HttpRequest`. Use the `@Response` macro to specify the response type.
///
/// ## Usage
///
/// ```swift
/// // With explicit response type:
/// @Head("/users/:id")
/// @Response(HeadResponse.self)
/// struct HeadUserRequest {
///     @Path
///     var id: String
///
///     @Query
///     var includeMetadata: Bool
/// }
///
/// // With default Empty response:
/// @Head("/users/:id/check")
/// struct CheckUserRequest {
///     @Path
///     var id: String
///     // This will generate: typealias Response = Empty
/// }
/// ```
///
/// - Parameter path: The path for the HTTP request
@attached(
    member, names: named(path), named(method), named(queryParameters), named(body), named(Response))
@attached(extension, conformances: HttpRequest)
public macro Head(_ path: String) =
    #externalMacro(module: "NetworkKitMacros", type: "HeadMacro")

/// A macro that creates a TRACE request with the specified path.
///
/// This macro automatically adds the `path`, `method`, and `queryParameters` properties to the struct
/// and makes it conform to `HttpRequest`. Use the `@Response` macro to specify the response type.
///
/// ## Usage
///
/// ```swift
/// // With explicit response type:
/// @Trace("/debug")
/// @Response([TraceResponse].self)
/// struct TraceDebugRequest {
///     @Query
///     var maxHops: Int
/// }
///
/// // With default Empty response:
/// @Trace("/debug/refresh")
/// struct RefreshTraceRequest {
///     // This will generate: typealias Response = Empty
/// }
/// ```
///
/// - Parameter path: The path for the HTTP request
@attached(
    member, names: named(path), named(method), named(queryParameters), named(body), named(Response))
@attached(extension, conformances: HttpRequest)
public macro Trace(_ path: String) =
    #externalMacro(module: "NetworkKitMacros", type: "TraceMacro")

/// A macro that creates a CONNECT request with the specified path.
///
/// This macro automatically adds the `path`, `method`, and `queryParameters` properties to the struct
/// and makes it conform to `HttpRequest`. Use the `@Response` macro to specify the response type.
///
/// ## Usage
///
/// ```swift
/// // With explicit response type:
/// @Connect("/proxy")
/// @Response([ConnectResponse].self)
/// struct ConnectProxyRequest {
///     @Query
///     var host: String
///
///     @Query
///     var port: Int
/// }
///
/// // With default Empty response:
/// @Connect("/proxy/refresh")
/// struct RefreshProxyRequest {
///     // This will generate: typealias Response = Empty
/// }
/// ```
///
/// - Parameter path: The path for the HTTP request
@attached(
    member, names: named(path), named(method), named(queryParameters), named(body), named(Response))
@attached(extension, conformances: HttpRequest)
public macro Connect(_ path: String) =
    #externalMacro(module: "NetworkKitMacros", type: "ConnectMacro")
