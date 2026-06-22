import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosTextFieldViewTests {

    @Test func textFieldRendersField() throws {
        let view = CosmosTextField(text: .constant("Hello"))
        let field = try view.inspect().anyView().textField()
        #expect(!field.isAbsent)
    }

    @Test func textFieldRendersPrompt() throws {
        let view = CosmosTextField(text: .constant(""), prompt: "welcome.headline")
        let field = try view.inspect().anyView().textField()
        #expect(!field.isAbsent)
    }

    @Test func secureTextFieldRendersSecureField() throws {
        let view = CosmosTextField(text: .constant("secret"), secure: true)
        let field = try view.inspect().anyView().secureField()
        #expect(!field.isAbsent)
    }

    @Test func textFieldIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosTextField(text: .constant(""))
            .environment(\.cosmosConfiguration, configuration)

        let field = try view.inspect().anyView().textField()
        #expect(!field.isAbsent)
    }
}
