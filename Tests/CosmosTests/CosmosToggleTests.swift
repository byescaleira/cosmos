import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosToggle")
struct CosmosToggleTests {

    // MARK: - Construction (per-init construction smoke)

    @Test func toggleConstructsFromLocalizedKey() {
        _ = CosmosToggle("preview.title", isOn: .constant(false))
    }

    @Test func toggleConstructsFromVerbatimTitle() {
        _ = CosmosToggle(verbatim: "Toggle", isOn: .constant(false))
    }

    @Test func toggleConstructsFromLocalizedKeyAndSystemImage() {
        _ = CosmosToggle("preview.title", systemImage: "wifi", isOn: .constant(false))
    }

    @Test func toggleConstructsWithCustomLabel() {
        _ = CosmosToggle(isOn: .constant(false)) { Text(verbatim: "Custom") }
    }

    @Test(.tags(.selector), arguments: CosmosToggleStyle.allCases)
    func toggleAcceptsEveryStyleVariant(_ style: CosmosToggleStyle) {
        _ = CosmosToggle("preview.title", isOn: .constant(false)).cosmosToggleStyle(style)
    }

    // MARK: - Style selector enum

    @Test func toggleStyleAllCases() {
        #expect(CosmosToggleStyle.allCases == [.automatic, .switch, .button])
    }

    // MARK: - CosmosToggleAccessibility (pure a11y re-application logic)

    @Test func toggleValueStringOnOff() {
        #expect(CosmosToggleAccessibility.valueString(isOn: true, isMixed: false) == "On")
        #expect(CosmosToggleAccessibility.valueString(isOn: false, isMixed: false) == "Off")
    }

    @Test func toggleValueStringMixedDominates() {
        // isMixed (indeterminate) takes precedence over isOn.
        #expect(CosmosToggleAccessibility.valueString(isOn: true, isMixed: true) == "Mixed")
        #expect(CosmosToggleAccessibility.valueString(isOn: false, isMixed: true) == "Mixed")
    }

    @Test func toggleSelectionHapticOnlyForButton() {
        // The .selection haptic fires only for .button (the variant with no native haptic);
        // .switch/.automatic emit their own, so Cosmos must not double-haptic.
        #expect(CosmosToggleAccessibility.shouldEmitSelectionHaptic(style: .button) == true)
        #expect(CosmosToggleAccessibility.shouldEmitSelectionHaptic(style: .switch) == false)
        #expect(CosmosToggleAccessibility.shouldEmitSelectionHaptic(style: .automatic) == false)
    }
}