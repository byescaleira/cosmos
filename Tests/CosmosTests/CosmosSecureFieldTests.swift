import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosSecureField")
struct CosmosSecureFieldTests {

    // MARK: - Construction (previously zero coverage)

    @Test func secureFieldConstructsFromLocalizedKey() {
        _ = CosmosSecureField("preview.title", text: .constant(""))
    }

    @Test func secureFieldConstructsFromLocalizedKeyWithPrompt() {
        _ = CosmosSecureField("preview.title", text: .constant(""), prompt: Text("preview.description"))
    }

    @Test func secureFieldConstructsFromVerbatimTitle() {
        _ = CosmosSecureField(verbatim: "Password", text: .constant(""))
    }

    @Test func secureFieldConstructsWithCustomLabel() {
        _ = CosmosSecureField(text: .constant("")) { Text(verbatim: "Secret") }
    }
}