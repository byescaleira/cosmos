// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Set to 6.3 (Xcode 26 / Swift 6.3) so the package builds on both Xcode 26 (hosted CI runners) and
// Xcode 27 (dev baseline, Swift 6.4). OS-27-only SDK symbols (`.tabs` PickerStyle,
// `TabRole.prominent`, `BorderedTextFieldStyle`) are compile-gated with `#if swift(>=6.4)` so
// they compile to a graceful fallback on Swift 6.3 and turn on under Xcode 27 / Swift 6.4.

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
                // .process compiles Localizable.xcstrings → .lproj/.strings at runtime.
                // Cosmos ships no bundled fonts; bring your own and pass the PostScript name
                // to CosmosTheme.withCustomFont(_:).
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