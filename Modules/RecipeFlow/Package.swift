// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RecipeFlow",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(name: "RecipeFlow", targets: ["RecipeFlow"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/onevcat/Kingfisher.git",
      from: "8.2.0"
    ),
    .package(path: "../RecipeDomain"),
    .package(path: "../RecipeNetworking"),
    .package(path: "../RecipeDataStore"),
    .package(path: "../RecipeUI")
  ],
  targets: [
    .target(
      name: "RecipeFlow",
      dependencies: [
        .product(name: "Kingfisher", package: "Kingfisher"),
        .product(name: "RecipeDomain", package: "RecipeDomain"),
        .product(name: "RecipeDataStore", package: "RecipeDataStore"),
        .product(name: "RecipeNetworking", package: "RecipeNetworking"),
        .product(name: "RecipeUI", package: "RecipeUI")
      ]
    ),
    .testTarget(
      name: "RecipeFlowTests",
      dependencies: ["RecipeFlow"]
    ),
  ]
)
