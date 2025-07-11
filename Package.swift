// swift-tools-version: 6.1

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "NetworkKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "601.0.1")
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: ["NetworkKitMacros"]
        ),
        .macro(
            name: "NetworkKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "NetworkKitMacrosTests",
            dependencies: [
                .target(name: "NetworkKitMacros"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: ["NetworkKit"]
        ),
    ],
)
