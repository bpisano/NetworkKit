//
//  ConnectMacroTests.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 17/07/2025.
//

import NetworkKitMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ConnectMacroTests: XCTestCase {
    func testConnectMacroExpansion() {
        assertMacroExpansion(
            """
            @Connect("/books")
            struct ConnectBook {
            }
            """,
            expandedSource: """
                struct ConnectBook {

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .connect

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body = EmptyBody()
                }

                extension ConnectBook: HttpRequest {
                }
                """,
            macros: ["Connect": ConnectMacro.self]
        )
    }

    func testConnectMacroExpansionWithPublicStruct() {
        assertMacroExpansion(
            """
            @Connect("/books")
            public struct ConnectBook {
            }
            """,
            expandedSource: """
                public struct ConnectBook {

                    public typealias Response = Empty

                    public let path: String = "/books"

                    public let method: HttpMethod = .connect

                    public var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    public let body = EmptyBody()
                }

                extension ConnectBook: HttpRequest {
                }
                """,
            macros: ["Connect": ConnectMacro.self]
        )
    }

    func testConnectMacroWithQueryProperties() {
        assertMacroExpansion(
            """
            @Connect("/books")
            struct ConnectBook {
                @Query
                var timeout: Int
            }
            """,
            expandedSource: """
                struct ConnectBook {
                    var timeout: Int

                    var _queryTimeout: QueryParameter {
                        QueryParameter(key: "timeout", value: timeout)
                    }

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .connect

                    var queryParameters: [QueryParameter] {
                        [
                            _queryTimeout
                        ]
                    }

                    let body = EmptyBody()
                }

                extension ConnectBook: HttpRequest {
                }
                """,
            macros: ["Connect": ConnectMacro.self, "Query": QueryMacro.self]
        )
    }

    func testConnectMacroWithPublicQueryProperties() {
        assertMacroExpansion(
            """
            @Connect("/books")
            public struct ConnectBook {
                @Query
                var timeout: Int
            }
            """,
            expandedSource: """
                public struct ConnectBook {
                    var timeout: Int

                    var _queryTimeout: QueryParameter {
                        QueryParameter(key: "timeout", value: timeout)
                    }

                    public typealias Response = Empty

                    public let path: String = "/books"

                    public let method: HttpMethod = .connect

                    public var queryParameters: [QueryParameter] {
                        [
                            _queryTimeout
                        ]
                    }

                    public let body = EmptyBody()
                }

                extension ConnectBook: HttpRequest {
                }
                """,
            macros: ["Connect": ConnectMacro.self, "Query": QueryMacro.self]
        )
    }

    func testConnectMacroWithBodyExpansion() {
        assertMacroExpansion(
            """
            @Connect("/books")
            struct ConnectBook {
                @Body
                struct ConnectOptions {
                    let tunnelHost: String
                }
            }
            """,
            expandedSource: """
                struct ConnectBook {
                    @Body
                    struct ConnectOptions {
                        let tunnelHost: String
                    }

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .connect

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body: ConnectOptions
                }

                extension ConnectBook: HttpRequest {
                }
                """,
            macros: ["Connect": ConnectMacro.self]
        )
    }

    func testConnectMacroWithExistingBodyProperty() {
        assertMacroExpansion(
            """
            @Connect("/books")
            struct ConnectBook {
                let body: String = "existing body"
            }
            """,
            expandedSource: """
                struct ConnectBook {
                    let body: String = "existing body"

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .connect

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                }

                extension ConnectBook: HttpRequest {
                }
                """,
            macros: ["Connect": ConnectMacro.self]
        )
    }

    func testConnectMacroWithResponseType() {
        assertMacroExpansion(
            """
            @Connect("/proxy")
            @Response(ConnectResponse.self)
            struct ConnectProxy {
            }
            """,
            expandedSource: """
                struct ConnectProxy {

                    typealias Response = ConnectResponse

                    let path: String = "/proxy"

                    let method: HttpMethod = .connect

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body = EmptyBody()
                }

                extension ConnectProxy: HttpRequest {
                }
                """,
            macros: ["Connect": ConnectMacro.self, "Response": ResponseMacro.self]
        )
    }

    func testConnectMacroWithResponseTypeAndPublicStruct() {
        assertMacroExpansion(
            """
            @Connect("/proxy")
            @Response([ConnectResponse].self)
            public struct ConnectProxy {
                let body: ConnectOptions
            }
            """,
            expandedSource: """
                public struct ConnectProxy {
                    let body: ConnectOptions

                    public typealias Response = [ConnectResponse]

                    public let path: String = "/proxy"

                    public let method: HttpMethod = .connect

                    public var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                }

                extension ConnectProxy: HttpRequest {
                }
                """,
            macros: ["Connect": ConnectMacro.self, "Response": ResponseMacro.self]
        )
    }
}
