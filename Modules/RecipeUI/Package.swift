// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "RecipeDomain", // Change per module
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "RecipeDomain",
            targets: ["RecipeDomain"]
        )
    ],
    dependencies: [
        // Shared dependencies only
        .package(
            url: "https://github.com/onevcat/Kingfisher.git",
            from: "7.0.0"
        )
    ],
    targets: [
        .target(
            name: "RecipeDomain",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher")
            ],
            linkerSettings: [
                .linkedFramework("UIKit")
            ]
        )
    ]
)
