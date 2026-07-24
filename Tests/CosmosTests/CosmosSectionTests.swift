import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosSection")
struct CosmosSectionTests {

    // MARK: - Construction

    @Test func sectionConstructsWithContentOnly() {
        _ = CosmosSection { CosmosText(verbatim: "Row") }
    }

    @Test func sectionConstructsWithContentAndHeader() {
        _ = CosmosSection(content: { CosmosText(verbatim: "Row") },
                          header: { CosmosText(verbatim: "Header") })
    }

    @Test func sectionConstructsWithContentHeaderAndFooter() {
        _ = CosmosSection(content: { CosmosText(verbatim: "Row") },
                          header: { CosmosText(verbatim: "Header") },
                          footer: { CosmosText(verbatim: "Footer") })
    }

    @Test func sectionConstructsWithContentAndFooter() {
        _ = CosmosSection(content: { CosmosText(verbatim: "Row") },
                          footer: { CosmosText(verbatim: "Footer") })
    }
}