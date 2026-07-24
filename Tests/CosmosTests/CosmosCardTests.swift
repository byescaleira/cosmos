import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosCard")
struct CosmosCardTests {

    // MARK: - Construction

    @Test func cardConstructsWithBodyOnly() {
        _ = CosmosCard { CosmosText(verbatim: "Body") }
    }

    @Test func cardConstructsWithHeaderAndFooter() {
        _ = CosmosCard(header: { CosmosText(verbatim: "Title") },
                       body: { CosmosText(verbatim: "Body") },
                       footer: { CosmosText(verbatim: "Footer") })
    }

    @Test func cardConstructsWithHeaderOnly() {
        _ = CosmosCard(header: { CosmosText(verbatim: "Title") },
                       body: { CosmosText(verbatim: "Body") })
    }
}