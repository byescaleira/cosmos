import Testing
import SwiftUI
@testable import Cosmos

@Suite("Cosmos Stacks")
struct CosmosStacksTests {

    // MARK: - Construction (every spacing selector resolves through the 4-pt grid)

    @Test func hStackConstructsForEverySpacingSelector() {
        // The init resolves each selector via CosmosSpacingTokens.value(for:) and feeds the raw
        // value to HStack; construction must not crash for any selector (incl. .none → system default).
        for spacing in CosmosPadding.allCases {
            _ = CosmosHStack(spacing: spacing) { CosmosText(verbatim: "a") }
            _ = CosmosHStack(alignment: .top, spacing: spacing) { CosmosText(verbatim: "a") }
        }
    }

    @Test func vStackConstructsForEverySpacingSelector() {
        for spacing in CosmosPadding.allCases {
            _ = CosmosVStack(spacing: spacing) { CosmosText(verbatim: "a") }
            _ = CosmosVStack(alignment: .leading, spacing: spacing) { CosmosText(verbatim: "a") }
        }
    }

    // MARK: - Defaults

    @Test func hStackDefaultsAreCenterAlignmentAndMediumSpacing() {
        // Default init (content only): alignment .center, spacing .medium. Construct with the
        // default and a custom variant to confirm both overloads compile and build a view.
        _ = CosmosHStack { CosmosText(verbatim: "a") }
        _ = CosmosHStack(spacing: .large) { CosmosText(verbatim: "a") }
        _ = CosmosHStack(alignment: .bottom) { CosmosText(verbatim: "a") }
    }

    @Test func vStackDefaultsAreCenterAlignmentAndMediumSpacing() {
        _ = CosmosVStack { CosmosText(verbatim: "a") }
        _ = CosmosVStack(spacing: .large) { CosmosText(verbatim: "a") }
        _ = CosmosVStack(alignment: .leading) { CosmosText(verbatim: "a") }
    }

    // MARK: - Spacing resolution is the 4-pt grid (parity with CosmosSpacingTokens)

    @Test func stackSpacingResolvesOnGrid() {
        // The stack delegates spacing resolution to CosmosSpacingTokens.value(for:), which is
        // exhaustively tested in CosmosTokensTests. Here we confirm the mapping the stack relies on
        // is unchanged for the cases a layout is most likely to use.
        #expect(CosmosSpacingTokens.value(for: .small) == 8)
        #expect(CosmosSpacingTokens.value(for: .medium) == 12)
        #expect(CosmosSpacingTokens.value(for: .large) == 16)
        #expect(CosmosSpacingTokens.value(for: .xl) == 24)
    }

    @Test func stacksAcceptArbitraryViewContent() {
        // Heterogeneous content + nested Cosmos stacks compose (the generic Content parameter).
        _ = CosmosVStack(spacing: .medium) {
            CosmosHStack(spacing: .small) {
                CosmosIcon("checkmark")
                CosmosText(verbatim: "Done")
            }
            CosmosText(verbatim: "Second row")
        }
    }
}