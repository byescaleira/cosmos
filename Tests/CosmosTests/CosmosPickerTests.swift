import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosPicker")
struct CosmosPickerTests {

    // MARK: - Construction

    @Test func pickerConstructsFromLocalizedKey() {
        _ = CosmosPicker("preview.title", selection: .constant("a")) { Text(verbatim: "A").tag("a") }
    }

    @Test func pickerConstructsFromVerbatimTitle() {
        _ = CosmosPicker(verbatim: "Pick", selection: .constant("a")) { Text(verbatim: "A").tag("a") }
    }

    @Test func pickerConstructsFromLocalizedKeyAndSystemImage() {
        _ = CosmosPicker("preview.title", systemImage: "tag", selection: .constant("a")) { Text(verbatim: "A").tag("a") }
    }

    @Test func pickerConstructsWithCustomLabel() {
        _ = CosmosPicker(selection: .constant("a"), content: { Text(verbatim: "A").tag("a") },
                         label: { Text(verbatim: "Pick") })
    }

    @Test(.tags(.selector), arguments: CosmosPickerStyle.allCases)
    func pickerAcceptsEveryStyleVariant(_ style: CosmosPickerStyle) {
        _ = CosmosPicker("preview.title", selection: .constant("a")) { Text(verbatim: "A").tag("a") }
            .cosmosPickerStyle(style)
    }

    // MARK: - Style selector enum

    @Test func pickerStyleAllCases() {
        // .tabs (TabsPickerStyle, OS 27) is the 9th case — the first above-floor (Cosmos-27) surface.
        #expect(CosmosPickerStyle.allCases == [
            .automatic, .menu, .segmented, .wheel, .inline, .palette, .navigationLink, .radioGroup, .tabs
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

    // MARK: - OS-27 surface: PickerStyle.tabs (first Cosmos-27 surface)

    @Test func pickerStyleTabsIsExposedAndCaseIterable() {
        // .tabs (TabsPickerStyle, OS 27) is the 9th case — present in CaseIterable.
        #expect(CosmosPickerStyle.tabs.rawValue == "tabs")
        #expect(CosmosPickerStyle.allCases.contains(.tabs))
    }

    @Test func pickerTabsAvailableOnFourPlatformsNotWatchOS() {
        // TabsPickerStyle is @available(iOS/macOS/tvOS/visionOS 27) @available(watchOS, unavailable).
        // The table reports the platform gate; the OS-27 version gate is runtime (in the applier).
        #expect(CosmosPickerAvailability.isAvailable(.tabs, on: .ios))
        #expect(CosmosPickerAvailability.isAvailable(.tabs, on: .macos))
        #expect(CosmosPickerAvailability.isAvailable(.tabs, on: .tvos))
        #expect(CosmosPickerAvailability.isAvailable(.tabs, on: .visionos))
        #expect(!CosmosPickerAvailability.isAvailable(.tabs, on: .watchos))
        // resolve returns .tabs on the 4 supporting platforms (applier degrades to .automatic
        // below OS 27); .automatic on watchOS.
        #expect(CosmosPickerAvailability.resolve(.tabs, on: .ios) == .tabs)
        #expect(CosmosPickerAvailability.resolve(.tabs, on: .watchos) == .automatic)
    }
}