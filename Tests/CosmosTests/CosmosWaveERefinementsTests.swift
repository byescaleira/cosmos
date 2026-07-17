import Testing
import Foundation
import SwiftUI
@testable import Cosmos

@Suite("Wave E Refinements (PHASE3)")
struct CosmosWaveERefinementsTests {

    // MARK: - CosmosSlider iOS 26 cluster math (pure, no view rendering)

    @Test func sliderClampedToEnabledBoundsClampsOutsideRange() {
        // Below the enabled subrange → lower bound; above → upper bound; within → unchanged.
        #expect(CosmosSliderMath.clampedToEnabledBounds(0.1, enabled: 0.2...0.8) == 0.2)
        #expect(CosmosSliderMath.clampedToEnabledBounds(0.9, enabled: 0.2...0.8) == 0.8)
        #expect(CosmosSliderMath.clampedToEnabledBounds(0.5, enabled: 0.2...0.8) == 0.5)
        #expect(CosmosSliderMath.clampedToEnabledBounds(0.2, enabled: 0.2...0.8) == 0.2)
        #expect(CosmosSliderMath.clampedToEnabledBounds(0.8, enabled: 0.2...0.8) == 0.8)
    }

    @Test func sliderTickSnapAlignsToNearestTick() {
        // Nearest tick by absolute distance; empty → passthrough.
        #expect(CosmosSliderMath.tickSnap(value: 0.26, tickValues: [0.0, 0.25, 0.5, 0.75, 1.0]) == 0.25)
        #expect(CosmosSliderMath.tickSnap(value: 0.4, tickValues: [0.0, 0.25, 0.5, 0.75, 1.0]) == 0.5)
        #expect(CosmosSliderMath.tickSnap(value: 0.9, tickValues: [0.0, 0.25, 0.5, 0.75, 1.0]) == 1.0)
        #expect(CosmosSliderMath.tickSnap(value: 0.5, tickValues: []) == 0.5) // empty → unchanged
        // Unsorted input is tolerated (nearest by distance, not position).
        #expect(CosmosSliderMath.tickSnap(value: 0.6, tickValues: [0.75, 0.25, 0.5]) == 0.5)
    }

    // MARK: - CosmosSlider cluster availability (pure, host-agnostic)

    @Test func sliderClusterAvailableOnFourSliderPlatformsNotTvOS() {
        // iOS 26 Slider cluster: @available(iOS/macOS/watchOS/visionOS 26) @available(tvOS, unavailable).
        #expect(CosmosSliderClusterAvailability.isAvailable(on: .ios))
        #expect(CosmosSliderClusterAvailability.isAvailable(on: .macos))
        #expect(CosmosSliderClusterAvailability.isAvailable(on: .watchos))
        #expect(CosmosSliderClusterAvailability.isAvailable(on: .visionos))
        #expect(!CosmosSliderClusterAvailability.isAvailable(on: .tvos))
    }
}