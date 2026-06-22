import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosIconViewTests {

    @Test func iconRendersSystemImage() throws {
        let view = CosmosIcon("star")
        let image = try view.inspect().image()
        #expect(!image.isAbsent)
    }

    @Test func iconIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosIcon("star")
            .environment(\.cosmosConfiguration, configuration)

        let image = try view.inspect().image()
        #expect(!image.isAbsent)
    }
}
