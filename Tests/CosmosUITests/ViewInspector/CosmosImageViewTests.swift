import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosImageViewTests {

    @Test func imageRendersSystemImage() throws {
        let view = CosmosImage(systemName: "photo")
        let image = try view.inspect().image()
        #expect(!image.isAbsent)
    }

    @Test func imageRendersResource() throws {
        let view = CosmosImage(resourceName: "placeholder")
        let image = try view.inspect().image()
        #expect(!image.isAbsent)
    }

    @Test func imageIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosImage(systemName: "photo")
            .environment(\.cosmosConfiguration, configuration)

        let image = try view.inspect().image()
        #expect(!image.isAbsent)
    }
}
