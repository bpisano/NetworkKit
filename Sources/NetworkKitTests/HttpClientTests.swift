//
//  HttpClientTests.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 07/07/2025.
//

import Foundation
import NetworkKit
import Testing

@Suite("HTTP Client")
struct HttpClientTests {
    let client = Client("https://dummyjson.com")

    @Test
    func testGetRequestWithPathParameter() async throws {
        let request = GetProductRequest(id: "1")
        let response = try await client.perform(request)
        let product: Product = response.data

        #expect(product.id == 1)
        #expect(product.title == "Essence Mascara Lash Princess")
        #expect(product.category == "beauty")
    }

    @Test
    func testGetRequestWithQueryParameters() async throws {
        let request = GetProductsRequest(limit: 3)
        let response = try await client.perform(request)
        let productList: ProductList = response.data

        #expect(productList.products.count == 3)
        #expect(productList.total >= 3)
    }

    @Test
    func testGetRequestWithNoParameters() async throws {
        let request = GetAllProductsRequest()
        let response = try await client.perform(request)
        let productList: ProductList = response.data

        #expect(productList.products.count == 30)  // Default limit
        #expect(productList.products.first?.id == 1)
        #expect(productList.products.last?.id == 30)
    }

    @Test
    func testPostRequestWithBody() async throws {
        let newProduct = CreateProductRequest(
            body: .init(
                title: "Test Product",
                description: "This is a test product description",
                price: 99.99,
                category: "electronics"
            )
        )
        let response = try await client.perform(newProduct)
        let product: Product = response.data

        #expect(product.id > 0)  // DummyJSON returns a new ID
        #expect(product.title == "Test Product")
        #expect(product.description == "This is a test product description")
        #expect(product.price == 99.99)
        #expect(product.category == "electronics")
    }

    @Test
    func testPutRequestWithPathParameterAndBody() async throws {
        let updateProduct = UpdateProductRequest(
            id: "1",
            body: .init(
                title: "Updated Product Title",
                description: "Updated product description",
                price: 149.99,
                category: "electronics"
            )
        )
        let response = try await client.perform(updateProduct)
        let product: Product = response.data

        #expect(product.id == 1)
        #expect(product.title == "Updated Product Title")
        #expect(product.description == "Updated product description")
        #expect(product.price == 149.99)
        #expect(product.category == "electronics")
    }

    @Test
    func testDeleteRequestWithPathParameter() async throws {
        let request = DeleteProductRequest(id: "1")
        let response = try await client.perform(request)
        let product: Product = response.data

        // DummyJSON returns the deleted product
        #expect(product.id == 1)
        #expect(product.isDeleted == true)
    }

    @Test
    func testGetRequestWithMixedPathAndQueryParameters() async throws {
        let request = GetProductsByCategoryRequest(category: "smartphones", limit: 5)
        let response = try await client.perform(request)
        let productList: ProductList = response.data

        #expect(productList.products.count == 5)
        #expect(productList.products.allSatisfy { $0.category == "smartphones" })
    }

    @Test
    func testGetRequestWithSpecialCharactersInQuery() async throws {
        let request = SearchProductsRequest(q: "phone")
        let response = try await client.perform(request)
        let productList: ProductList = response.data

        // DummyJSON should return products matching "phone"
        #expect(productList.products.count > 0)
        #expect(productList.total > 0)
    }

    @Test
    func testGetRequestWithNumericQueryParameters() async throws {
        let request = GetProductsWithPaginationRequest(skip: 10, limit: 10)
        let response = try await client.perform(request)
        let productList: ProductList = response.data

        #expect(productList.products.count == 10)
        #expect(productList.skip == 10)
        #expect(productList.limit == 10)
    }

    @Test
    func testGetRequestWithBooleanQueryParameters() async throws {
        let request = GetProductsWithFiltersRequest(select: "title,price,category")
        let response = try await client.perform(request)
        let productList: ProductList = response.data

        // DummyJSON should return products with only selected fields
        #expect(productList.products.count > 0)
    }

    @Test
    func testRawDataResponse() async throws {
        let request = GetProductRequest(id: "1")
        let response: Response<Data> = try await client.performRaw(request)

        #expect(!response.data.isEmpty)

        // Verify we can decode the data
        let product = try JSONDecoder().decode(Product.self, from: response.data)
        #expect(product.id == 1)
    }

    @Test
    func testVoidResponse() async throws {
        let request = DeleteProductRequest(id: "1")
        let response = try await client.perform(request)

        // Should complete without throwing and return the deleted product
        #expect(response.statusCode == 200)
    }

    @Test
    func testCustomJSONEncoder() async throws {
        let customClient = client
        customClient.encoder.keyEncodingStrategy = .convertToSnakeCase
        customClient.decoder.keyDecodingStrategy = .convertFromSnakeCase

        let request = GetProductRequest(id: "1")
        let response = try await customClient.perform(request)
        let product: Product = response.data

        #expect(product.id == 1)
    }
}

// MARK: - Request Types

@Get("/products/:id")
@Response(Product.self)
private struct GetProductRequest {
    @Path
    var id: String
}

@Get("/products")
@Response(ProductList.self)
private struct GetAllProductsRequest {
}

@Get("/products")
@Response(ProductList.self)
private struct GetProductsRequest {
    @Query
    var limit: Int
}

@Get("/products/category/:category")
@Response(ProductList.self)
private struct GetProductsByCategoryRequest {
    @Path
    var category: String

    @Query
    var limit: Int
}

@Get("/products/search")
@Response(ProductList.self)
private struct SearchProductsRequest {
    @Query
    var q: String
}

@Get("/products")
@Response(ProductList.self)
private struct GetProductsWithPaginationRequest {
    @Query
    var skip: Int

    @Query
    var limit: Int
}

@Get("/products")
@Response(ProductList.self)
private struct GetProductsWithFiltersRequest {
    @Query
    var select: String
}

@Post("/products/add")
@Response(Product.self)
private struct CreateProductRequest {
    @Body
    struct Body {
        let title: String
        let description: String
        let price: Double
        let category: String
    }
}

@Put("/products/:id")
@Response(Product.self)
private struct UpdateProductRequest {
    @Path
    var id: String

    @Body
    struct Body {
        let title: String
        let description: String
        let price: Double
        let category: String
    }
}

@Delete("/products/:id")
@Response(Product.self)
private struct DeleteProductRequest {
    @Path
    var id: String
}

// MARK: - Response Models

private struct Product: Codable, Equatable {
    let id: Int
    let title: String
    let description: String?
    let price: Double
    let category: String
    let stock: Int?
    let isDeleted: Bool?
}

private struct ProductList: Codable, Equatable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}
