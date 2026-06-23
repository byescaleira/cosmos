import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosStatusRowViewTests {

    @Test func statusRowRendersTitleAndSubtitle() throws {
        let view = CosmosStatusRow(
            systemImage: "bell.fill",
            title: "notification.title",
            subtitle: "notification.subtitle"
        )

        let inspected = try view.inspect().view(CosmosStatusRow.self)
        #expect(try inspected.find(text: "notification.title").isAbsent == false)
        #expect(try inspected.find(text: "notification.subtitle").isAbsent == false)
    }

    @Test func statusRowRendersBadge() throws {
        let view = CosmosStatusRow(
            systemImage: "bell.fill",
            title: "notification.title",
            badge: CosmosBadge("3", variant: .primary)
        )

        let inspected = try view.inspect().view(CosmosStatusRow.self)
        #expect(try inspected.find(text: "notification.title").isAbsent == false)
        #expect(try inspected.find(text: "3").isAbsent == false)
    }

    @Test func statusRowRendersImage() throws {
        let view = CosmosStatusRow(
            image: .system(name: "person.circle"),
            title: "user.status"
        )

        let inspected = try view.inspect().view(CosmosStatusRow.self)
        #expect(try inspected.find(text: "user.status").isAbsent == false)
        #expect(try inspected.find(ViewInspector.ViewType.Image.self).isAbsent == false)
    }
}
