import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosMenu")
struct CosmosMenuTests {

    // MARK: - Construction (Menu unavailable on watchOS — atom falls back to CosmosButton)

    @Test func menuConstructsFromLocalizedTitleKey() {
        _ = CosmosMenu("preview.title") { CosmosText(verbatim: "Item") }
    }

    @Test func menuConstructsFromVerbatimTitle() {
        _ = CosmosMenu(verbatim: "Menu") { CosmosText(verbatim: "Item") }
    }

    @Test func menuConstructsWithCustomLabel() {
        _ = CosmosMenu(content: { CosmosText(verbatim: "Item") },
                       label: { Text(verbatim: "Open") })
    }

    @Test func menuConstructsWithPrimaryAction() {
        _ = CosmosMenu(content: { CosmosText(verbatim: "Item") },
                       label: { Text(verbatim: "Open") },
                       primaryAction: {})
    }

    @Test func menuConstructsFromLocalizedTitleKeyAndSystemImage() {
        _ = CosmosMenu("preview.title", systemImage: "ellipsis.circle") { CosmosText(verbatim: "Item") }
    }

    @Test(.tags(.selector), arguments: CosmosMenuStyle.allCases)
    func menuAcceptsEveryStyleVariant(_ style: CosmosMenuStyle) {
        _ = CosmosMenu("preview.title") { CosmosText(verbatim: "Item") }.cosmosMenuStyle(style)
    }

    // MARK: - Style selector enum

    @Test func menuStyleAllCases() {
        #expect(CosmosMenuStyle.allCases == [.automatic, .button])
    }

    // MARK: - CosmosMenuAccessibility + availability

    @Test func menuPrimaryActionFeedback() {
        // Non-destructive primary tap → .selection.
        let normal = CosmosMenuAccessibility.primaryActionFeedback(isDestructive: false)
        if case .selection = normal {
            // expected
        } else {
            Issue.record("expected .selection for a non-destructive primary action")
        }
        // Destructive primary tap → .impact(weight: .rigid, intensity: nil).
        let destructive = CosmosMenuAccessibility.primaryActionFeedback(isDestructive: true)
        if case .impact(let weight, let intensity) = destructive {
            #expect(weight == .rigid)
            #expect(intensity == nil)
        } else {
            Issue.record("expected .impact(.rigid) for a destructive primary action")
        }
    }

    @Test func menuAvailabilityMatchesPlatform() {
        // `.menuActionDismissBehavior(.disabled)`: iOS 16.4+/tvOS 17+/visionOS 1+ — unavailable on
        // macOS/watchOS. On the macOS host this is `false`.
        #expect(CosmosMenuAvailability.supportsDismissBehaviorDisabled == (CosmosPlatform.current != .macos && CosmosPlatform.current != .watchos))
        // `.menuOrder(.priority)`: iOS/visionOS only.
        #expect(CosmosMenuAvailability.supportsMenuOrderPriority == (CosmosPlatform.current == .ios || CosmosPlatform.current == .visionos))
        #expect(CosmosMenuAvailability.supportsMenuOrderPriority == false) // macOS host
    }
}