import Testing
import SwiftUI
@testable import Cosmos

@Suite("Wave F Atoms")
struct CosmosWaveFAtomsTests {

    // MARK: - CosmosScrollAnchor selector enum

    @Test func scrollAnchorAllCases() {
        #expect(CosmosScrollAnchor.allCases == [.top, .bottom])
    }

    @Test func scrollAnchorStableIDs() {
        #expect(CosmosScrollAnchor.top.scrollID == "cosmos.scroll.top")
        #expect(CosmosScrollAnchor.bottom.scrollID == "cosmos.scroll.bottom")
    }

    @Test func scrollAnchorHashableSendable() {
        // Anchors are Hashable + Sendable value types — usable as scroll-target ids.
        let set: Set<CosmosScrollAnchor> = [.top, .top, .bottom]
        #expect(set == [.top, .bottom])
    }

    // MARK: - CosmosScrollAvailability (full modifier × platform matrix, Xcode 27 .swiftinterface)

    @Test func scrollDismissesKeyboardAvailableOffVisionOS() {
        // `.scrollDismissesKeyboard` + its `ScrollDismissesKeyboardMode` type are
        // `@available(visionOS, unavailable)` — available on the other four.
        #expect(CosmosScrollAvailability.scrollDismissesKeyboardAvailable(on: .ios))
        #expect(CosmosScrollAvailability.scrollDismissesKeyboardAvailable(on: .macos))
        #expect(CosmosScrollAvailability.scrollDismissesKeyboardAvailable(on: .tvos))
        #expect(CosmosScrollAvailability.scrollDismissesKeyboardAvailable(on: .watchos))
        #expect(!CosmosScrollAvailability.scrollDismissesKeyboardAvailable(on: .visionos))
    }

    @Test func scrollEdgeEffectStyleAvailableOffVisionOS() {
        // `.scrollEdgeEffectStyle` is floor-exact 26 on iOS/macOS/tvOS/watchOS and
        // `@available(visionOS, unavailable)` — the wrapper no-ops on visionOS.
        #expect(CosmosScrollAvailability.scrollEdgeEffectStyleAvailable(on: .ios))
        #expect(CosmosScrollAvailability.scrollEdgeEffectStyleAvailable(on: .macos))
        #expect(CosmosScrollAvailability.scrollEdgeEffectStyleAvailable(on: .tvos))
        #expect(CosmosScrollAvailability.scrollEdgeEffectStyleAvailable(on: .watchos))
        #expect(!CosmosScrollAvailability.scrollEdgeEffectStyleAvailable(on: .visionos))
    }
}