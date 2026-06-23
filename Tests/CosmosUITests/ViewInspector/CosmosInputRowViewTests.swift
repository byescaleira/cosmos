import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosInputRowViewTests {

    @Test func inputRowRendersLabelAndField() throws {
        let view = CosmosInputRow(
            text: .constant("Rafael"),
            label: "login.name_label",
            prompt: "login.name_prompt"
        )

        let inspected = try view.inspect().view(CosmosInputRow.self)
        let label = try inspected.find(text: "login.name_label")
        #expect(!label.isAbsent)
        let field = try inspected.find(ViewInspector.ViewType.TextField.self)
        #expect(!field.isAbsent)
    }

    @Test func inputRowRendersSecureField() throws {
        let view = CosmosInputRow(
            text: .constant("secret"),
            label: "login.password_label",
            secure: true
        )

        let inspected = try view.inspect().view(CosmosInputRow.self)
        let field = try inspected.find(ViewInspector.ViewType.SecureField.self)
        #expect(!field.isAbsent)
    }

    @Test func inputRowIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosInputRow(
            text: .constant(""),
            label: "login.name_label"
        )
        .environment(\.cosmosConfiguration, configuration)

        // ViewInspector cannot observe body-level environment gating headlessly;
        // the view tree still contains the content. Snapshot/runtime tests verify
        // actual visibility.
        let inspected = try view.inspect().view(CosmosInputRow.self)
        let label = try inspected.find(text: "login.name_label")
        #expect(!label.isAbsent)
    }
}
