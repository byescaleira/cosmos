import Testing
import Foundation
import SwiftUI
@testable import Cosmos

@Suite("Wave A Atoms")
struct CosmosWaveAAtomsTests {

    // MARK: - Style selector enums

    @Test func toggleStyleAllCases() {
        #expect(CosmosToggleStyle.allCases == [.automatic, .switch, .button])
    }

    @Test func labelStyleAllCases() {
        #expect(CosmosLabelStyle.allCases == [.automatic, .titleAndIcon, .iconOnly, .titleOnly, .cosmos])
    }

    @Test func progressStyleAllCases() {
        #expect(CosmosProgressStyle.allCases == [.automatic, .circular, .linear, .cosmos])
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

    // MARK: - CosmosProgressAccessibility (pure determinate/indeterminate branch logic)

    @Test func progressIsIndeterminateWhenFractionNil() {
        #expect(CosmosProgressAccessibility.isIndeterminate(fractionCompleted: nil) == true)
        #expect(CosmosProgressAccessibility.isIndeterminate(fractionCompleted: 0.0) == false)
        #expect(CosmosProgressAccessibility.isIndeterminate(fractionCompleted: 0.5) == false)
        #expect(CosmosProgressAccessibility.isIndeterminate(fractionCompleted: 1.0) == false)
    }

    @Test func progressValueStringEmptyForIndeterminate() {
        // The native spinner owns its own value; the custom chrome emits no value for indeterminate.
        #expect(CosmosProgressAccessibility.valueString(fractionCompleted: nil) == "")
    }

    @Test func progressValueStringClampsAndRounds() {
        #expect(CosmosProgressAccessibility.valueString(fractionCompleted: 0.0) == "0%")
        #expect(CosmosProgressAccessibility.valueString(fractionCompleted: 0.454) == "45%")
        #expect(CosmosProgressAccessibility.valueString(fractionCompleted: 1.0) == "100%")
        // Clamped to [0, 1].
        #expect(CosmosProgressAccessibility.valueString(fractionCompleted: 1.5) == "100%")
        #expect(CosmosProgressAccessibility.valueString(fractionCompleted: -0.25) == "0%")
    }

    // MARK: - Theme selectors (defaults + fluent builders)

    @Test func themeDefaultsForWaveASelectors() {
        let theme = CosmosTheme.default
        #expect(theme.toggleStyle == .automatic)
        #expect(theme.labelStyle == .automatic)
        #expect(theme.progressStyle == .automatic)
    }

    @Test func themeFluentBuildersReturnMutatedCopies() {
        let base = CosmosTheme.default
        #expect(base.withToggleStyle(.button).toggleStyle == .button)
        #expect(base.withLabelStyle(.cosmos).labelStyle == .cosmos)
        #expect(base.withProgressStyle(.linear).progressStyle == .linear)
    }

    @Test func themeFluentBuildersDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withToggleStyle(.button)
        _ = base.withLabelStyle(.iconOnly)
        _ = base.withProgressStyle(.cosmos)
        #expect(base.toggleStyle == .automatic)
        #expect(base.labelStyle == .automatic)
        #expect(base.progressStyle == .automatic)
    }

    // MARK: - Motion policy gating (Wave A atoms route through this; truth-table sanity)

    @Test func motionPolicyGatesProgressAndToggleMotion() {
        // valueChange motion is suppressed when motion is disabled or (reduce-motion && respected).
        #expect(CosmosMotionPolicy.shouldEmit(isEnabled: false, respectReduceMotion: true, reduceMotion: false) == false)
        #expect(CosmosMotionPolicy.shouldEmit(isEnabled: true, respectReduceMotion: true, reduceMotion: true) == false)
        #expect(CosmosMotionPolicy.shouldEmit(isEnabled: true, respectReduceMotion: true, reduceMotion: false) == true)
        // respectReduceMotion = false lets motion emit even under reduce-motion (intentional override).
        #expect(CosmosMotionPolicy.shouldEmit(isEnabled: true, respectReduceMotion: false, reduceMotion: true) == true)
    }

    @Test func hapticsPolicyGatesToggleSelectionHaptic() {
        // The .button toggle variant's selection haptic is gated by the haptics policy.
        #expect(CosmosHapticsPolicy.shouldEmit(isEnabled: false, respectReduceMotion: true, reduceMotion: false) == false)
        #expect(CosmosHapticsPolicy.shouldEmit(isEnabled: true, respectReduceMotion: true, reduceMotion: true) == false)
        #expect(CosmosHapticsPolicy.shouldEmit(isEnabled: true, respectReduceMotion: true, reduceMotion: false) == true)
    }

    // MARK: - valueChange token resolution (used by CosmosProgressChrome)

    @MainActor
    @Test func valueChangeTokenResolves() {
        let tokens = CosmosMotionTokens.default
        let full = tokens.animation(for: .valueChange, reduceMotion: false, policy: .substitute)
        #expect(full != nil)
        // reduce-motion + .instant → nil (snap); .substitute → short easeInOut.
        #expect(tokens.animation(for: .valueChange, reduceMotion: true, policy: .instant) == nil)
        #expect(tokens.animation(for: .valueChange, reduceMotion: true, policy: .substitute) != nil)
    }
}