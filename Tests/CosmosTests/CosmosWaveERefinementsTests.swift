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

    // MARK: - cosmosTabViewBottomAccessory(isEnabled:) availability (iOS 26.1; pure, host-agnostic)

    @Test func bottomAccessoryEnabledAvailabilityIOSOnly() {
        // The isEnabled: overload is @available(iOS 26.1, *) — unavailable on the other 4.
        #expect(CosmosTabViewBottomAccessoryEnabledAvailability.isAvailable(on: .ios))
        #expect(!CosmosTabViewBottomAccessoryEnabledAvailability.isAvailable(on: .macos))
        #expect(!CosmosTabViewBottomAccessoryEnabledAvailability.isAvailable(on: .tvos))
        #expect(!CosmosTabViewBottomAccessoryEnabledAvailability.isAvailable(on: .watchos))
        #expect(!CosmosTabViewBottomAccessoryEnabledAvailability.isAvailable(on: .visionos))
    }

    // MARK: - CosmosSelectableList selection-init availability (pure, host-agnostic)

    @Test func selectableListOptionalSingleAvailableOnAllFivePlatforms() {
        // Optional-single (Binding<SelectionValue?>) is watchOS 10+ and ≤ floor everywhere → all 5.
        for platform in CosmosPlatform.allCases {
            #expect(CosmosSelectableListAvailability.optionalSingleAvailable(on: platform),
                    "optional-single should be available on \(platform)")
        }
    }

    @Test func selectableListSetAvailableOnFourPlatformsNotWatchOS() {
        // Set selection is @available(watchOS, unavailable) → iOS/macOS/tvOS/visionOS only.
        #expect(CosmosSelectableListAvailability.setAvailable(on: .ios))
        #expect(CosmosSelectableListAvailability.setAvailable(on: .macos))
        #expect(CosmosSelectableListAvailability.setAvailable(on: .tvos))
        #expect(CosmosSelectableListAvailability.setAvailable(on: .visionos))
        #expect(!CosmosSelectableListAvailability.setAvailable(on: .watchos))
    }

    @Test func selectableListReusesListStyleFallback() {
        // CosmosSelectableList shares CosmosListStyleApplier/CosmosListAvailability — the same
        // per-platform style fallback applies (a style unavailable on a platform resolves to
        // .automatic, never blindly forwarded).
        #expect(CosmosListAvailability.resolve(.bordered, on: .ios) == .automatic)   // macOS-only
        #expect(CosmosListAvailability.resolve(.grouped, on: .macos) == .automatic)  // not macOS
        #expect(CosmosListAvailability.resolve(.insetGrouped, on: .tvos) == .automatic) // not tvOS
        // An available style resolves to itself (no spurious fallback).
        #expect(CosmosListAvailability.resolve(.plain, on: .ios) == .plain)
    }

    // MARK: - OS-27 surfaces: PickerStyle.tabs + TabRole.prominent (first Cosmos-27 surface)

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

    @Test func tabRoleSearchAndProminentAvailableOnAllFivePlatforms() {
        // TabRole.search is ≤ floor (all 5); TabRole.prominent is @available(anyAppleOS 27) —
        // all 5 platforms (no watchOS exclusion, unlike .tabs). Version gate is runtime.
        for platform in CosmosPlatform.allCases {
            #expect(CosmosTabRoleAvailability.searchAvailable(on: platform),
                    ".search should be available on \(platform)")
            #expect(CosmosTabRoleAvailability.prominentAvailable(on: platform),
                    ".prominent should be platform-available on \(platform)")
        }
    }

    @Test func tabRoleNativeRoleResolvesNoneAndSearchDeterministically() {
        // Floor-available roles are deterministic. (.prominent.nativeRole() depends on the host OS
        // version — OS 27 → .prominent, below → nil — so it is not asserted here.)
        #expect(CosmosTabRole.none.nativeRole() == nil)
        #expect(CosmosTabRole.search.nativeRole() == .search)
        #expect(CosmosTabRole.allCases == [.none, .search, .prominent])
    }
}