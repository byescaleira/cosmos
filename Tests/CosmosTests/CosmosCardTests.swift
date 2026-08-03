import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosCard")
struct CosmosCardTests {

    // MARK: - Construction
    //
    // `CosmosCard` is `@available(*, deprecated)`; every construction test is annotated with the
    // matching `@available(*, deprecated)` passthrough so the deprecated-inits call sites don't emit
    // warnings (a deprecated context may use deprecated APIs freely — keeps the build warning-free
    // for the deprecation runway until the atom is obsoleted).

    @Test(.tags(.smoke))
    @available(*, deprecated, message: "Exercising deprecated CosmosCard inits during the deprecation runway.")
    func cardConstructsWithHeaderBodyFooter() {
        _ = CosmosCard(
            header: { CosmosText(verbatim: "Header") },
            body: { CosmosText(verbatim: "Body") },
            footer: { CosmosText(verbatim: "Footer") }
        )
    }

    @Test(.tags(.smoke))
    @available(*, deprecated, message: "Exercising deprecated CosmosCard inits during the deprecation runway.")
    func cardConstructsWithBodyOnly() {
        // `header`/`footer` default to `EmptyView`; the atom must still construct with body alone.
        _ = CosmosCard(body: { CosmosText(verbatim: "Body") })
    }

    @Test(.tags(.smoke))
    @available(*, deprecated, message: "Exercising deprecated CosmosCard inits during the deprecation runway.")
    func cardConstructsWithCustomViewContent() {
        _ = CosmosCard(
            header: { Label("Title", systemImage: "star.fill") },
            body: { VStack { CosmosText(verbatim: "Line 1"); CosmosText(verbatim: "Line 2") } }
        )
    }
}