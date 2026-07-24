import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosSelectableList")
struct CosmosSelectableListTests {

    // MARK: - Construction

    @Test func selectableListConstructsOptionalSingleWithContent() {
        _ = CosmosSelectableList(selection: .constant(Int?.none)) { CosmosText(verbatim: "Row") }
    }

    @Test func selectableListConstructsOptionalSingleWithIdentifiableData() {
        _ = CosmosSelectableList(selection: .constant(Int?.none), [ListRow(id: 1, text: "A")]) { CosmosText(verbatim: $0.text) }
    }

    @Test func selectableListConstructsOptionalSingleWithDataAndIDKeyPath() {
        _ = CosmosSelectableList(selection: .constant(Int?.none), [ListRow(id: 1, text: "A")], id: \.id) { CosmosText(verbatim: $0.text) }
    }

    @Test(.disabled(if: isWatchOS), .tags(.availability))
    func selectableListConstructsSetWithContent() {
        _ = CosmosSelectableList(selection: .constant(Set<Int>())) { CosmosText(verbatim: "Row") }
    }

    @Test(.disabled(if: isWatchOS), .tags(.availability))
    func selectableListConstructsSetWithIdentifiableData() {
        _ = CosmosSelectableList(selection: .constant(Set<Int>()), [ListRow(id: 1, text: "A")]) { CosmosText(verbatim: $0.text) }
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
}