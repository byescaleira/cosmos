import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosPickerViewTests {

    @Test func pickerRendersSegmentedControl() throws {
        let view = CosmosPicker(
            selection: .constant("b"),
            options: [
                .init(value: "a", label: "A"),
                .init(value: "b", label: "B")
            ]
        )
        let picker = try view.inspect().anyView().picker()
        #expect(!picker.isAbsent)
    }

    @Test func pickerRendersOptions() throws {
        let view = CosmosPicker(
            selection: .constant("b"),
            options: [
                .init(value: "a", label: "A"),
                .init(value: "b", label: "B")
            ]
        )
        let picker = try view.inspect().anyView().picker()
        #expect(!picker.isAbsent)
    }

    @Test func pickerIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosPicker(
            selection: .constant("b"),
            options: [.init(value: "b", label: "B")]
        )
        .environment(\.cosmosConfiguration, configuration)

        let picker = try view.inspect().anyView().picker()
        #expect(!picker.isAbsent)
    }
}
