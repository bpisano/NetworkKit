/// A macro that transforms properties into query parameters for HTTP requests.
///
/// The `@Query` macro automatically generates the necessary code to convert property values
/// into `QueryParameter` objects that can be used in HTTP requests. This macro **must be used
/// in conjunction with HTTP method macros** like `@Get`, `@Post`, `@Put`, etc.
///
/// ## Usage
///
/// Apply the `@Query` macro to properties in your request structure that uses an HTTP method macro:
///
/// ```swift
/// @Get("/api/search")
/// struct SearchRequest {
///     @Query
///     let search: String
///
///     @Query
///     let category: String
/// }
/// ```
///
/// This generates computed properties that create `QueryParameter` objects, which are
/// automatically collected by the HTTP method macro:
///
/// ```swift
/// @Get("/api/search")
/// struct SearchRequest {
///     var search: String
///     var category: String
///
///     var _querySearch: QueryParameter {
///         QueryParameter(key: "search", value: search)
///     }
///
///     var _queryCategory: QueryParameter {
///         QueryParameter(key: "category", value: category)
///     }
///
///     var queryParameters: [QueryParameter] {
///         [_querySearch, _queryCategory]
///     }
/// }
/// ```
///
/// ## Custom Parameter Names
///
/// You can specify a custom parameter name by passing a string argument:
///
/// ```swift
/// @Get("/api/search")
/// struct SearchRequest {
///     @Query("q")
///     let search: String
///
///     @Query("page_size")
///     let pageSize: String
/// }
/// ```
///
/// This will use the custom names in the generated query parameters:
///
/// ```swift
/// var _querySearch: QueryParameter {
///     QueryParameter(key: "q", value: search)
/// }
///
/// var _queryPageSize: QueryParameter {
///     QueryParameter(key: "page_size", value: pageSize)
/// }
/// ```
///
/// ## Supported Types (QueryRepresentable)
///
/// The `@Query` macro works with any type that conforms to the `QueryRepresentable` protocol.
/// NetworkKit provides built-in support for a comprehensive set of types:
///
/// ### String Types
/// - `String` - Converted directly to query value
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
/// ### Collection Types
/// - `Array<Element>` where `Element: QueryRepresentable` - Elements joined with commas
///
/// ### Examples with Different Types
///
/// ```swift
/// @Get("/api/users")
/// struct GetUsersRequest {
///     @Query
///     let userId: UUID          // Converted to UUID string
///
///     @Query
///     let page: Int            // Converted to string representation
///
///     @Query
///     let includeActive: Bool  // Converted to "true" or "false"
///
///     @Query
///     let tags: [String]       // Converted to comma-separated values
/// }
/// ```
///
/// ### Custom QueryRepresentable Types
///
/// You can make your own types work with `@Query` by conforming to `QueryRepresentable`:
///
/// ```swift
/// enum SortOrder: String, QueryRepresentable, CaseIterable {
///     case ascending = "asc"
///     case descending = "desc"
///
///     var queryValue: String { rawValue }
/// }
///
/// @Get("/api/products")
/// struct GetProductsRequest {
///     @Query
///     let sortOrder: SortOrder
/// }
/// ```
///
/// ## Requirements
///
/// - Should be used with an HTTP method macro (`@Get`, `@Post`, `@Put`, `@Delete`, etc.)
/// - Can only be applied to stored properties
/// - Properties must have a type that conforms to `QueryRepresentable`
///
/// - Parameter name: An optional custom parameter name to use instead of the property name
@attached(peer, names: arbitrary)
public macro Query(_ name: String? = nil) =
    #externalMacro(module: "NetworkKitMacros", type: "QueryMacro")
