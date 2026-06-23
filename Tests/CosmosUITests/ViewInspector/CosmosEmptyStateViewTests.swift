import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosEmptyStateViewTests {

    @Test func emptyStateRendersTitleAndSubtitle() throws {
        let view = CosmosEmptyState(
            title: "empty.title",
            subtitle: "empty.subtitle"
        )

        let inspected = try view.inspect().view(CosmosEmptyState.self)
        #expect(try inspected.find(text: "empty.title").isAbsent == false)
        #expect(try inspected.find(text: "empty.subtitle").isAbsent == false)
    }

    @Test func emptyStateRendersButton() throws {
        let view = CosmosEmptyState(
            title: "empty.title",
            buttonTitle: "empty.action",
            buttonAction: {}
        )

        let inspected = try view.inspect().view(CosmosEmptyState.self)
        #expect(try inspected.find(text: "empty.title").isAbsent == false)
        #expect(try inspected.find(text: "empty.action").isAbsent == false)
    }

    @Test func emptyStateRendersImage() throws {
        let view = CosmosEmptyState(
            image: .system(name: "magnifyingglass"),
            title: "empty.title"
        )

        let inspected = try view.inspect().view(CosmosEmptyState.self)
        #expect(try inspected.find(text: "empty.title").isAbsent == false)
        #expect(try inspected.find(ViewInspector.ViewType.Image.self).isAbsent == false)
    }
}
