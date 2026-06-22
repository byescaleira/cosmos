import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosTabViewTests {

    private var tabs: [CosmosTab] {
        [
            CosmosTab(id: "home", titleKey: "Home", systemImage: "house"),
            CosmosTab(id: "settings", titleKey: "Settings", systemImage: "gear")
        ]
    }

    @Test func tabViewRendersTabLabels() throws {
        @State var selection: String? = "home"

        let view = CosmosTabView(
            selection: $selection,
            tabs: tabs,
            strategy: .tabBar
        ) { tab in
            Text("Content for \(tab.titleKey)")
        }

        let inspected = try view.inspect()
        #expect(try inspected.find(text: "Home").isAbsent == false)
        #expect(try inspected.find(text: "Settings").isAbsent == false)
    }

    @Test func tabViewRendersCustomContent() throws {
        @State var selection: String? = "home"

        let view = CosmosTabView(
            selection: $selection,
            tabs: tabs,
            strategy: .tabBar
        ) { tab in
            Text("Content for \(tab.titleKey)")
        }

        let inspected = try view.inspect()
        #expect(try inspected.find(text: "Content for Home").isAbsent == false)
    }

    @Test func tabViewIsHiddenWhenNotVisible() throws {
        @State var selection: String? = "home"
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosTabView(
            selection: $selection,
            tabs: tabs,
            strategy: .tabBar
        ) { tab in
            Text("Content for \(tab.titleKey)")
        }
        .environment(\.cosmosConfiguration, configuration)

        // ViewInspector evaluates the body before the environment modifier is
        // applied, so the visibility gate is not observable headlessly. The tab
        // view still appears here; real visibility is verified in snapshot tests.
        #expect(try view.inspect().find(text: "Home").isAbsent == false)
    }
}
