//
//  PathBuilderTests.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 07/07/2025.
//

import Foundation
import Testing

@testable import NetworkKit

@Suite("Path Builder")
struct PathBuilderTests {
    @Test
    func testPathBuilderWithSinglePathParameter() throws {
        let request = TestRequestWithSinglePath(id: "123")
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(url: URL(string: "https://api.example.com/books/:id")!)

        try pathBuilder.modify(&urlRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/books/123")
    }

    @Test
    func testPathBuilderWithMultiplePathParameters() throws {
        let request = TestRequestWithMultiplePaths(userId: "456", bookId: "789")
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(
            url: URL(string: "https://api.example.com/users/:userId/books/:bookId")!)

        try pathBuilder.modify(&urlRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/users/456/books/789")
    }

    @Test
    func testPathBuilderWithNoPathParameters() throws {
        let request = TestRequestWithNoPaths()
        let pathBuilder = PathBuilder(request: request)
        let originalURL = URL(string: "https://api.example.com/books")!
        var urlRequest = URLRequest(url: originalURL)

        try pathBuilder.modify(&urlRequest)

        #expect(urlRequest.url?.absoluteString == originalURL.absoluteString)
    }

    @Test
    func testPathBuilderWithMixedProperties() throws {
        let request = TestRequestWithMultiplePaths(userId: "999", bookId: "dummy")
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(url: URL(string: "https://api.example.com/users/:userId")!)

        try pathBuilder.modify(&urlRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/users/999")
    }

    @Test
    func testPathBuilderWithEmptyPathValue() throws {
        let request = TestRequestWithSinglePath(id: "")
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(url: URL(string: "https://api.example.com/books/:id")!)

        try pathBuilder.modify(&urlRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/books/")
    }

    @Test
    func testPathBuilderWithSpecialCharacters() throws {
        let request = TestRequestWithSinglePath(id: "hello%20world")
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(url: URL(string: "https://api.example.com/search/:id")!)

        try pathBuilder.modify(&urlRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/search/hello%2520world")
    }

    // MARK: - Custom Path Key Tests

    @Test
    func testPathBuilderWithCustomPathKey() throws {
        let request = TestRequestWithCustomPathKey(identifier: "custom123")
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(url: URL(string: "https://api.example.com/items/:itemId")!)

        try pathBuilder.modify(&urlRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/items/custom123")
    }

    @Test
    func testPathBuilderWithMultipleCustomPathKeys() throws {
        let request = TestRequestWithMultipleCustomPathKeys(
            userIdentifier: "user456",
            documentIdentifier: "doc789"
        )
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(
            url: URL(string: "https://api.example.com/users/:userId/documents/:docId")!)

        try pathBuilder.modify(&urlRequest)

        #expect(
            urlRequest.url?.absoluteString
                == "https://api.example.com/users/user456/documents/doc789")
    }

    // MARK: - PathRepresentable Types Tests

    @Test
    func testPathBuilderWithStringTypes() throws {
        let request = TestRequestWithStringTypes(
            regularString: "hello",
            substring: "world"[...],
            character: "x"
        )
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(
            url: URL(string: "https://api.example.com/:regularString/:substring/:character")!)

        try pathBuilder.modify(&urlRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/hello/world/x")
    }

    @Test
    func testPathBuilderWithSignedIntegerTypes() throws {
        let request = TestRequestWithSignedIntegers(
            regularInt: 42,
            int8Value: Int8(8),
            int16Value: Int16(16),
            int32Value: Int32(32),
            int64Value: Int64(64)
        )
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(
            url: URL(
                string:
                    "https://api.example.com/:regularInt/:int8Value/:int16Value/:int32Value/:int64Value"
            )!)

        try pathBuilder.modify(&urlRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/42/8/16/32/64")
    }

    @Test
    func testPathBuilderWithUnsignedIntegerTypes() throws {
        let request = TestRequestWithUnsignedIntegers(
            uintValue: UInt(100),
            uint8Value: UInt8(8),
            uint16Value: UInt16(16),
            uint32Value: UInt32(32),
            uint64Value: UInt64(64)
        )
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(
            url: URL(
                string:
                    "https://api.example.com/:uintValue/:uint8Value/:uint16Value/:uint32Value/:uint64Value"
            )!)

        try pathBuilder.modify(&urlRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/100/8/16/32/64")
    }

    @Test
    func testPathBuilderWithFloatingPointTypes() throws {
        let request = TestRequestWithFloatingPoint(
            floatValue: 3.14,
            doubleValue: 2.71828,
            decimalValue: Decimal(string: "123.456")!
        )
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(
            url: URL(string: "https://api.example.com/:floatValue/:doubleValue/:decimalValue")!)

        try pathBuilder.modify(&urlRequest)

        let url = urlRequest.url?.absoluteString ?? ""
        #expect(url.contains("3.14"))
        #expect(url.contains("2.71828"))
        #expect(url.contains("123.456"))
    }

    @Test
    func testPathBuilderWithBooleanType() throws {
        let request = TestRequestWithBoolean(
            isActive: true,
            isEnabled: false
        )
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(
            url: URL(string: "https://api.example.com/:isActive/:isEnabled")!)

        try pathBuilder.modify(&urlRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/true/false")
    }

    @Test
    func testPathBuilderWithFoundationTypes() throws {
        let uuid = UUID()
        let date = Date(timeIntervalSince1970: 1_609_459_200)  // 2021-01-01
        let url = URL(string: "https://example.com")!
        let nsNumber = NSNumber(value: 42)

        let request = TestRequestWithFoundationTypes(
            uuidValue: uuid,
            dateValue: date,
            urlValue: url,
            numberValue: nsNumber
        )
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(
            url: URL(
                string: "https://api.example.com/:uuidValue/:dateValue/:urlValue/:numberValue")!)

        try pathBuilder.modify(&urlRequest)

        let resultURL = urlRequest.url?.absoluteString ?? ""
        #expect(resultURL.contains(uuid.uuidString))
        #expect(resultURL.contains("1609459200"))
        #expect(resultURL.contains("https://example.com"))
        #expect(resultURL.contains("42"))
    }

    @Test
    func testPathBuilderWithArrayTypes() throws {
        let request = TestRequestWithArrayTypes(
            stringArray: ["apple", "banana", "cherry"],
            intArray: [1, 2, 3, 4, 5],
            mixedArray: [true, false]
        )
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(
            url: URL(string: "https://api.example.com/:stringArray/:intArray/:mixedArray")!)

        try pathBuilder.modify(&urlRequest)

        #expect(
            urlRequest.url?.absoluteString
                == "https://api.example.com/apple,banana,cherry/1,2,3,4,5/true,false")
    }

    @Test
    func testPathBuilderWithEmptyArray() throws {
        let request = TestRequestWithEmptyArray(emptyArray: [])
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(url: URL(string: "https://api.example.com/:emptyArray")!)

        try pathBuilder.modify(&urlRequest)

        #expect(urlRequest.url?.absoluteString == "https://api.example.com/")
    }

    @Test
    func testPathBuilderWithComplexMixedTypes() throws {
        let request = TestRequestWithMixedTypes(
            id: 123,
            name: "product",
            isActive: true,
            tags: ["electronics", "gadget"],
            price: 99.99
        )
        let pathBuilder = PathBuilder(request: request)
        var urlRequest = URLRequest(
            url: URL(string: "https://api.example.com/products/:id/:name/:isActive/:tags/:price")!)

        try pathBuilder.modify(&urlRequest)

        #expect(
            urlRequest.url?.absoluteString
                == "https://api.example.com/products/123/product/true/electronics,gadget/99.99")
    }
}

// MARK: - Test Request Types

@Get("/books/:id")
private struct TestRequestWithSinglePath {
    @Path
    var id: String
}

@Get("/users/:userId/books/:bookId")
private struct TestRequestWithMultiplePaths {
    @Path
    var userId: String

    @Path
    var bookId: String
}

@Get("/books")
private struct TestRequestWithNoPaths {
    let title = "Test Book"
    let author = "Test Author"
}

// MARK: - Custom Path Key Test Types

@Get("/items/:itemId")
private struct TestRequestWithCustomPathKey {
    @Path("itemId")
    var identifier: String
}

@Get("/users/:userId/documents/:docId")
private struct TestRequestWithMultipleCustomPathKeys {
    @Path("userId")
    var userIdentifier: String

    @Path("docId")
    var documentIdentifier: String
}

// MARK: - PathRepresentable Types Test Structs

@Get("/:regularString/:substring/:character")
private struct TestRequestWithStringTypes {
    @Path
    var regularString: String

    @Path
    var substring: Substring

    @Path
    var character: Character
}

@Get("/:regularInt/:int8Value/:int16Value/:int32Value/:int64Value")
private struct TestRequestWithSignedIntegers {
    @Path
    var regularInt: Int

    @Path
    var int8Value: Int8

    @Path
    var int16Value: Int16

    @Path
    var int32Value: Int32

    @Path
    var int64Value: Int64
}

@Get("/:uintValue/:uint8Value/:uint16Value/:uint32Value/:uint64Value")
private struct TestRequestWithUnsignedIntegers {
    @Path
    var uintValue: UInt

    @Path
    var uint8Value: UInt8

    @Path
    var uint16Value: UInt16

    @Path
    var uint32Value: UInt32

    @Path
    var uint64Value: UInt64
}

@Get("/:floatValue/:doubleValue/:decimalValue")
private struct TestRequestWithFloatingPoint {
    @Path
    var floatValue: Float

    @Path
    var doubleValue: Double

    @Path
    var decimalValue: Decimal
}

@Get("/:isActive/:isEnabled")
private struct TestRequestWithBoolean {
    @Path
    var isActive: Bool

    @Path
    var isEnabled: Bool
}

@Get("/:uuidValue/:dateValue/:urlValue/:numberValue")
private struct TestRequestWithFoundationTypes {
    @Path
    var uuidValue: UUID

    @Path
    var dateValue: Date

    @Path
    var urlValue: URL

    @Path
    var numberValue: NSNumber
}

@Get("/:strings/:ints/:bools")
private struct TestRequestWithArrayTypes {
    @Path
    var stringArray: [String]

    @Path
    var intArray: [Int]

    @Path
    var mixedArray: [Bool]
}

@Get("/:empty")
private struct TestRequestWithEmptyArray {
    @Path
    var emptyArray: [String]
}

@Get("/products/:id/:name/:active/:tags/:price")
private struct TestRequestWithMixedTypes {
    @Path
    var id: Int

    @Path
    var name: String

    @Path
    var isActive: Bool

    @Path
    var tags: [String]

    @Path
    var price: Double
}
