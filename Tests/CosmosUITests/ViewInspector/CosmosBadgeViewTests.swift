import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosBadgeViewTests {

    @Test func badgeRendersText() throws {
        let view = CosmosBadge("New")
        let text = try view.inspect().text()
        #expect(try text.string() == "New")
    }

    @Test func badgeRendersDot() throws {
        let view = CosmosBadge(dot: .error)
        let shape = try view.inspect().shape()
        #expect(!shape.isAbsent)
    }

    @Test func badgeIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosBadge("New")
            .environment(\.cosmosConfiguration, configuration)

        let text = try view.inspect().text()
        #expect(!text.isAbsent)
    }
}
