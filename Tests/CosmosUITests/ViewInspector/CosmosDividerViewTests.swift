import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosDividerViewTests {

    @Test func dividerRenders() throws {
        let view = CosmosDivider()
        let divider = try view.inspect().divider()
        #expect(!divider.isAbsent)
    }

    @Test func dividerIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosDivider()
            .environment(\.cosmosConfiguration, configuration)

        let divider = try view.inspect().divider()
        #expect(!divider.isAbsent)
    }
}
