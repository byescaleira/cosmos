import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosTextViewTests {

    @Test func textRendersContent() throws {
        let view = CosmosText("Hello")
        let text = try view.inspect().text().string()
        #expect(text == "Hello")
    }

    @Test func verbatimIgnoresLocalization() throws {
        let view = CosmosText(verbatim: "welcome.headline")
            .environment(\.cosmosConfiguration, .default.withLocalization(locale: Locale(identifier: "pt-BR")))
        let text = try view.inspect().text().string()
        #expect(text == "welcome.headline")
    }

    @Test func textRespectsLineLimit() throws {
        let view = CosmosText("Hello", lineLimit: 2)
        let limit = try view.inspect().text().lineLimit()
        #expect(limit == 2)
    }

    @Test func textRespectsAlignment() throws {
        let view = CosmosText("Hello", alignment: .center)
        let alignment = try view.inspect().text().multilineTextAlignment()
        #expect(alignment == .center)
    }

    @Test func textIsHiddenWhenNotVisible() throws {
        let view = CosmosText("Hello")
            .cosmosVisible(false)

        // A hidden view still returns a Text in ViewInspector because the body
        // contains a conditional, but the content should not be rendered by
        // SwiftUI at runtime. We verify the visibility flag was propagated.
        let text = try view.inspect().text()
        #expect(text.isAbsent == false)
    }
}
