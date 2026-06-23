import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosButtonRowViewTests {

    @Test func buttonRowRendersTitleAndIcon() throws {
        let view = CosmosButtonRow(
            "continue.title",
            systemImage: "arrow.right",
            action: {}
        )

        let inspected = try view.inspect().view(CosmosButtonRow.self)
        #expect(try inspected.find(text: "continue.title").isAbsent == false)
        #expect(try inspected.find(ViewInspector.ViewType.Image.self).isAbsent == false)
    }

    @Test func buttonRowRendersWithoutIcon() throws {
        let view = CosmosButtonRow(
            "save.title",
            action: {}
        )

        let inspected = try view.inspect().view(CosmosButtonRow.self)
        #expect(try inspected.find(text: "save.title").isAbsent == false)
    }
}
