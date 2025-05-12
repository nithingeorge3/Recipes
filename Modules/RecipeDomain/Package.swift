// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RecipeDomain",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "RecipeDomain",
            targets: ["RecipeDomain"]),
    ],
    targets: [
        .target(
            name: "RecipeDomain"),
        .testTarget(
            name: "RecipeDomainTests",
            dependencies: ["RecipeDomain"]
        ),
    ]
)
