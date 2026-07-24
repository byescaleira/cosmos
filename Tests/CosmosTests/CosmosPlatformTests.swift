import Testing
@testable import Cosmos

@Suite("CosmosPlatform")
struct CosmosPlatformTests {

    @Test func platformAllCases() {
        #expect(CosmosPlatform.allCases == [.ios, .macos, .watchos, .visionos, .tvos])
    }

    @Test func platformCurrentIsHost() {
        // The test host is macOS — `current` must resolve to the compile-time host.
        #expect(CosmosPlatform.current == .macos)
    }
}