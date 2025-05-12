// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RecipeUI",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(name: "RecipeUI", targets: ["RecipeUI"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/onevcat/Kingfisher.git",
      from: "8.2.0"
    )
  ],
  targets: [
    .target(
      name: "RecipeUI",
      dependencies: [
        .product(name: "Kingfisher", package: "Kingfisher")
      ]
    ),
    .testTarget(
      name: "RecipeUITests",
      dependencies: ["RecipeUI"]
    ),
  ]
)
