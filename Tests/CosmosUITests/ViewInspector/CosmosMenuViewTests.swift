import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosMenuViewTests {

    @Test func menuRenders() throws {
        let view = CosmosMenu("Options") {
            Button("Option 1") { }
            Button("Option 2") { }
        }
        let menu = try view.inspect().anyView().menu()
        #expect(!menu.isAbsent)
    }

    @Test func menuRendersCustomLabel() throws {
        let view = CosmosMenu(label: { Text("More") }, content: {
            Button("Option") { }
        })
        let menu = try view.inspect().anyView().menu()
        #expect(!menu.isAbsent)
    }

    @Test func menuIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosMenu("Options") {
            Button("Option") { }
        }
        .environment(\.cosmosConfiguration, configuration)

        let menu = try view.inspect().anyView().menu()
        #expect(!menu.isAbsent)
    }
}
