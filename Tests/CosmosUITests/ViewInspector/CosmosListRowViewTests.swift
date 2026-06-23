import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosListRowViewTests {

    @Test func listRowRendersTitleAndIcon() throws {
        let view = CosmosListRow(
            "settings.account",
            subtitle: "settings.account_subtitle",
            systemImage: "person",
            trailing: .chevron
        )

        let inspected = try view.inspect().view(CosmosListRow.self)
        #expect(try inspected.find(text: "settings.account").isAbsent == false)
        #expect(try inspected.find(text: "settings.account_subtitle").isAbsent == false)
        #expect(try inspected.find(ViewInspector.ViewType.Image.self).isAbsent == false)
    }

    @Test func listRowRendersBadgeTrailing() throws {
        let view = CosmosListRow(
            "notifications.title",
            trailing: .badge(text: "3", variant: .primary)
        )

        let inspected = try view.inspect().view(CosmosListRow.self)
        #expect(try inspected.find(text: "notifications.title").isAbsent == false)
        #expect(try inspected.find(text: "3").isAbsent == false)
    }

    @Test func listRowRendersValueTrailing() throws {
        let view = CosmosListRow(
            "profile.language",
            trailing: .text("English")
        )

        let inspected = try view.inspect().view(CosmosListRow.self)
        #expect(try inspected.find(text: "profile.language").isAbsent == false)
        #expect(try inspected.find(text: "English").isAbsent == false)
    }
}
