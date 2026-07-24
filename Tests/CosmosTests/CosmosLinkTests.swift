import Testing
import Foundation
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosLink")
struct CosmosLinkTests {

    // MARK: - Construction

    @Test func linkConstructsFromDestinationAndCustomLabel() {
        _ = CosmosLink(destination: URL(string: "https://example.com")!) { Text(verbatim: "Open") }
    }

    @Test func linkConstructsFromLocalizedTitleKey() {
        _ = CosmosLink("welcome.continue", destination: URL(string: "https://example.com")!)
    }

    @Test func linkConstructsFromVerbatimTitle() {
        _ = CosmosLink(verbatim: "Visit", destination: URL(string: "https://example.com")!)
    }
}