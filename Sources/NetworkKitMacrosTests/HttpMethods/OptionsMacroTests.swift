//
//  OptionsMacroTests.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 17/07/2025.
//

import NetworkKitMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class OptionsMacroTests: XCTestCase {
    func testOptionsMacroExpansion() {
        assertMacroExpansion(
            """
            @Options("/books")
            struct OptionsBook {
            }
            """,
            expandedSource: """
                struct OptionsBook {

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .options

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body = EmptyBody()
                }

                extension OptionsBook: HttpRequest {
                }
                """,
            macros: ["Options": OptionsMacro.self]
        )
    }

    func testOptionsMacroExpansionWithPublicStruct() {
        assertMacroExpansion(
            """
            @Options("/books")
            public struct OptionsBook {
            }
            """,
            expandedSource: """
                public struct OptionsBook {

                    public typealias Response = Empty

                    public let path: String = "/books"

                    public let method: HttpMethod = .options

                    public var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    public let body = EmptyBody()
                }

                extension OptionsBook: HttpRequest {
                }
                """,
            macros: ["Options": OptionsMacro.self]
        )
    }

    func testOptionsMacroWithQueryProperties() {
        assertMacroExpansion(
            """
            @Options("/books")
            struct OptionsBook {
                @Query
                var includeHidden: Bool
            }
            """,
            expandedSource: """
                struct OptionsBook {
                    var includeHidden: Bool

                    var _queryIncludeHidden: QueryParameter {
                        QueryParameter(key: "includeHidden", value: includeHidden)
                    }

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .options

                    var queryParameters: [QueryParameter] {
                        [
                            _queryIncludeHidden
                        ]
                    }

                    let body = EmptyBody()
                }

                extension OptionsBook: HttpRequest {
                }
                """,
            macros: ["Options": OptionsMacro.self, "Query": QueryMacro.self]
        )
    }

    func testOptionsMacroWithPublicQueryProperties() {
        assertMacroExpansion(
            """
            @Options("/books")
            public struct OptionsBook {
                @Query
                var includeHidden: Bool
            }
            """,
            expandedSource: """
                public struct OptionsBook {
                    var includeHidden: Bool

                    var _queryIncludeHidden: QueryParameter {
                        QueryParameter(key: "includeHidden", value: includeHidden)
                    }

                    public typealias Response = Empty

                    public let path: String = "/books"

                    public let method: HttpMethod = .options

                    public var queryParameters: [QueryParameter] {
                        [
                            _queryIncludeHidden
                        ]
                    }

                    public let body = EmptyBody()
                }

                extension OptionsBook: HttpRequest {
                }
                """,
            macros: ["Options": OptionsMacro.self, "Query": QueryMacro.self]
        )
    }

    func testOptionsMacroWithBodyExpansion() {
        assertMacroExpansion(
            """
            @Options("/books")
            struct OptionsBook {
                @Body
                struct OptionsFilter {
                    let scope: String
                }
            }
            """,
            expandedSource: """
                struct OptionsBook {
                    @Body
                    struct OptionsFilter {
                        let scope: String
                    }

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .options

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body: OptionsFilter
                }

                extension OptionsBook: HttpRequest {
                }
                """,
            macros: ["Options": OptionsMacro.self]
        )
    }

    func testOptionsMacroWithExistingBodyProperty() {
        assertMacroExpansion(
            """
            @Options("/books")
            struct OptionsBook {
                let body: String = "existing body"
            }
            """,
            expandedSource: """
                struct OptionsBook {
                    let body: String = "existing body"

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .options

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                }

                extension OptionsBook: HttpRequest {
                }
                """,
            macros: ["Options": OptionsMacro.self]
        )
    }

    func testOptionsMacroWithResponseType() {
        assertMacroExpansion(
            """
            @Options("/api/config")
            @Response(OptionsResponse.self)
            struct ApiConfig {
            }
            """,
            expandedSource: """
                struct ApiConfig {

                    typealias Response = OptionsResponse

                    let path: String = "/api/config"

                    let method: HttpMethod = .options

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body = EmptyBody()
                }

                extension ApiConfig: HttpRequest {
                }
                """,
            macros: ["Options": OptionsMacro.self, "Response": ResponseMacro.self]
        )
    }

    func testOptionsMacroWithResponseTypeAndPublicStruct() {
        assertMacroExpansion(
            """
            @Options("/api/config")
            @Response([String].self)
            public struct ApiConfig {
                let body: OptionsData
            }
            """,
            expandedSource: """
                public struct ApiConfig {
                    let body: OptionsData

                    public typealias Response = [String]

                    public let path: String = "/api/config"

                    public let method: HttpMethod = .options

                    public var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                }

                extension ApiConfig: HttpRequest {
                }
                """,
            macros: ["Options": OptionsMacro.self, "Response": ResponseMacro.self]
        )
    }
}
