//
//  PatchMacroTests.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 17/07/2025.
//

import NetworkKitMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class PatchMacroTests: XCTestCase {
    func testPatchMacroExpansion() {
        assertMacroExpansion(
            """
            @Patch("/books/1")
            struct PartialUpdateBook {
            }
            """,
            expandedSource: """
                struct PartialUpdateBook {

                    typealias Response = Empty

                    let path: String = "/books/1"

                    let method: HttpMethod = .patch

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body = EmptyBody()
                }

                extension PartialUpdateBook: HttpRequest {
                }
                """,
            macros: ["Patch": PatchMacro.self]
        )
    }

    func testPatchMacroExpansionWithPublicStruct() {
        assertMacroExpansion(
            """
            @Patch("/books/1")
            public struct PartialUpdateBook {
            }
            """,
            expandedSource: """
                public struct PartialUpdateBook {

                    public typealias Response = Empty

                    public let path: String = "/books/1"

                    public let method: HttpMethod = .patch

                    public var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    public let body = EmptyBody()
                }

                extension PartialUpdateBook: HttpRequest {
                }
                """,
            macros: ["Patch": PatchMacro.self]
        )
    }

    func testPatchMacroWithQueryProperties() {
        assertMacroExpansion(
            """
            @Patch("/books/1")
            struct PartialUpdateBook {
                @Query
                var force: Bool
            }
            """,
            expandedSource: """
                struct PartialUpdateBook {
                    var force: Bool

                    var _queryForce: QueryParameter {
                        QueryParameter(key: "force", value: force)
                    }

                    typealias Response = Empty

                    let path: String = "/books/1"

                    let method: HttpMethod = .patch

                    var queryParameters: [QueryParameter] {
                        [
                            _queryForce
                        ]
                    }

                    let body = EmptyBody()
                }

                extension PartialUpdateBook: HttpRequest {
                }
                """,
            macros: ["Patch": PatchMacro.self, "Query": QueryMacro.self]
        )
    }

    func testPatchMacroWithPublicQueryProperties() {
        assertMacroExpansion(
            """
            @Patch("/books/1")
            public struct PartialUpdateBook {
                @Query
                var force: Bool
            }
            """,
            expandedSource: """
                public struct PartialUpdateBook {
                    var force: Bool

                    var _queryForce: QueryParameter {
                        QueryParameter(key: "force", value: force)
                    }

                    public typealias Response = Empty

                    public let path: String = "/books/1"

                    public let method: HttpMethod = .patch

                    public var queryParameters: [QueryParameter] {
                        [
                            _queryForce
                        ]
                    }

                    public let body = EmptyBody()
                }

                extension PartialUpdateBook: HttpRequest {
                }
                """,
            macros: ["Patch": PatchMacro.self, "Query": QueryMacro.self]
        )
    }

    func testPatchMacroWithBodyExpansion() {
        assertMacroExpansion(
            """
            @Patch("/books/1")
            struct PartialUpdateBook {
                @Body
                struct BookPatch {
                    let name: String?
                }
            }
            """,
            expandedSource: """
                struct PartialUpdateBook {
                    @Body
                    struct BookPatch {
                        let name: String?
                    }

                    typealias Response = Empty

                    let path: String = "/books/1"

                    let method: HttpMethod = .patch

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body: BookPatch
                }

                extension PartialUpdateBook: HttpRequest {
                }
                """,
            macros: ["Patch": PatchMacro.self]
        )
    }

    func testPatchMacroWithExistingBodyProperty() {
        assertMacroExpansion(
            """
            @Patch("/books/1")
            struct PartialUpdateBook {
                let body: String = "existing body"
            }
            """,
            expandedSource: """
                struct PartialUpdateBook {
                    let body: String = "existing body"

                    typealias Response = Empty

                    let path: String = "/books/1"

                    let method: HttpMethod = .patch

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                }

                extension PartialUpdateBook: HttpRequest {
                }
                """,
            macros: ["Patch": PatchMacro.self]
        )
    }

    func testPatchMacroWithResponseType() {
        assertMacroExpansion(
            """
            @Patch("/books/:id")
            @Response(Book.self)
            struct PartialUpdateBook {
            }
            """,
            expandedSource: """
                struct PartialUpdateBook {

                    typealias Response = Book

                    let path: String = "/books/:id"

                    let method: HttpMethod = .patch

                    var queryParameters: [QueryParameter] {
                        [

                        ]
                    }

                    let body = EmptyBody()
                }

                extension PartialUpdateBook: HttpRequest {
                }
                """,
            macros: ["Patch": PatchMacro.self, "Response": ResponseMacro.self]
        )
    }

    func testPatchMacroWithResponseTypeAndPublicStruct() {
        assertMacroExpansion(
            """
            @Patch("/books/:id")
            @Response(Book.self)
            public struct PartialUpdateBook {
                let body: PatchRequest
            }
            """,
            expandedSource: """
                public struct PartialUpdateBook {
                    let body: PatchRequest

                    public typealias Response = Book

                    public let path: String = "/books/:id"

                    public let method: HttpMethod = .patch

                    public var queryParameters: [QueryParameter] {
                        [

                        ]
                    }
                }

                extension PartialUpdateBook: HttpRequest {
                }
                """,
            macros: ["Patch": PatchMacro.self, "Response": ResponseMacro.self]
        )
    }
}
