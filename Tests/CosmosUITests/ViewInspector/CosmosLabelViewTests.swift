import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosLabelViewTests {

    @Test func labelRendersTitle() throws {
        let view = CosmosLabel("Continue")
        let text = try view.inspect().text()
        #expect(try text.string() == "Continue")
    }

    @Test func labelRendersIconAndTitle() throws {
        let view = CosmosLabel("Continue", systemImage: "arrow.right")
        let hstack = try view.inspect().hStack()
        #expect(try hstack.count == 2)
    }

    @Test func labelIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosLabel("Continue")
            .environment(\.cosmosConfiguration, configuration)

        let text = try view.inspect().text()
        #expect(!text.isAbsent)
    }
}
