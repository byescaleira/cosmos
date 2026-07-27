import Testing
import Foundation
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosImage")
struct CosmosImageTests {

    // MARK: - Construction (static sources)

    @Test func imageConstructsFromSystemName() {
        _ = CosmosImage(systemName: "star.fill")
    }

    @Test func imageConstructsFromSystemNameAndVariableValue() {
        _ = CosmosImage(systemName: "chart.bar.fill", variableValue: 0.75)
    }

    @Test func imageConstructsFromDecorativeSystemName() {
        _ = CosmosImage(decorativeSystemName: "chevron.right")
    }

    // `init(_ resource: ImageResource)` is compile-verified only here: constructing an
    // `ImageResource` requires a codegen'd constant from an asset catalog, and Cosmos ships no
    // image assets (only a String Catalog). The init is part of the public surface and
    // type-checks on all 5 platforms at the `.v26` floor (iOS 17 / macOS 14 / tvOS 17 / watchOS 10 /
    // visionOS 1); consumers with asset catalogs construct it at runtime. No runtime construction
    // test is possible without shipping a bundled asset.

    @Test func imageConstructsFromBundledAssetName() {
        _ = CosmosImage("PlaceholderAsset", bundle: nil)
    }

    @Test func imageConstructsFromDecorativeBundledAsset() {
        _ = CosmosImage(decorative: "PlaceholderAsset", bundle: nil)
    }

    @Test func imageConstructsFromCustomContent() {
        _ = CosmosImage { Image(systemName: "sparkles") }
    }

    // MARK: - Construction (remote / URL)

    @Test func imageConstructsWithUrlAndContent() {
        _ = CosmosImage(url: URL(string: "https://example.com/image.png"),
                        content: { image in image })
    }

    @Test func imageConstructsWithNilUrl() {
        // A nil URL routes to the placeholder slot; construction must not crash.
        _ = CosmosImage(url: nil as URL?, content: { image in image })
    }

    @Test func imageConstructsWithStringUrl() {
        // A valid URL string parses and forwards to the typed URL init.
        _ = CosmosImage(url: "https://example.com/image.png", content: { image in image })
    }

    @Test func imageConstructsWithInvalidStringUrl() {
        // An unparseable string yields `URL(string:) == nil` → the placeholder slot, like a nil URL.
        _ = CosmosImage(url: "not a url", content: { image in image })
    }

    @Test func imageConstructsWithCustomPlaceholderAndFailure() {
        // The `retry` closure is non-Sendable; do not send it into another view — exercise the
        // failure slot with a static view and ignore `retry` (its wiring is covered by previews).
        // Typed (non-AnyView) slot closures — the canonical generic form (WWDC21-10022 identity).
        _ = CosmosImage(
            url: URL(string: "https://example.com/image.png"),
            content: { image in image },
            placeholder: { CosmosText(verbatim: "Loading…") },
            failure: { _, _ in CosmosText(verbatim: "Failed to load") }
        )
    }

    // MARK: - CosmosImageCache (tuned URLSession + URLCache; shared with CosmosAsyncImage)

    @Test func imageCacheDefaultSessionHasTunedURLCache() {
        let session = CosmosImageCache.defaultSession
        let cache = session.configuration.urlCache
        #expect(cache != nil)
        // Default sizing: 16 MB memory, 128 MB disk.
        #expect(cache?.memoryCapacity == 16 * 1024 * 1024)
        #expect(cache?.diskCapacity == 128 * 1024 * 1024)
    }

    @Test func imageCacheDefaultSessionTimeoutsConfigured() {
        let session = CosmosImageCache.defaultSession
        #expect(session.configuration.timeoutIntervalForRequest == 30)
        #expect(session.configuration.timeoutIntervalForResource == 60)
    }

    @Test func imageCacheCustomSizingHonored() {
        let session = CosmosImageCache.session(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 32 * 1024 * 1024)
        let cache = session.configuration.urlCache
        #expect(cache?.memoryCapacity == 4 * 1024 * 1024)
        #expect(cache?.diskCapacity == 32 * 1024 * 1024)
    }

    @Test func imageCacheDefaultSessionIsStableOnceToken() {
        // The `static let defaultSession` is a once-token (swift_once): the same instance is returned
        // across calls — no per-call allocation, no lock primitive.
        #expect(CosmosImageCache.defaultSession === CosmosImageCache.defaultSession)
    }

    // MARK: - CosmosAsyncImageAvailability (full platform matrix, Xcode 27 .swiftinterface)

    @Test func urlSessionInjectionAvailableOnAllPlatforms() {
        // `View.asyncImageURLSession(_:)` is `@available(anyAppleOS 27.0, *)` — no platform carve-out.
        // The table reports the platform gate only (true on all 5); the OS-27 version gate is runtime,
        // in `CosmosAsyncImageSessionApplier`.
        for platform in CosmosPlatform.allCases {
            #expect(CosmosAsyncImageAvailability.urlSessionInjectionAvailable(on: platform), "failed on \(platform)")
        }
    }
}