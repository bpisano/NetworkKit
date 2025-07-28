//
//  TraceMacroTests.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 17/07/2025.
//

import NetworkKitMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class TraceMacroTests: XCTestCase {
    func testTraceMacroExpansion() {
        assertMacroExpansion(
            """
            @Trace("/books")
            struct TraceBook {
            }
            """,
            expandedSource: """
                struct TraceBook {

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .trace

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body = EmptyBody()
                }

                extension TraceBook: HttpRequest {
                }
                """,
            macros: ["Trace": TraceMacro.self]
        )
    }

    func testTraceMacroExpansionWithPublicStruct() {
        assertMacroExpansion(
            """
            @Trace("/books")
            public struct TraceBook {
            }
            """,
            expandedSource: """
                public struct TraceBook {

                    typealias Response = Empty

                    public let path: String = "/books"

                    public let method: HttpMethod = .trace

                    public var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    public let body = EmptyBody()
                }

                extension TraceBook: HttpRequest {
                }
                """,
            macros: ["Trace": TraceMacro.self]
        )
    }

    func testTraceMacroWithQueryProperties() {
        assertMacroExpansion(
            """
            @Trace("/books")
            struct TraceBook {
                @Query
                var maxHops: Int
            }
            """,
            expandedSource: """
                struct TraceBook {
                    var maxHops: Int

                    var _queryMaxHops: QueryParameter {
                        QueryParameter(key: "maxHops", value: maxHops)
                    }

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .trace

                    var queryParameters: [QueryParameter] {
                        [
                            _queryMaxHops
                        ]
                    }

                    let body = EmptyBody()
                }

                extension TraceBook: HttpRequest {
                }
                """,
            macros: ["Trace": TraceMacro.self, "Query": QueryMacro.self]
        )
    }

    func testTraceMacroWithPublicQueryProperties() {
        assertMacroExpansion(
            """
            @Trace("/books")
            public struct TraceBook {
                @Query
                var maxHops: Int
            }
            """,
            expandedSource: """
                public struct TraceBook {
                    var maxHops: Int

                    var _queryMaxHops: QueryParameter {
                        QueryParameter(key: "maxHops", value: maxHops)
                    }

                    typealias Response = Empty

                    public let path: String = "/books"

                    public let method: HttpMethod = .trace

                    public var queryParameters: [QueryParameter] {
                        [
                            _queryMaxHops
                        ]
                    }

                    public let body = EmptyBody()
                }

                extension TraceBook: HttpRequest {
                }
                """,
            macros: ["Trace": TraceMacro.self, "Query": QueryMacro.self]
        )
    }

    func testTraceMacroWithBodyExpansion() {
        assertMacroExpansion(
            """
            @Trace("/books")
            struct TraceBook {
                @Body
                struct TraceOptions {
                    let includeHeaders: Bool
                }
            }
            """,
            expandedSource: """
                struct TraceBook {
                    @Body
                    struct TraceOptions {
                        let includeHeaders: Bool
                    }

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .trace

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body: TraceOptions
                }

                extension TraceBook: HttpRequest {
                }
                """,
            macros: ["Trace": TraceMacro.self]
        )
    }

    func testTraceMacroWithExistingBodyProperty() {
        assertMacroExpansion(
            """
            @Trace("/books")
            struct TraceBook {
                let body: String = "existing body"
            }
            """,
            expandedSource: """
                struct TraceBook {
                    let body: String = "existing body"

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .trace

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                }

                extension TraceBook: HttpRequest {
                }
                """,
            macros: ["Trace": TraceMacro.self]
        )
    }

    func testTraceMacroWithResponseType() {
        assertMacroExpansion(
            """
            @Trace("/debug/trace", of: TraceResponse.self)
            struct DebugTrace {
            }
            """,
            expandedSource: """
                struct DebugTrace {

                    typealias Response = TraceResponse

                    let path: String = "/debug/trace"

                    let method: HttpMethod = .trace

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body = EmptyBody()
                }

                extension DebugTrace: HttpRequest {
                }
                """,
            macros: ["Trace": TraceMacro.self]
        )
    }

    func testTraceMacroWithResponseTypeAndPublicStruct() {
        assertMacroExpansion(
            """
            @Trace("/debug/trace", of: [TraceResponse].self)
            public struct DebugTrace {
                let body: TraceOptions
            }
            """,
            expandedSource: """
                public struct DebugTrace {
                    let body: TraceOptions

                    typealias Response = [TraceResponse]

                    public let path: String = "/debug/trace"

                    public let method: HttpMethod = .trace

                    public var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                }

                extension DebugTrace: HttpRequest {
                }
                """,
            macros: ["Trace": TraceMacro.self]
        )
    }
}
