import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosFormRowViewTests {

    @Test func formRowRendersToggle() throws {
        let view = CosmosFormRow(
            "settings.notifications",
            systemImage: "bell",
            control: .toggle(.constant(true))
        )

        let inspected = try view.inspect().view(CosmosFormRow.self)
        #expect(try inspected.find(text: "settings.notifications").isAbsent == false)
        #expect(try inspected.find(ViewInspector.ViewType.Toggle.self).isAbsent == false)
    }

    @Test func formRowRendersPicker() throws {
        let view = CosmosFormRow(
            "settings.theme",
            control: .picker(
                .constant("light"),
                [
                    .init(value: "light", label: "Light"),
                    .init(value: "dark", label: "Dark")
                ]
            )
        )

        let inspected = try view.inspect().view(CosmosFormRow.self)
        #expect(try inspected.find(text: "settings.theme").isAbsent == false)
        #expect(try inspected.find(ViewInspector.ViewType.Picker.self).isAbsent == false)
    }

    @Test func formRowRendersValue() throws {
        let view = CosmosFormRow(
            "settings.language",
            control: .value("English")
        )

        let inspected = try view.inspect().view(CosmosFormRow.self)
        #expect(try inspected.find(text: "settings.language").isAbsent == false)
        #expect(try inspected.find(text: "English").isAbsent == false)
    }
}
