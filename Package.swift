// swift-tools-version: 6.4
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
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Cosmos",
            targets: ["Cosmos"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Cosmos",
            dependencies: [],
            resources: [
                // .process compiles Localizable.xcstrings → .lproj/.strings at runtime
                // and copies the bundled .ttf fonts into the module bundle.
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "CosmosTests",
            dependencies: ["Cosmos"]
        ),
    ],
    swiftLanguageModes: [.v6]
)