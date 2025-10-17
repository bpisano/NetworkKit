//
//  DeleteMacroTests.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 17/07/2025.
//

import NetworkKitMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class DeleteMacroTests: XCTestCase {
    func testDeleteMacroExpansion() {
        assertMacroExpansion(
            """
            @Delete("/books/1")
            struct DeleteBook {
            }
            """,
            expandedSource: """
                struct DeleteBook {

                    typealias Response = Empty

                    let path: String = "/books/1"

                    let method: HttpMethod = .delete

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                
                    var pathParameters: [PathParameter] {
                        [
                
                        ]
                    }

                    let body = EmptyBody()
                }

                extension DeleteBook: HttpRequest {
                }
                """,
            macros: ["Delete": DeleteMacro.self]
        )
    }

    func testDeleteMacroExpansionWithPublicStruct() {
        assertMacroExpansion(
            """
            @Delete("/books/1")
            public struct DeleteBook {
            }
            """,
            expandedSource: """
                public struct DeleteBook {

                    public typealias Response = Empty

                    public let path: String = "/books/1"

                    public let method: HttpMethod = .delete

                    public var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                
                    public var pathParameters: [PathParameter] {
                        [
                
                        ]
                    }

                    public let body = EmptyBody()
                }

                extension DeleteBook: HttpRequest {
                }
                """,
            macros: ["Delete": DeleteMacro.self]
        )
    }

    func testDeleteMacroWithQueryProperties() {
        assertMacroExpansion(
            """
            @Delete("/books/1")
            struct DeleteBook {
                @Query
                var force: Bool
            }
            """,
            expandedSource: """
                struct DeleteBook {
                    var force: Bool

                    var _queryForce: QueryParameter {
                        QueryParameter(key: "force", value: force)
                    }

                    typealias Response = Empty

                    let path: String = "/books/1"

                    let method: HttpMethod = .delete

                    var queryParameters: [QueryParameter] {
                        [
                            _queryForce
                        ]
                    }
                
                    var pathParameters: [PathParameter] {
                        [
                
                        ]
                    }

                    let body = EmptyBody()
                }

                extension DeleteBook: HttpRequest {
                }
                """,
            macros: ["Delete": DeleteMacro.self, "Query": QueryMacro.self]
        )
    }

    func testDeleteMacroWithPublicQueryProperties() {
        assertMacroExpansion(
            """
            @Delete("/books/1")
            public struct DeleteBook {
                @Query
                var force: Bool
            }
            """,
            expandedSource: """
                public struct DeleteBook {
                    var force: Bool

                    var _queryForce: QueryParameter {
                        QueryParameter(key: "force", value: force)
                    }

                    public typealias Response = Empty

                    public let path: String = "/books/1"

                    public let method: HttpMethod = .delete

                    public var queryParameters: [QueryParameter] {
                        [
                            _queryForce
                        ]
                    }
                
                    public var pathParameters: [PathParameter] {
                        [
                
                        ]
                    }

                    public let body = EmptyBody()
                }

                extension DeleteBook: HttpRequest {
                }
                """,
            macros: ["Delete": DeleteMacro.self, "Query": QueryMacro.self]
        )
    }

    func testDeleteMacroWithBodyExpansion() {
        assertMacroExpansion(
            """
            @Delete("/books/1")
            struct DeleteBook {
                @Body
                struct DeleteOptions {
                    let force: Bool
                }
            }
            """,
            expandedSource: """
                struct DeleteBook {
                    @Body
                    struct DeleteOptions {
                        let force: Bool
                    }

                    typealias Response = Empty

                    let path: String = "/books/1"

                    let method: HttpMethod = .delete

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                
                    var pathParameters: [PathParameter] {
                        [
                
                        ]
                    }

                    let body: DeleteOptions
                }

                extension DeleteBook: HttpRequest {
                }
                """,
            macros: ["Delete": DeleteMacro.self]
        )
    }

    func testDeleteMacroWithExistingBodyProperty() {
        assertMacroExpansion(
            """
            @Delete("/books/1")
            struct DeleteBook {
                let body: String = "existing body"
            }
            """,
            expandedSource: """
                struct DeleteBook {
                    let body: String = "existing body"

                    typealias Response = Empty

                    let path: String = "/books/1"

                    let method: HttpMethod = .delete

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                
                    var pathParameters: [PathParameter] {
                        [
                
                        ]
                    }
                }

                extension DeleteBook: HttpRequest {
                }
                """,
            macros: ["Delete": DeleteMacro.self]
        )
    }

    func testDeleteMacroWithResponseType() {
        assertMacroExpansion(
            """
            @Delete("/books/:id")
            @Response(DeleteResponse.self)
            struct DeleteBook {
            }
            """,
            expandedSource: """
                @Response(DeleteResponse.self)
                struct DeleteBook {

                    typealias Response = DeleteResponse

                    let path: String = "/books/:id"

                    let method: HttpMethod = .delete

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                
                    var pathParameters: [PathParameter] {
                        [
                
                        ]
                    }

                    let body = EmptyBody()
                }

                extension DeleteBook: HttpRequest {
                }
                """,
            macros: ["Delete": DeleteMacro.self]
        )
    }

    func testDeleteMacroWithResponseTypeOnly() {
        assertMacroExpansion(
            """
            @Delete("/books")
            @Response([DeleteResponse].self)
            struct DeleteAllBooks {
            }
            """,
            expandedSource: """
                struct DeleteAllBooks {

                    typealias Response = [DeleteResponse]

                    let path: String = "/books"

                    let method: HttpMethod = .delete

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                
                    var pathParameters: [PathParameter] {
                        [
                
                        ]
                    }

                    let body = EmptyBody()
                }

                extension DeleteAllBooks: HttpRequest {
                }
                """,
            macros: ["Delete": DeleteMacro.self, "Response": ResponseMacro.self]
        )
    }
}
