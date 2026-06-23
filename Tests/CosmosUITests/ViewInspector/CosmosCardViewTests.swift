import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosCardViewTests {

    @Test func cardRendersTitleAndSubtitle() throws {
        let view = CosmosCard(
            title: "card.title",
            subtitle: "card.subtitle"
        )

        let inspected = try view.inspect().view(CosmosCard.self)
        #expect(try inspected.find(text: "card.title").isAbsent == false)
        #expect(try inspected.find(text: "card.subtitle").isAbsent == false)
    }

    @Test func cardRendersBadgeAndButton() throws {
        let view = CosmosCard(
            title: "card.title",
            badge: CosmosBadge("New", variant: .success),
            buttonTitle: "card.action",
            buttonAction: {}
        )

        let inspected = try view.inspect().view(CosmosCard.self)
        #expect(try inspected.find(text: "card.title").isAbsent == false)
        #expect(try inspected.find(text: "New").isAbsent == false)
        #expect(try inspected.find(text: "card.action").isAbsent == false)
    }

    @Test func cardRendersImage() throws {
        let view = CosmosCard(
            image: .system(name: "photo"),
            title: "card.title"
        )

        let inspected = try view.inspect().view(CosmosCard.self)
        #expect(try inspected.find(text: "card.title").isAbsent == false)
        #expect(try inspected.find(ViewInspector.ViewType.Image.self).isAbsent == false)
    }
}
