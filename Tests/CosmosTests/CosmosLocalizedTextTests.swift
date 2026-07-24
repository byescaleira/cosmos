import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosLocalizedText")
struct CosmosLocalizedTextTests {

    // MARK: - Construction (previously zero coverage)

    @Test func localizedTextConstructsFromKey() {
        _ = CosmosLocalizedText(key: "welcome.headline")
    }

    @Test func localizedTextConstructsFromUnresolvedKey() {
        // An unresolved key renders nothing; construction must not crash.
        _ = CosmosLocalizedText(key: "this.key.does.not.exist")
    }
}