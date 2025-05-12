// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RecipeNetworking",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "RecipeNetworking",
            targets: ["RecipeNetworking"]),
    ],
    dependencies: [
        .package(path: "../RecipeDomain")
    ],
    targets: [
        .target(
            name: "RecipeNetworking",
            dependencies: [
                .product(name: "RecipeDomain", package: "RecipeDomain")
            ],
            resources: [
                .process("Network/Mock/TestData")
            ]
        ),
        .testTarget(
            name: "RecipeNetworkingTests",
            dependencies: ["RecipeNetworking"]
        ),
    ]
)
