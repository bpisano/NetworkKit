/// A macro that makes a struct conform to `HttpBody` protocol.
///
/// This macro automatically adds the `HttpBody` conformance to your struct, enabling it to be
/// used as a request body. The struct will be automatically serialized as JSON when used in HTTP requests.
///
/// ## Usage
///
/// ```swift
/// @Post("/users")
/// @Response(User.self)
/// struct CreateUserRequest {
///     @Body
///     struct Body {
///         let name: String
///         let email: String
///         let age: Int
///     }
/// }
@attached(extension, conformances: HttpBody)
public macro Body() =
    #externalMacro(module: "NetworkKitMacros", type: "BodyMacro")
