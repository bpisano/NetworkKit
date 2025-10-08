//
//  PostMacroTests.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 17/07/2025.
//

import NetworkKitMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class PostMacroTests: XCTestCase {
    func testPostMacroExpansion() {
        assertMacroExpansion(
            """
            @Post("/books")
            struct CreateBook {
            }
            """,
            expandedSource: """
                struct CreateBook {

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .post

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body = EmptyBody()
                }

                extension CreateBook: HttpRequest {
                }
                """,
            macros: ["Post": PostMacro.self]
        )
    }

    func testPostMacroExpansionWithPublicStruct() {
        assertMacroExpansion(
            """
            @Post("/books")
            public struct CreateBook {
            }
            """,
            expandedSource: """
                public struct CreateBook {

                    public typealias Response = Empty

                    public let path: String = "/books"

                    public let method: HttpMethod = .post

                    public var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    public let body = EmptyBody()
                }

                extension CreateBook: HttpRequest {
                }
                """,
            macros: ["Post": PostMacro.self]
        )
    }

    func testPostMacroWithQueryProperties() {
        assertMacroExpansion(
            """
            @Post("/books")
            struct CreateBook {
                @Query
                var force: Bool
            }
            """,
            expandedSource: """
                struct CreateBook {
                    var force: Bool

                    var _queryForce: QueryParameter {
                        QueryParameter(key: "force", value: force)
                    }

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .post

                    var queryParameters: [QueryParameter] {
                        [
                            _queryForce
                        ]
                    }

                    let body = EmptyBody()
                }

                extension CreateBook: HttpRequest {
                }
                """,
            macros: ["Post": PostMacro.self, "Query": QueryMacro.self]
        )
    }

    func testPostMacroWithPublicQueryProperties() {
        assertMacroExpansion(
            """
            @Post("/books")
            public struct CreateBook {
                @Query
                var force: Bool
            }
            """,
            expandedSource: """
                public struct CreateBook {
                    var force: Bool

                    var _queryForce: QueryParameter {
                        QueryParameter(key: "force", value: force)
                    }

                    public typealias Response = Empty

                    public let path: String = "/books"

                    public let method: HttpMethod = .post

                    public var queryParameters: [QueryParameter] {
                        [
                            _queryForce
                        ]
                    }

                    public let body = EmptyBody()
                }

                extension CreateBook: HttpRequest {
                }
                """,
            macros: ["Post": PostMacro.self, "Query": QueryMacro.self]
        )
    }

    func testPostMacroWithBodyExpansion() {
        assertMacroExpansion(
            """
            @Post("/books")
            struct CreateBook {
                @Body
                struct Book {
                    let name: String
                }
            }
            """,
            expandedSource: """
                struct CreateBook {
                    @Body
                    struct Book {
                        let name: String
                    }

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .post

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body: Book
                }

                extension CreateBook: HttpRequest {
                }
                """,
            macros: ["Post": PostMacro.self]
        )
    }

    func testPostMacroWithExistingBodyProperty() {
        assertMacroExpansion(
            """
            @Post("/books")
            struct CreateBook {
                let body: String = "existing body"
            }
            """,
            expandedSource: """
                struct CreateBook {
                    let body: String = "existing body"

                    typealias Response = Empty

                    let path: String = "/books"

                    let method: HttpMethod = .post

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                }

                extension CreateBook: HttpRequest {
                }
                """,
            macros: ["Post": PostMacro.self]
        )
    }

    func testPostMacroWithResponseType() {
        assertMacroExpansion(
            """
            @Post("/books")
            @Response(Book.self)
            struct CreateBook {
            }
            """,
            expandedSource: """
                struct CreateBook {

                    typealias Response = Book

                    let path: String = "/books"

                    let method: HttpMethod = .post

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body = EmptyBody()
                }

                extension CreateBook: HttpRequest {
                }
                """,
            macros: ["Post": PostMacro.self, "Response": ResponseMacro.self]
        )
    }

    func testPostMacroWithResponseTypeAndPublicStruct() {
        assertMacroExpansion(
            """
            @Post("/books")
            @Response([Book].self)
            public struct CreateBooks {
            }
            """,
            expandedSource: """
                public struct CreateBooks {

                    public typealias Response = [Book]

                    public let path: String = "/books"

                    public let method: HttpMethod = .post

                    public var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    public let body = EmptyBody()
                }

                extension CreateBooks: HttpRequest {
                }
                """,
            macros: ["Post": PostMacro.self, "Response": ResponseMacro.self]
        )
    }

    func testPostMacroWithResponseTypeAndBodyProperty() {
        assertMacroExpansion(
            """
            @Post("/books")
            @Response(Book.self)
            struct CreateBook {
                let body: CreateBookRequest
            }
            """,
            expandedSource: """
                struct CreateBook {
                    let body: CreateBookRequest

                    typealias Response = Book

                    let path: String = "/books"

                    let method: HttpMethod = .post

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                }

                extension CreateBook: HttpRequest {
                }
                """,
            macros: ["Post": PostMacro.self, "Response": ResponseMacro.self]
        )
    }
}
