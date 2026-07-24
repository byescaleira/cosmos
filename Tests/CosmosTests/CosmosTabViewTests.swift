import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosTabView")
struct CosmosTabViewTests {

    // MARK: - Construction

    @Test func tabViewConstructsSelectableWithSelection() {
        _ = CosmosTabView(selection: .constant("a")) {
            Tab("A", systemImage: "1.circle", value: "a") { CosmosText(verbatim: "A") }
            Tab("B", systemImage: "2.circle", value: "b") { CosmosText(verbatim: "B") }
        }
    }

    @Test func tabViewConstructsNonSelectable() {
        _ = CosmosTabView {
            Tab("A", systemImage: "1.circle") { CosmosText(verbatim: "A") }
            Tab("B", systemImage: "2.circle") { CosmosText(verbatim: "B") }
        }
    }

    @Test(.tags(.selector), arguments: CosmosTabViewStyle.allCases)
    func tabViewAcceptsEveryStyleVariant(_ style: CosmosTabViewStyle) {
        _ = CosmosTabView(selection: .constant("a")) {
            Tab("A", systemImage: "1.circle", value: "a") { CosmosText(verbatim: "A") }
        }.cosmosTabViewStyle(style)
    }

    // MARK: - Style selector enum

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

    // MARK: - cosmosTabViewBottomAccessory(isEnabled:) availability (iOS 26.1; pure, host-agnostic)

    @Test func bottomAccessoryEnabledAvailabilityIOSOnly() {
        // The isEnabled: overload is @available(iOS 26.1, *) — unavailable on the other 4.
        #expect(CosmosTabViewBottomAccessoryEnabledAvailability.isAvailable(on: .ios))
        #expect(!CosmosTabViewBottomAccessoryEnabledAvailability.isAvailable(on: .macos))
        #expect(!CosmosTabViewBottomAccessoryEnabledAvailability.isAvailable(on: .tvos))
        #expect(!CosmosTabViewBottomAccessoryEnabledAvailability.isAvailable(on: .watchos))
        #expect(!CosmosTabViewBottomAccessoryEnabledAvailability.isAvailable(on: .visionos))
    }

    // MARK: - CosmosTabRole (OS-27 .prominent surface)

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