import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosSlider")
struct CosmosSliderTests {

    // MARK: - Construction (gated off tvOS — Slider unavailable there)

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func sliderConstructsWithCustomLabelAndValueLabels() {
        _ = CosmosSlider(value: .constant(0.5),
                         label: { Text(verbatim: "Slider") },
                         minimumValueLabel: { Text(verbatim: "0") },
                         maximumValueLabel: { Text(verbatim: "1") })
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func sliderConstructsWithLabelOnly() {
        _ = CosmosSlider(value: .constant(0.5), label: { Text(verbatim: "Slider") })
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func sliderConstructsWithNoLabels() {
        _ = CosmosSlider(value: .constant(0.5))
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func sliderConstructsFromLocalizedKeyAndStep() {
        _ = CosmosSlider("preview.title", value: .constant(0.5), step: 0.1)
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func sliderConstructsFromVerbatimTitle() {
        _ = CosmosSlider(verbatim: "Slider", value: .constant(0.5))
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func sliderConstructsClusterWithCurrentValueLabel() {
        _ = CosmosSlider(value: .constant(0.5),
                         label: { Text(verbatim: "Slider") },
                         currentValueLabel: { Text(verbatim: "50%") })
    }

    // MARK: - CosmosSliderMath stepping logic (pure helper, no view rendering)

    @Test func sliderSteppedValueQuantizesToStep() {
        // The quantizer aligns a raw value to the nearest step within bounds.
        #expect(CosmosSliderMath.stepped(value: 0.46, lower: 0, upper: 1, step: 0.1) == 0.5)
        #expect(CosmosSliderMath.stepped(value: 0.42, lower: 0, upper: 1, step: 0.1) == 0.4)
        #expect(CosmosSliderMath.stepped(value: 0.97, lower: 0, upper: 1, step: 0.25) == 1.0)
        #expect(CosmosSliderMath.stepped(value: 0.5, lower: 0, upper: 1, step: 0) == 0.5) // step 0 → passthrough
    }

    @Test func sliderSteppedValueClampsToBounds() {
        #expect(CosmosSliderMath.stepped(value: -0.3, lower: 0, upper: 1, step: 0.1) == 0.0)
        #expect(CosmosSliderMath.stepped(value: 1.3, lower: 0, upper: 1, step: 0.1) == 1.0)
        #expect(CosmosSliderMath.stepped(value: 12, lower: 0, upper: 10, step: 1) == 10)
    }

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