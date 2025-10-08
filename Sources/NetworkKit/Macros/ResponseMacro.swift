/// A macro that defines the response type for HTTP requests.
///
/// This macro can be used in two ways:
///
/// ## External Usage (on HttpRequest struct)
/// When applied to an HttpRequest struct with a type argument, it adds a Response typealias.
///
/// > Make sure your type conforms to `Decodable`.
///
/// ```swift
/// @Delete("/products/:id")
/// @Response(Product.self)
/// private struct DeleteProductRequest {
///     @Path
///     var id: String
/// }
/// ```
///
/// Expands to:
/// ```swift
/// @Delete("/products/:id")
/// private struct DeleteProductRequest {
///     typealias Response = Product
///
///     @Path
///     var id: String
/// }
/// ```
///
/// ## Internal Usage (on nested type)
/// When applied to a nested type, it makes that type the response and adds Decodable conformance.
///
/// > Don't provide any arguments to the `@Response` macro when used internally.
///
/// ```swift
/// @Delete("/products/:id")
/// private struct DeleteProductRequest {
///     @Path
///     var id: String
///
///     @Response
///     struct Dto {
///         let id: String
///         let name: String
///     }
/// }
/// ```
///
/// Expands to:
/// ```swift
/// @Delete("/products/:id")
/// private struct DeleteProductRequest {
///     typealias Response = Dto
///
///     @Path
///     var id: String
///
///     struct Dto: Decodable {
///         let id: String
///         let name: String
///     }
/// }
/// ```
///
/// - Parameter responseType: The response type (only for external usage)
@attached(member, names: named(Response))
@attached(extension, conformances: Decodable)
public macro Response<T: Decodable>(_ responseType: T.Type) =
    #externalMacro(module: "NetworkKitMacros", type: "ResponseMacro")

@attached(member, names: named(Response))
@attached(extension, conformances: Decodable)
public macro Response() =
    #externalMacro(module: "NetworkKitMacros", type: "ResponseMacro")
