/// A macro that transforms properties into path parameters for HTTP requests.
///
/// The `@Path` macro automatically generates the necessary code to convert property values
/// into `PathParameter` objects that can be used in HTTP requests. This macro **must be used
/// in conjunction with HTTP method macros** like `@Get`, `@Post`, `@Put`, etc.
///
/// ## Usage
///
/// Apply the `@Path` macro to properties in your request structure that uses an HTTP method macro:
///
/// ```swift
/// @Get("/api/users/:id/posts/:postId")
/// struct GetUserPostRequest {
///     @Path
///     let id: String
///
///     @Path
///     let postId: String
/// }
/// ```
///
/// This generates computed properties that create `PathParameter` objects, which are
/// automatically collected by the HTTP method macro:
///
/// ```swift
/// @Get("/api/users/:id/posts/:postId")
/// struct GetUserPostRequest {
///     var id: String
///     var postId: String
///
///     var _pathId: PathParameter {
///         PathParameter(key: "id", value: id)
///     }
///
///     var _pathPostId: PathParameter {
///         PathParameter(key: "postId", value: postId)
///     }
///
///     var pathParameters: [PathParameter] {
///         [_pathId, _pathPostId]
///     }
/// }
/// ```
///
/// ## Custom Parameter Names
///
/// You can specify a custom parameter name by passing a string argument:
///
/// ```swift
/// @Get("/api/users/:userId/posts/:docId")
/// struct GetUserPostRequest {
///     @Path("userId")
///     let userIdentifier: String
///
///     @Path("docId")
///     let documentId: String
/// }
/// ```
///
/// This will use the custom names in the generated path parameters:
///
/// ```swift
/// var _pathUserIdentifier: PathParameter {
///     PathParameter(key: "userId", value: userIdentifier)
/// }
///
/// var _pathDocumentId: PathParameter {
///     PathParameter(key: "docId", value: documentId)
/// }
/// ```
///
/// ## Supported Types (PathRepresentable)
///
/// The `@Path` macro works with any type that conforms to the `PathRepresentable` protocol.
/// NetworkKit provides built-in support for a comprehensive set of types:
///
/// ### String Types
/// - `String` - Converted directly to path value
/// - `Substring` - Converted to String
/// - `Character` - Converted to String
///
/// ### Integer Types
/// - **Signed**: `Int`, `Int8`, `Int16`, `Int32`, `Int64`
/// - **Unsigned**: `UInt`, `UInt8`, `UInt16`, `UInt32`, `UInt64`
///
/// ### Floating Point Types
/// - `Float`, `Double`, `Decimal`
///
/// ### Boolean Type
/// - `Bool` - Converted to "true" or "false"
///
/// ### Foundation Types
/// - `UUID` - Converted to UUID string representation
/// - `Date` - Converted to time interval since 1970
/// - `URL` - Converted to absolute string
/// - `NSNumber` - Converted to string value
///
/// ### Examples with Different Types
///
/// ```swift
/// @Get("/api/users/:userId/posts/:postId/status/:isActive")
/// struct GetUserPostRequest {
///     @Path
///     let userId: UUID           // Converted to UUID string
///
///     @Path
///     let postId: Int           // Converted to string representation
///
///     @Path
///     let isActive: Bool        // Converted to "true" or "false"
/// }
///
/// @Get("/api/products/:categories")
/// struct GetProductsRequest {
///     @Path
///     let categories: [String]  // Converted to comma-separated values
/// }
/// ```
///
/// ### Custom PathRepresentable Types
///
/// You can make your own types work with `@Path` by conforming to `PathRepresentable`:
///
/// ```swift
/// enum ProductCategory: String, PathRepresentable, CaseIterable {
///     case electronics = "electronics"
///     case clothing = "clothing"
///     case books = "books"
///
///     var pathValue: String { rawValue }
/// }
///
/// @Get("/api/products/:category")
/// struct GetProductsRequest {
///     @Path
///     let category: ProductCategory
/// }
/// ```
///
/// ## Requirements
///
/// - Should be used with an HTTP method macro (`@Get`, `@Post`, `@Put`, `@Delete`, etc.)
/// - Can only be applied to stored properties
/// - Properties must have a type that conforms to `PathRepresentable`
///
/// - Parameter name: An optional custom parameter name to use instead of the property name
@attached(peer, names: arbitrary)
public macro Path(_ name: String? = nil) =
    #externalMacro(module: "NetworkKitMacros", type: "PathMacro")
