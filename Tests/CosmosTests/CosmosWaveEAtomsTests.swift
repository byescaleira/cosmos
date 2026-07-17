import Testing
import SwiftUI
@testable import Cosmos

@Suite("Wave E Atoms")
struct CosmosWaveEAtomsTests {

    // MARK: - CosmosPickerStyle selector enum

    @Test func pickerStyleAllCases() {
        #expect(CosmosPickerStyle.allCases == [
            .automatic, .menu, .segmented, .wheel, .inline, .palette, .navigationLink, .radioGroup
        ])
    }

    // MARK: - CosmosPickerAvailability (full style × platform matrix, Xcode 27 .swiftinterface)

    @Test func pickerAvailabilityAutomaticAllPlatforms() {
        for platform in [CosmosPlatform.ios, .macos, .tvos, .watchos, .visionos] {
            #expect(CosmosPickerAvailability.isAvailable(.automatic, on: platform))
        }
    }

    @Test func pickerAvailabilityInlineAllPlatforms() {
        for platform in [CosmosPlatform.ios, .macos, .tvos, .watchos, .visionos] {
            #expect(CosmosPickerAvailability.isAvailable(.inline, on: platform))
        }
    }

    @Test func pickerAvailabilityMenuNotWatchOS() {
        #expect(CosmosPickerAvailability.isAvailable(.menu, on: .ios))
        #expect(CosmosPickerAvailability.isAvailable(.menu, on: .macos))
        #expect(CosmosPickerAvailability.isAvailable(.menu, on: .tvos))
        #expect(CosmosPickerAvailability.isAvailable(.menu, on: .visionos))
        #expect(!CosmosPickerAvailability.isAvailable(.menu, on: .watchos))
    }

    @Test func pickerAvailabilitySegmentedNotWatchOS() {
        #expect(CosmosPickerAvailability.isAvailable(.segmented, on: .ios))
        #expect(CosmosPickerAvailability.isAvailable(.segmented, on: .macos))
        #expect(CosmosPickerAvailability.isAvailable(.segmented, on: .tvos))
        #expect(CosmosPickerAvailability.isAvailable(.segmented, on: .visionos))
        #expect(!CosmosPickerAvailability.isAvailable(.segmented, on: .watchos))
    }

    @Test func pickerAvailabilityWheelNotMacOSTvOS() {
        #expect(CosmosPickerAvailability.isAvailable(.wheel, on: .ios))
        #expect(CosmosPickerAvailability.isAvailable(.wheel, on: .watchos))
        #expect(CosmosPickerAvailability.isAvailable(.wheel, on: .visionos))
        #expect(!CosmosPickerAvailability.isAvailable(.wheel, on: .macos))
        #expect(!CosmosPickerAvailability.isAvailable(.wheel, on: .tvos))
    }

    @Test func pickerAvailabilityPaletteNotTvOSWatchOS() {
        #expect(CosmosPickerAvailability.isAvailable(.palette, on: .ios))
        #expect(CosmosPickerAvailability.isAvailable(.palette, on: .macos))
        #expect(CosmosPickerAvailability.isAvailable(.palette, on: .visionos)) // via `*`
        #expect(!CosmosPickerAvailability.isAvailable(.palette, on: .tvos))
        #expect(!CosmosPickerAvailability.isAvailable(.palette, on: .watchos))
    }

    @Test func pickerAvailabilityNavigationLinkNotMacOS() {
        #expect(CosmosPickerAvailability.isAvailable(.navigationLink, on: .ios))
        #expect(CosmosPickerAvailability.isAvailable(.navigationLink, on: .tvos))
        #expect(CosmosPickerAvailability.isAvailable(.navigationLink, on: .watchos))
        #expect(CosmosPickerAvailability.isAvailable(.navigationLink, on: .visionos))
        #expect(!CosmosPickerAvailability.isAvailable(.navigationLink, on: .macos))
    }

    @Test func pickerAvailabilityRadioGroupMacOSOnly() {
        #expect(CosmosPickerAvailability.isAvailable(.radioGroup, on: .macos))
        #expect(!CosmosPickerAvailability.isAvailable(.radioGroup, on: .ios))
        #expect(!CosmosPickerAvailability.isAvailable(.radioGroup, on: .tvos))
        #expect(!CosmosPickerAvailability.isAvailable(.radioGroup, on: .watchos))
        #expect(!CosmosPickerAvailability.isAvailable(.radioGroup, on: .visionos))
    }

    @Test func pickerResolveFallsBackToAutomatic() {
        // An unavailable requested style resolves to .automatic; an available one resolves to itself.
        #expect(CosmosPickerAvailability.resolve(.wheel, on: .macos) == .automatic)
        #expect(CosmosPickerAvailability.resolve(.radioGroup, on: .ios) == .automatic)
        #expect(CosmosPickerAvailability.resolve(.menu, on: .watchos) == .automatic)
        #expect(CosmosPickerAvailability.resolve(.palette, on: .tvos) == .automatic)
        #expect(CosmosPickerAvailability.resolve(.navigationLink, on: .macos) == .automatic)
        #expect(CosmosPickerAvailability.resolve(.segmented, on: .ios) == .segmented)
        #expect(CosmosPickerAvailability.resolve(.automatic, on: .tvos) == .automatic)
        #expect(CosmosPickerAvailability.resolve(.wheel, on: .watchos) == .wheel)
    }

    // MARK: - Theme selectors (defaults + fluent builders)

    @Test func themeDefaultsForWaveESelectors() {
        let theme = CosmosTheme.default
        #expect(theme.pickerStyle == .automatic)
    }

    @Test func themeFluentBuildersForWaveE() {
        let base = CosmosTheme.default
        #expect(base.withPickerStyle(.menu).pickerStyle == .menu)
        #expect(base.withPickerStyle(.wheel).pickerStyle == .wheel)
        #expect(base.withPickerStyle(.radioGroup).pickerStyle == .radioGroup)
    }

    @Test func themeFluentBuildersDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withPickerStyle(.segmented)
        #expect(base.pickerStyle == .automatic)
    }
}