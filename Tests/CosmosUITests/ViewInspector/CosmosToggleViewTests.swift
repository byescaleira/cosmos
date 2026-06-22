import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosToggleViewTests {

    @Test func toggleRendersSwitch() throws {
        let view = CosmosToggle(isOn: .constant(false), "Enabled")
        let toggle = try view.inspect().anyView().toggle()
        #expect(!toggle.isAbsent)
    }

    @Test func toggleRendersLabel() throws {
        let view = CosmosToggle(isOn: .constant(false), "Enabled")
        let toggle = try view.inspect().anyView().toggle()
        let label = try toggle.labelView().text().string()
        #expect(label == "Enabled")
    }

    @Test func toggleRendersIconLabel() throws {
        let view = CosmosToggle(isOn: .constant(false), "Enabled", systemImage: "bell")
        let toggle = try view.inspect().anyView().toggle()
        let hstack = try toggle.labelView().hStack()
        #expect(try hstack.count == 2)
    }

    @Test func toggleIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosToggle(isOn: .constant(false), "Enabled")
            .environment(\.cosmosConfiguration, configuration)

        let toggle = try view.inspect().anyView().toggle()
        #expect(!toggle.isAbsent)
    }
}
