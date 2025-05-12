// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RecipeDataStore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "RecipeDataStore",
            targets: ["RecipeDataStore"]),
    ],
    dependencies: [
        .package(path: "../RecipeNetworking")
    ],
    targets: [
        .target(
            name: "RecipeDataStore",
            dependencies: [
                .product(name: "RecipeNetworking", package: "RecipeNetworking")
            ]
        ),
        .testTarget(
            name: "RecipeDataStoreTests",
            dependencies: ["RecipeDataStore"]
        ),
    ]
)
