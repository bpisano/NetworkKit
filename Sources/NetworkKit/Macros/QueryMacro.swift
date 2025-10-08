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
/// ## Requirements
///
/// - Should be used with an HTTP method macro (`@Get`, `@Post`, `@Put`, `@Delete`, etc.)
/// - Can only be applied to stored properties
/// - Properties should have a type that conforms to `CustomStringConvertible`
///
/// - Parameter name: An optional custom parameter name to use instead of the property name
@attached(peer, names: arbitrary)
public macro Query(_ name: String? = nil) =
    #externalMacro(module: "NetworkKitMacros", type: "QueryMacro")
