import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import NetworkKitMacros

final class ResponseMacroTests: XCTestCase {
    func testInternalResponseMacroExpansion() {
        assertMacroExpansion(
            """
            struct SomeRequest {
                @Response
                struct UserResponse {
                    let id: String
                    let name: String
                }
            }
            """,
            expandedSource: """
                struct SomeRequest {
                    struct UserResponse {
                        let id: String
                        let name: String
                    }
                }

                extension SomeRequest.UserResponse: Decodable {
                }
                """,
            macros: ["Response": ResponseMacro.self]
        )
    }

    func testGetMacroWithExternalResponse() {
        assertMacroExpansion(
            """
            @Get("/users")
            @Response(User.self)
            struct GetUsersRequest {
            }
            """,
            expandedSource: """
                struct GetUsersRequest {

                    typealias Response = User

                    let path: String = "/users"

                    let method: HttpMethod = .get

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body = EmptyBody()
                }

                extension GetUsersRequest: HttpRequest {
                }
                """,
            macros: ["Get": GetMacro.self, "Response": ResponseMacro.self]
        )
    }

    func testPublicGetMacroWithExternalResponse() {
        assertMacroExpansion(
            """
            @Get("/users")
            @Response(User.self)
            public struct GetUsersRequest {
            }
            """,
            expandedSource: """
                public struct GetUsersRequest {

                    public typealias Response = User

                    public let path: String = "/users"

                    public let method: HttpMethod = .get

                    public var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    public let body = EmptyBody()
                }

                extension GetUsersRequest: HttpRequest {
                }
                """,
            macros: ["Get": GetMacro.self, "Response": ResponseMacro.self]
        )
    }
}
