import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosList")
struct CosmosListTests {

    // MARK: - Construction

    @Test func listConstructsWithContentOnly() {
        _ = CosmosList { CosmosText(verbatim: "Row") }
    }

    @Test func listConstructsFromIdentifiableData() {
        _ = CosmosList([ListRow(id: 1, text: "A"), .init(id: 2, text: "B")]) { CosmosText(verbatim: $0.text) }
    }

    @Test func listConstructsFromDataWithIDKeyPath() {
        _ = CosmosList([ListRow(id: 1, text: "A")], id: \.id) { CosmosText(verbatim: $0.text) }
    }

    @Test func listConstructsFromRange() {
        _ = CosmosList(0..<3) { CosmosText(verbatim: "Row \($0)") }
    }

    @Test(.tags(.selector), arguments: CosmosListStyle.allCases)
    func listAcceptsEveryStyleVariant(_ style: CosmosListStyle) {
        _ = CosmosList { CosmosText(verbatim: "Row") }.cosmosListStyle(style)
    }

    // MARK: - Style selector enum

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
}