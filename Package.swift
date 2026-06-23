// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cosmos",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .macCatalyst(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Cosmos",
            targets: ["Cosmos"]
        ),
        .library(
            name: "CosmosBase",
            targets: ["CosmosBase"]
        ),
        .library(
            name: "CosmosScreen",
            targets: ["CosmosScreen"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CosmosBase",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "Cosmos",
            dependencies: ["CosmosBase"]
        ),
        .target(
            name: "CosmosScreen",
            dependencies: ["Cosmos", "CosmosBase"]
        ),
        .testTarget(
            name: "CosmosTests",
            dependencies: ["Cosmos", "CosmosBase"]
        )
    ],
    swiftLanguageModes: [.v6]
)
