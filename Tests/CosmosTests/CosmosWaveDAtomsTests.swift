import Testing
import SwiftUI
@testable import Cosmos

@Suite("Wave D Atoms")
struct CosmosWaveDAtomsTests {

    // MARK: - Style selector enums

    @Test func textFieldStyleAllCases() {
        #expect(CosmosTextFieldStyle.allCases == [.automatic, .plain, .bordered, .cosmos])
    }

    @Test func textEditorStyleAllCases() {
        #expect(CosmosTextEditorStyle.allCases == [.automatic, .plain, .roundedBorder])
    }

    // MARK: - CosmosTextEditorAvailability (full style × platform matrix)

    @Test func textEditorAvailabilityTvOSWatchOSAlwaysFalse() {
        // TextEditorStyle is unavailable on tvOS/watchOS — every style must be false there.
        for style in CosmosTextEditorStyle.allCases {
            #expect(CosmosTextEditorAvailability.isAvailable(style, on: .tvos) == false)
            #expect(CosmosTextEditorAvailability.isAvailable(style, on: .watchos) == false)
        }
    }

    @Test func textEditorAvailabilityIOS() {
        #expect(CosmosTextEditorAvailability.isAvailable(.automatic, on: .ios))
        #expect(CosmosTextEditorAvailability.isAvailable(.plain, on: .ios))
        #expect(!CosmosTextEditorAvailability.isAvailable(.roundedBorder, on: .ios)) // visionOS-only
    }

    @Test func textEditorAvailabilityMacOS() {
        #expect(CosmosTextEditorAvailability.isAvailable(.automatic, on: .macos))
        #expect(CosmosTextEditorAvailability.isAvailable(.plain, on: .macos))
        #expect(!CosmosTextEditorAvailability.isAvailable(.roundedBorder, on: .macos)) // visionOS-only
    }

    @Test func textEditorAvailabilityVisionOS() {
        #expect(CosmosTextEditorAvailability.isAvailable(.automatic, on: .visionos))
        #expect(CosmosTextEditorAvailability.isAvailable(.plain, on: .visionos))
        #expect(CosmosTextEditorAvailability.isAvailable(.roundedBorder, on: .visionos)) // visionOS-only
    }

    @Test func textEditorResolveFallsBackToAutomatic() {
        // An unavailable requested style resolves to .automatic; an available one resolves to itself.
        #expect(CosmosTextEditorAvailability.resolve(.roundedBorder, on: .ios) == .automatic)
        #expect(CosmosTextEditorAvailability.resolve(.roundedBorder, on: .macos) == .automatic)
        #expect(CosmosTextEditorAvailability.resolve(.roundedBorder, on: .tvos) == .automatic)
        #expect(CosmosTextEditorAvailability.resolve(.plain, on: .ios) == .plain)
        #expect(CosmosTextEditorAvailability.resolve(.automatic, on: .visionos) == .automatic)
        #expect(CosmosTextEditorAvailability.resolve(.roundedBorder, on: .visionos) == .roundedBorder)
    }

    // MARK: - Theme selectors (defaults + fluent builders)

    @Test func themeDefaultsForWaveDSelectors() {
        let theme = CosmosTheme.default
        #expect(theme.textFieldStyle == .automatic)
        #expect(theme.textEditorStyle == .automatic)
    }

    @Test func themeFluentBuildersForWaveD() {
        let base = CosmosTheme.default
        #expect(base.withTextFieldStyle(.cosmos).textFieldStyle == .cosmos)
        #expect(base.withTextFieldStyle(.bordered).textFieldStyle == .bordered)
        #expect(base.withTextEditorStyle(.roundedBorder).textEditorStyle == .roundedBorder)
    }

    @Test func themeFluentBuildersDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withTextFieldStyle(.cosmos)
        _ = base.withTextEditorStyle(.plain)
        #expect(base.textFieldStyle == .automatic)
        #expect(base.textEditorStyle == .automatic)
    }

    // MARK: - CosmosSlider stepping logic (pure helper, no view rendering)

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

    // MARK: - CosmosStepper value mutation (pure helper)

    @Test func stepperAdvancesAndClamps() {
        #expect(CosmosStepperMath.advance(5, by: 1, in: 0...10) == 6)
        #expect(CosmosStepperMath.advance(6, by: -3, in: 0...10) == 3)
        // Clamp to upper bound.
        #expect(CosmosStepperMath.advance(3, by: 100, in: 0...10) == 10)
        // Clamp to lower bound.
        #expect(CosmosStepperMath.advance(10, by: -100, in: 0...10) == 0)
        // Unbounded (nil bounds) → no clamping.
        #expect(CosmosStepperMath.advance(5, by: 1, in: nil) == 6)
    }

    @Test func stepperDoublesWork() {
        #expect(CosmosStepperMath.advance(3.0, by: 0.5, in: 0.0...5.0) == 3.5)
        #expect(CosmosStepperMath.advance(3.5, by: -0.5, in: 0.0...5.0) == 3.0)
    }
}