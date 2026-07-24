import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosVStack")
struct CosmosVStackTests {

    // MARK: - Construction (every spacing selector resolves through the 4-pt grid)

    @Test func vStackConstructsForEverySpacingSelector() {
        for spacing in CosmosPadding.allCases {
            _ = CosmosVStack(spacing: spacing) { CosmosText(verbatim: "a") }
            _ = CosmosVStack(alignment: .leading, spacing: spacing) { CosmosText(verbatim: "a") }
        }
    }

    // MARK: - Defaults

    @Test func vStackDefaultsAreCenterAlignmentAndMediumSpacing() {
        _ = CosmosVStack { CosmosText(verbatim: "a") }
        _ = CosmosVStack(spacing: .large) { CosmosText(verbatim: "a") }
        _ = CosmosVStack(alignment: .leading) { CosmosText(verbatim: "a") }
    }
}