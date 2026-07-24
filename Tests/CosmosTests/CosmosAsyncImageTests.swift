import Testing
import Foundation
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosAsyncImage")
struct CosmosAsyncImageTests {

    // MARK: - Construction

    @Test func asyncImageConstructsWithUrlAndContent() {
        _ = CosmosAsyncImage(url: URL(string: "https://example.com/image.png"),
                             content: { image in image })
    }

    @Test func asyncImageConstructsWithNilUrl() {
        // A nil URL routes to the placeholder slot; construction must not crash.
        _ = CosmosAsyncImage(url: nil, content: { image in image })
    }

    @Test func asyncImageConstructsWithCustomPlaceholderAndFailure() {
        // The `retry` closure is non-Sendable; do not send it into another view — exercise the
        // failure slot with a static view and ignore `retry` (its wiring is covered by previews).
        // Typed (non-AnyView) slot closures — the canonical generic form (WWDC21-10022 identity).
        _ = CosmosAsyncImage(
            url: URL(string: "https://example.com/image.png"),
            content: { image in image },
            placeholder: { CosmosText(verbatim: "Loading…") },
            failure: { _, _ in CosmosText(verbatim: "Failed to load") }
        )
    }

    // MARK: - CosmosImageCache (tuned URLSession + URLCache)

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