import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosTextField")
struct CosmosTextFieldTests {

    // MARK: - Construction

    @Test func textFieldConstructsFromLocalizedKey() {
        _ = CosmosTextField("preview.title", text: .constant(""))
    }

    @Test func textFieldConstructsFromVerbatimTitle() {
        _ = CosmosTextField(verbatim: "Name", text: .constant(""))
    }

    @Test func textFieldConstructsFromLocalizedKeyWithPrompt() {
        _ = CosmosTextField("preview.title", text: .constant(""), prompt: Text("preview.description"))
    }

    @Test func textFieldConstructsWithCustomLabel() {
        _ = CosmosTextField(text: .constant("")) { Text(verbatim: "Field") }
    }

    @Test func textFieldConstructsWithOnSubmit() {
        _ = CosmosTextField(text: .constant(""), onSubmit: {}) { Text(verbatim: "Field") }
    }

    @Test(.tags(.selector), arguments: CosmosTextFieldStyle.allCases)
    func textFieldAcceptsEveryStyleVariant(_ style: CosmosTextFieldStyle) {
        _ = CosmosTextField("preview.title", text: .constant("")).cosmosTextFieldStyle(style)
    }

    // MARK: - Style selector enum

    @Test func textFieldStyleAllCases() {
        #expect(CosmosTextFieldStyle.allCases == [.automatic, .plain, .bordered, .cosmos])
    }
}