import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosViewThatFits")
struct CosmosViewThatFitsTests {

    // MARK: - Construction
    //
    // `CosmosViewThatFits` wraps SwiftUI's `ViewThatFits` so the size-driven reflow pattern has a
    // `Cosmos`-prefixed atom. Value-level construction only (no rendering / no ViewInspector, per
    // the test contract): the smoke guarantees each public init builds a view across realistic
    // alternative shapes. The pick-the-fitting-child behavior is verified visually via the
    // co-located `#Preview` (wide → row, narrow → stack), not by a unit test.

    @Test func viewThatFitsConstructsWithDefaultAxes() {
        _ = CosmosViewThatFits {
            CosmosText(verbatim: "wide")
            CosmosText(verbatim: "narrow")
        }
    }

    @Test func viewThatFitsConstructsWithExplicitHorizontalAxis() {
        // The `in axes` overload constrains which axes count as "fitting" (default both).
        _ = CosmosViewThatFits(in: .horizontal) {
            CosmosText(verbatim: "wide")
            CosmosText(verbatim: "narrow")
        }
    }

    @Test func viewThatFitsConstructsRowThenStackAlternatives() {
        // The canonical reflow: a row that collapses to a stack under constrained width. Both
        // alternatives are heterogeneous Cosmos atoms — construction must not crash.
        _ = CosmosViewThatFits {
            CosmosHStack(spacing: .medium) {
                CosmosLabel("preview.title", systemImage: "star")
                CosmosButton("welcome.continue") {}
            }
            CosmosVStack(spacing: .small) {
                CosmosLabel("preview.title", systemImage: "star")
                CosmosButton("welcome.continue") {}
            }
        }
    }

    @Test func viewThatFitsConstructsThreeAlternatives() {
        // Priority order: first that fits wins. Three alternatives exercise the multi-child path.
        _ = CosmosViewThatFits {
            CosmosText(verbatim: "first")
            CosmosText(verbatim: "second")
            CosmosText(verbatim: "third")
        }
    }

    @Test func viewThatFitsAcceptsSingleAlternative() {
        // A single alternative is valid (degenerates to always showing it).
        _ = CosmosViewThatFits { CosmosText(verbatim: "only") }
    }
}