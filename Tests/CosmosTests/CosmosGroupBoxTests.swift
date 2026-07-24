import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosGroupBox")
struct CosmosGroupBoxTests {

    // MARK: - Construction

    @Test func groupBoxConstructsWithContentOnly() {
        _ = CosmosGroupBox { CosmosText(verbatim: "Content") }
    }

    @Test func groupBoxConstructsWithContentAndCustomLabel() {
        _ = CosmosGroupBox(content: { CosmosText(verbatim: "Content") },
                           label: { Text(verbatim: "Group") })
    }

    @Test func groupBoxConstructsFromLocalizedTitleKey() {
        _ = CosmosGroupBox("preview.title") { CosmosText(verbatim: "Content") }
    }

    @Test func groupBoxConstructsFromVerbatimTitle() {
        _ = CosmosGroupBox(verbatim: "Group") { CosmosText(verbatim: "Content") }
    }

    @Test(.tags(.selector), arguments: CosmosGroupBoxStyle.allCases)
    func groupBoxAcceptsEveryStyleVariant(_ style: CosmosGroupBoxStyle) {
        _ = CosmosGroupBox("preview.title") { CosmosText(verbatim: "Content") }
            .cosmosGroupBoxStyle(style)
    }

    // MARK: - Style selector enum

    @Test func groupBoxStyleAllCases() {
        #expect(CosmosGroupBoxStyle.allCases == [.automatic, .cosmos])
    }

    // MARK: - CosmosGroupBoxAvailability (pure platform predicate)

    @Test func groupBoxAvailabilityMatchesPlatform() {
        // The predicate must agree with the platform enum: native chrome exists everywhere except
        // tvOS/watchOS.
        let expected = CosmosPlatform.current != .tvos && CosmosPlatform.current != .watchos
        #expect(CosmosGroupBoxAvailability.hasNativeGroupBox == expected)
        // On the macOS host specifically, the native GroupBox path is live.
        #expect(CosmosGroupBoxAvailability.hasNativeGroupBox == true)
    }
}