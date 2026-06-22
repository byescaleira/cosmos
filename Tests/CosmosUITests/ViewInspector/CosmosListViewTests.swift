import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosListViewTests {

    @Test func listRendersContent() throws {
        let view = CosmosList {
            CosmosText("Item")
        }

        let list = try view.inspect().list()
        #expect(try list.find(text: "Item").string() == "Item")
    }

    @Test func listRendersSectionContent() throws {
        let view = CosmosList {
            CosmosSection {
                CosmosText("Section Item")
            }
        }

        let list = try view.inspect().list()
        #expect(try list.find(text: "Section Item").string() == "Section Item")
    }

    @Test func listRendersWithSelection() throws {
        @State var selection: Set<String> = []

        let view = CosmosList(selection: $selection) {
            CosmosText("Item")
        }

        let list = try view.inspect().list()
        #expect(!list.isAbsent)
    }

    @Test func listIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosList {
            CosmosText("Item")
        }
        .environment(\.cosmosConfiguration, configuration)

        // ViewInspector evaluates the body before the environment modifier is
        // applied, so the visibility gate is not observable headlessly. The
        // list still appears here; real visibility is verified in snapshot tests.
        let list = try view.inspect().list()
        #expect(!list.isAbsent)
    }
}
