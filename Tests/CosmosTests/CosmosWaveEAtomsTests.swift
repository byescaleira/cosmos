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

    // MARK: - CosmosListStyle selector enum

    @Test func listStyleAllCases() {
        #expect(CosmosListStyle.allCases == [
            .automatic, .plain, .grouped, .inset, .insetGrouped, .sidebar, .bordered, .elliptical, .carousel
        ])
    }

    // MARK: - CosmosListAvailability (full style × platform matrix, Xcode 27 .swiftinterface)

    @Test func listAvailabilityAutomaticPlainAllPlatforms() {
        for platform in [CosmosPlatform.ios, .macos, .tvos, .watchos, .visionos] {
            #expect(CosmosListAvailability.isAvailable(.automatic, on: platform))
            #expect(CosmosListAvailability.isAvailable(.plain, on: platform))
        }
    }

    @Test func listAvailabilityGroupedNotMacOSWatchOS() {
        #expect(CosmosListAvailability.isAvailable(.grouped, on: .ios))
        #expect(CosmosListAvailability.isAvailable(.grouped, on: .tvos))
        #expect(CosmosListAvailability.isAvailable(.grouped, on: .visionos))
        #expect(!CosmosListAvailability.isAvailable(.grouped, on: .macos))
        #expect(!CosmosListAvailability.isAvailable(.grouped, on: .watchos))
    }

    @Test func listAvailabilityInsetNotTvOSWatchOS() {
        #expect(CosmosListAvailability.isAvailable(.inset, on: .ios))
        #expect(CosmosListAvailability.isAvailable(.inset, on: .macos))
        #expect(CosmosListAvailability.isAvailable(.inset, on: .visionos))
        #expect(!CosmosListAvailability.isAvailable(.inset, on: .tvos))
        #expect(!CosmosListAvailability.isAvailable(.inset, on: .watchos))
    }

    @Test func listAvailabilityInsetGroupedIOSVisionOSOnly() {
        #expect(CosmosListAvailability.isAvailable(.insetGrouped, on: .ios))
        #expect(CosmosListAvailability.isAvailable(.insetGrouped, on: .visionos)) // via `*`
        #expect(!CosmosListAvailability.isAvailable(.insetGrouped, on: .macos))
        #expect(!CosmosListAvailability.isAvailable(.insetGrouped, on: .tvos))
        #expect(!CosmosListAvailability.isAvailable(.insetGrouped, on: .watchos))
    }

    @Test func listAvailabilitySidebarNotTvOSWatchOS() {
        #expect(CosmosListAvailability.isAvailable(.sidebar, on: .ios))
        #expect(CosmosListAvailability.isAvailable(.sidebar, on: .macos))
        #expect(CosmosListAvailability.isAvailable(.sidebar, on: .visionos))
        #expect(!CosmosListAvailability.isAvailable(.sidebar, on: .tvos))
        #expect(!CosmosListAvailability.isAvailable(.sidebar, on: .watchos))
    }

    @Test func listAvailabilityBorderedMacOSOnly() {
        #expect(CosmosListAvailability.isAvailable(.bordered, on: .macos))
        for platform in [CosmosPlatform.ios, .tvos, .watchos, .visionos] {
            #expect(!CosmosListAvailability.isAvailable(.bordered, on: platform))
        }
    }

    @Test func listAvailabilityEllipticalCarouselWatchOSOnly() {
        #expect(CosmosListAvailability.isAvailable(.elliptical, on: .watchos))
        #expect(CosmosListAvailability.isAvailable(.carousel, on: .watchos))
        for platform in [CosmosPlatform.ios, .macos, .tvos, .visionos] {
            #expect(!CosmosListAvailability.isAvailable(.elliptical, on: platform))
            #expect(!CosmosListAvailability.isAvailable(.carousel, on: platform))
        }
    }

    @Test func listResolveFallsBackToAutomatic() {
        // Unavailable requested styles resolve to .automatic; available ones resolve to themselves.
        #expect(CosmosListAvailability.resolve(.grouped, on: .macos) == .automatic)
        #expect(CosmosListAvailability.resolve(.grouped, on: .watchos) == .automatic)
        #expect(CosmosListAvailability.resolve(.insetGrouped, on: .macos) == .automatic)
        #expect(CosmosListAvailability.resolve(.sidebar, on: .tvos) == .automatic)
        #expect(CosmosListAvailability.resolve(.bordered, on: .ios) == .automatic)
        #expect(CosmosListAvailability.resolve(.elliptical, on: .ios) == .automatic)
        #expect(CosmosListAvailability.resolve(.carousel, on: .macos) == .automatic)
        #expect(CosmosListAvailability.resolve(.grouped, on: .ios) == .grouped)
        #expect(CosmosListAvailability.resolve(.bordered, on: .macos) == .bordered)
        #expect(CosmosListAvailability.resolve(.elliptical, on: .watchos) == .elliptical)
        #expect(CosmosListAvailability.resolve(.automatic, on: .tvos) == .automatic)
    }

    // MARK: - List theme selectors

    @Test func themeDefaultsForListSelector() {
        #expect(CosmosTheme.default.listStyle == .automatic)
    }

    @Test func themeFluentBuildersForList() {
        let base = CosmosTheme.default
        #expect(base.withListStyle(.grouped).listStyle == .grouped)
        #expect(base.withListStyle(.sidebar).listStyle == .sidebar)
        #expect(base.withListStyle(.bordered).listStyle == .bordered)
    }

    @Test func themeFluentBuildersForListDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withListStyle(.grouped)
        #expect(base.listStyle == .automatic)
    }

    // MARK: - CosmosTabViewStyle selector enum

    @Test func tabViewStyleAllCases() {
        #expect(CosmosTabViewStyle.allCases == [
            .automatic, .page, .sidebarAdaptable, .tabBarOnly, .verticalPage, .grouped
        ])
    }

    // MARK: - CosmosTabViewAvailability (full style × platform matrix, Xcode 27 .swiftinterface)

    @Test func tabViewAvailabilityAutomaticAllPlatforms() {
        for platform in [CosmosPlatform.ios, .macos, .tvos, .watchos, .visionos] {
            #expect(CosmosTabViewAvailability.isAvailable(.automatic, on: platform))
        }
    }

    @Test func tabViewAvailabilityPageNotMacOS() {
        #expect(CosmosTabViewAvailability.isAvailable(.page, on: .ios))
        #expect(CosmosTabViewAvailability.isAvailable(.page, on: .tvos))
        #expect(CosmosTabViewAvailability.isAvailable(.page, on: .watchos))
        #expect(CosmosTabViewAvailability.isAvailable(.page, on: .visionos))
        #expect(!CosmosTabViewAvailability.isAvailable(.page, on: .macos))
    }

    @Test func tabViewAvailabilitySidebarAdaptableNotWatchOS() {
        #expect(CosmosTabViewAvailability.isAvailable(.sidebarAdaptable, on: .ios))
        #expect(CosmosTabViewAvailability.isAvailable(.sidebarAdaptable, on: .macos))
        #expect(CosmosTabViewAvailability.isAvailable(.sidebarAdaptable, on: .tvos))
        #expect(CosmosTabViewAvailability.isAvailable(.sidebarAdaptable, on: .visionos))
        #expect(!CosmosTabViewAvailability.isAvailable(.sidebarAdaptable, on: .watchos))
    }

    @Test func tabViewAvailabilityTabBarOnlyNotWatchOS() {
        #expect(CosmosTabViewAvailability.isAvailable(.tabBarOnly, on: .ios))
        #expect(CosmosTabViewAvailability.isAvailable(.tabBarOnly, on: .macos))
        #expect(CosmosTabViewAvailability.isAvailable(.tabBarOnly, on: .tvos))
        #expect(CosmosTabViewAvailability.isAvailable(.tabBarOnly, on: .visionos))
        #expect(!CosmosTabViewAvailability.isAvailable(.tabBarOnly, on: .watchos))
    }

    @Test func tabViewAvailabilityVerticalPageWatchOSOnly() {
        #expect(CosmosTabViewAvailability.isAvailable(.verticalPage, on: .watchos))
        for platform in [CosmosPlatform.ios, .macos, .tvos, .visionos] {
            #expect(!CosmosTabViewAvailability.isAvailable(.verticalPage, on: platform))
        }
    }

    @Test func tabViewAvailabilityGroupedMacOSOnly() {
        #expect(CosmosTabViewAvailability.isAvailable(.grouped, on: .macos))
        for platform in [CosmosPlatform.ios, .tvos, .watchos, .visionos] {
            #expect(!CosmosTabViewAvailability.isAvailable(.grouped, on: platform))
        }
    }

    @Test func tabViewResolveFallsBackToAutomatic() {
        // Unavailable requested styles resolve to .automatic; available ones resolve to themselves.
        #expect(CosmosTabViewAvailability.resolve(.page, on: .macos) == .automatic)
        #expect(CosmosTabViewAvailability.resolve(.sidebarAdaptable, on: .watchos) == .automatic)
        #expect(CosmosTabViewAvailability.resolve(.tabBarOnly, on: .watchos) == .automatic)
        #expect(CosmosTabViewAvailability.resolve(.verticalPage, on: .ios) == .automatic)
        #expect(CosmosTabViewAvailability.resolve(.verticalPage, on: .macos) == .automatic)
        #expect(CosmosTabViewAvailability.resolve(.grouped, on: .ios) == .automatic)
        #expect(CosmosTabViewAvailability.resolve(.grouped, on: .watchos) == .automatic)
        #expect(CosmosTabViewAvailability.resolve(.page, on: .ios) == .page)
        #expect(CosmosTabViewAvailability.resolve(.sidebarAdaptable, on: .macos) == .sidebarAdaptable)
        #expect(CosmosTabViewAvailability.resolve(.verticalPage, on: .watchos) == .verticalPage)
        #expect(CosmosTabViewAvailability.resolve(.grouped, on: .macos) == .grouped)
        #expect(CosmosTabViewAvailability.resolve(.automatic, on: .tvos) == .automatic)
    }

    // MARK: - TabView theme selectors

    @Test func themeDefaultsForTabViewSelector() {
        #expect(CosmosTheme.default.tabViewStyle == .automatic)
    }

    @Test func themeFluentBuildersForTabView() {
        let base = CosmosTheme.default
        #expect(base.withTabViewStyle(.page).tabViewStyle == .page)
        #expect(base.withTabViewStyle(.sidebarAdaptable).tabViewStyle == .sidebarAdaptable)
        #expect(base.withTabViewStyle(.grouped).tabViewStyle == .grouped)
    }

    @Test func themeFluentBuildersForTabViewDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withTabViewStyle(.page)
        #expect(base.tabViewStyle == .automatic)
    }
}