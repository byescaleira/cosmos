import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosAdaptiveStack")
struct CosmosAdaptiveStackTests {

    // MARK: - Construction (previously zero coverage)

    @Test func adaptiveStackConstructsWithContent() {
        _ = CosmosAdaptiveStack { CosmosText(verbatim: "A"); CosmosText(verbatim: "B") }
    }

    @Test func adaptiveStackConstructsViaModifier() {
        _ = CosmosText(verbatim: "row").cosmosAdaptiveStack()
    }

    @Test func adaptiveStackConstructsWithExplicitSpacingsAndAlignments() {
        _ = CosmosAdaptiveStack(
            horizontalSpacing: 8, verticalSpacing: 12,
            horizontalAlignment: .top, verticalAlignment: .leading
        ) { CosmosText(verbatim: "Content") }
    }
}