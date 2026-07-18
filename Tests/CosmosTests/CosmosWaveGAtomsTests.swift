import Testing
import Foundation
@testable import Cosmos

@Suite("Wave G Atoms")
struct CosmosWaveGAtomsTests {

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