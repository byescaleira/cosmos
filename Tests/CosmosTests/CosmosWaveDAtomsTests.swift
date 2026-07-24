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
    //
    // Parameterized over (style, platform) so the whole 3×5 matrix is asserted in one test on any
    // host (T5). `TextEditor` is unavailable on tvOS/watchOS entirely; `.roundedBorder` is
    // visionOS-only; `.automatic`/`.plain` are available on iOS/macOS/visionOS.

    @Test(.tags(.selector), arguments: CosmosTextEditorStyle.allCases, CosmosPlatform.allCases)
    func textEditorAvailabilityMatrix(_ style: CosmosTextEditorStyle, on platform: CosmosPlatform) {
        let expected: Bool
        switch (style, platform) {
        case (.roundedBorder, .visionos): expected = true
        case (.automatic, .ios), (.automatic, .macos), (.automatic, .visionos): expected = true
        case (.plain, .ios), (.plain, .macos), (.plain, .visionos): expected = true
        default: expected = false // tvOS/watchOS for all; .roundedBorder off visionOS
        }
        #expect(
            CosmosTextEditorAvailability.isAvailable(style, on: platform) == expected,
            "\(style) on \(platform.rawValue)"
        )
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

    @Test func stepperDoesNotOverflowTrapForIntNearBounds() {
        // Regression: advance clamps the stride to the remaining in-bounds distance BEFORE
        // advanced(by:), so Int near Int.max does not trap on overflow before the post-clamp.
        #expect(CosmosStepperMath.advance(Int.max - 1, by: 2, in: 0...Int.max) == Int.max)
        #expect(CosmosStepperMath.advance(Int.min + 1, by: -2, in: Int.min...0) == Int.min)
        // A stride that overshoots both bounds clamps (no trap).
        #expect(CosmosStepperMath.advance(8, by: Int.max, in: 0...10) == 10)
        #expect(CosmosStepperMath.advance(2, by: -Int.max, in: 0...10) == 0)
    }
}