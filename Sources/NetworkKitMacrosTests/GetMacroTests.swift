//
//  GetMacroTests.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 17/07/2025.
//

import NetworkKitMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class GetMacroTests: XCTestCase {
    func testGetMacroExpansion() {
        assertMacroExpansion(
            """
            @Get("/books")
            struct GetBook {
            }
            """,
            expandedSource: """
                struct GetBook {

                    let path: String = "/books"

                    let method: HttpMethod = .get

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body = EmptyBody()
                }

                extension GetBook: HttpRequest {
                }
                """,
            macros: ["Get": GetMacro.self]
        )
    }

    func testGetMacroExpansionWithPublicStruct() {
        assertMacroExpansion(
            """
            @Get("/books")
            public struct GetBook {
            }
            """,
            expandedSource: """
                public struct GetBook {

                    public let path: String = "/books"

                    public let method: HttpMethod = .get

                    public var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    public let body = EmptyBody()
                }

                extension GetBook: HttpRequest {
                }
                """,
            macros: ["Get": GetMacro.self]
        )
    }

    func testGetMacroWithQueryProperties() {
        assertMacroExpansion(
            """
            @Get("/books")
            struct GetBook {
                @Query
                var search: String
                
                @Query("page_size")
                var pageSize: String
            }
            """,
            expandedSource: """
                struct GetBook {
                    var search: String

                    var _querySearch: QueryParameter {
                        QueryParameter(key: "search", value: search)
                    }

                    var pageSize: String

                    var _queryPageSize: QueryParameter {
                        QueryParameter(key: "page_size", value: pageSize)
                    }

                    let path: String = "/books"

                    let method: HttpMethod = .get

                    var queryParameters: [QueryParameter] {
                        [
                            _querySearch,
                            _queryPageSize
                        ]
                    }
                
                    let body = EmptyBody()
                }

                extension GetBook: HttpRequest {
                }
                """,
            macros: ["Get": GetMacro.self, "Query": QueryMacro.self]
        )
    }

    func testGetMacroWithPublicQueryProperties() {
        assertMacroExpansion(
            """
            @Get("/books")
            public struct GetBook {
                @Query
                var search: String
            }
            """,
            expandedSource: """
                public struct GetBook {
                    var search: String

                    var _querySearch: QueryParameter {
                        QueryParameter(key: "search", value: search)
                    }

                    public let path: String = "/books"

                    public let method: HttpMethod = .get

                    public var queryParameters: [QueryParameter] {
                        [
                            _querySearch
                        ]
                    }
                
                    public let body = EmptyBody()
                }

                extension GetBook: HttpRequest {
                }
                """,
            macros: ["Get": GetMacro.self, "Query": QueryMacro.self]
        )
    }

    func testGetMacroWithBodyExpansion() {
        assertMacroExpansion(
            """
            @Get("/books")
            struct GetBook {
                @Body
                struct BookFilter {
                    let category: String
                }
            }
            """,
            expandedSource: """
                struct GetBook {
                    @Body
                    struct BookFilter {
                        let category: String
                    }

                    let path: String = "/books"

                    let method: HttpMethod = .get

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body: BookFilter
                }

                extension GetBook: HttpRequest {
                }
                """,
            macros: ["Get": GetMacro.self]
        )
    }

    func testGetMacroWithExistingBodyProperty() {
        assertMacroExpansion(
            """
            @Get("/books")
            struct GetBook {
                let body: String = "existing body"
            }
            """,
            expandedSource: """
                struct GetBook {
                    let body: String = "existing body"

                    let path: String = "/books"

                    let method: HttpMethod = .get

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                }

                extension GetBook: HttpRequest {
                }
                """,
            macros: ["Get": GetMacro.self]
        )
    }
}
