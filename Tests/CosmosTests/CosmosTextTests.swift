import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosText")
struct CosmosTextTests {

    // MARK: - Construction

    @Test func textConstructsFromLocalizedKey() {
        _ = CosmosText("welcome.headline")
    }

    @Test func textConstructsFromVerbatim() {
        _ = CosmosText(verbatim: "Hello, world")
    }

    @Test func textAcceptsNilKeyAndNilVerbatim() {
        // Both nil-key and nil-verbatim render nothing (the atom guards on a resolved string).
        _ = CosmosText(nil as String?)
        _ = CosmosText(verbatim: nil as String?)
    }

    @Test func textAcceptsFontOverride() {
        _ = CosmosText("welcome.headline").cosmosFont(.title, weight: .bold)
    }
}