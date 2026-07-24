import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosStepper")
struct CosmosStepperTests {

    // MARK: - Construction (tvOS renders a CosmosButton fallback — public API uniform)

    @Test func stepperConstructsWithOnIncrementOnDecrement() {
        _ = CosmosStepper(label: { Text(verbatim: "Stepper") },
                          onIncrement: {}, onDecrement: {})
    }

    @Test func stepperConstructsFromLocalizedKeyWithOnIncrementOnDecrement() {
        _ = CosmosStepper("preview.title", onIncrement: {}, onDecrement: {})
    }

    @Test func stepperConstructsWithValueAndStep() {
        _ = CosmosStepper("preview.title", value: .constant(0), step: 1)
    }

    @Test func stepperConstructsWithValueAndBounds() {
        _ = CosmosStepper("preview.title", value: .constant(0), in: 0...10)
    }

    @Test func stepperConstructsFromVerbatimTitleWithValue() {
        _ = CosmosStepper(verbatim: "Count", value: .constant(0))
    }

    @Test func stepperConstructsWithCustomLabelAndValue() {
        _ = CosmosStepper(value: .constant(0), step: 2) { Text(verbatim: "Count") }
    }

    // MARK: - CosmosStepperMath value mutation (pure helper)

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