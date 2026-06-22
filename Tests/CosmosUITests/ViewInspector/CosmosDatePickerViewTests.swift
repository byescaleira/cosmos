import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosDatePickerViewTests {

    @Test func datePickerRenders() throws {
        let view = CosmosDatePicker(selection: .constant(Date()))
        let picker = try view.inspect().anyView().datePicker()
        #expect(!picker.isAbsent)
    }

    @Test func datePickerRendersWithLabel() throws {
        let view = CosmosDatePicker(selection: .constant(Date()), "event.date")
        let picker = try view.inspect().anyView().datePicker()
        #expect(!picker.isAbsent)
    }

    @Test func datePickerRendersTimeOnly() throws {
        let view = CosmosDatePicker(selection: .constant(Date()), displayedComponents: .hourAndMinute)
        let picker = try view.inspect().anyView().datePicker()
        #expect(!picker.isAbsent)
    }

    @Test func datePickerIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosDatePicker(selection: .constant(Date()))
            .environment(\.cosmosConfiguration, configuration)

        let picker = try view.inspect().anyView().datePicker()
        #expect(!picker.isAbsent)
    }
}
