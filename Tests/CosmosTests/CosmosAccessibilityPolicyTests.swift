import Testing
@testable import Cosmos

/// `CosmosAccessibilityPolicy` is the config-aware chokepoint for the accessibility env gates
/// (mirroring `CosmosMotionPolicy`). Verifies each gate honors the `respect*` override flag so a
/// consumer can intentionally force the adaptive behavior on/off, never relying on the bare env
/// value. These are pure value-level decisions (no rendering), per the test contract.
@Suite("CosmosAccessibilityPolicy")
struct CosmosAccessibilityPolicyTests {

    // MARK: - shouldShowBorders (A2 — drives the borderless `.ghost` outline)

    @Test(.tags(.availability))
    func showBordersEmitsWhenGateOnAndRespected() {
        #expect(CosmosAccessibilityPolicy.shouldShowBorders(respectShowBorders: true, showBorders: true) == true)
    }

    @Test(.tags(.availability))
    func showBordersSuppressedWhenGateOff() {
        #expect(CosmosAccessibilityPolicy.shouldShowBorders(respectShowBorders: true, showBorders: false) == false)
    }

    @Test(.tags(.availability))
    func showBordersSuppressedWhenRespectFalseOverridesGate() {
        // `respectShowBorders = false` intentionally overrides even when the gate is on.
        #expect(CosmosAccessibilityPolicy.shouldShowBorders(respectShowBorders: false, showBorders: true) == false)
    }

    // MARK: - shouldIncreaseContrast

    @Test func increaseContrastEmitsWhenIncreasedAndRespected() {
        #expect(CosmosAccessibilityPolicy.shouldIncreaseContrast(respectIncreaseContrast: true, contrast: .increased) == true)
    }

    @Test func increaseContrastSuppressedOnStandardContrast() {
        #expect(CosmosAccessibilityPolicy.shouldIncreaseContrast(respectIncreaseContrast: true, contrast: .standard) == false)
    }

    @Test func increaseContrastSuppressedWhenRespectFalseOverrides() {
        #expect(CosmosAccessibilityPolicy.shouldIncreaseContrast(respectIncreaseContrast: false, contrast: .increased) == false)
    }

    // MARK: - shouldDifferentiateWithoutColor

    @Test func differentiateWithoutColorEmitsWhenGateOnAndRespected() {
        #expect(CosmosAccessibilityPolicy.shouldDifferentiateWithoutColor(respectDifferentiateWithoutColor: true, differentiateWithoutColor: true) == true)
    }

    @Test func differentiateWithoutColorSuppressedWhenGateOff() {
        #expect(CosmosAccessibilityPolicy.shouldDifferentiateWithoutColor(respectDifferentiateWithoutColor: true, differentiateWithoutColor: false) == false)
    }

    @Test func differentiateWithoutColorSuppressedWhenRespectFalseOverrides() {
        #expect(CosmosAccessibilityPolicy.shouldDifferentiateWithoutColor(respectDifferentiateWithoutColor: false, differentiateWithoutColor: true) == false)
    }
}