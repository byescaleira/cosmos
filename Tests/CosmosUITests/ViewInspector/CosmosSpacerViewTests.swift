import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosSpacerViewTests {

    @Test func spacerRenders() throws {
        let view = CosmosSpacer()
        let spacer = try view.inspect().spacer()
        #expect(!spacer.isAbsent)
    }

    @Test func spacerIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosSpacer()
            .environment(\.cosmosConfiguration, configuration)

        let spacer = try view.inspect().spacer()
        #expect(!spacer.isAbsent)
    }
}
