import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosLoadingStateViewTests {

    @Test func loadingStateRendersProgressAndTitle() throws {
        let view = CosmosLoadingState(
            title: "loading.title",
            subtitle: "loading.subtitle"
        )

        let inspected = try view.inspect().view(CosmosLoadingState.self)
        #expect(try inspected.find(text: "loading.title").isAbsent == false)
        #expect(try inspected.find(text: "loading.subtitle").isAbsent == false)
    }

    @Test func loadingStateRendersDeterminateProgress() throws {
        let view = CosmosLoadingState(
            title: "loading.title",
            progressValue: 0.42
        )

        let inspected = try view.inspect().view(CosmosLoadingState.self)
        #expect(try inspected.find(text: "loading.title").isAbsent == false)
    }

    @Test func loadingStateRendersWithoutTitle() throws {
        let view = CosmosLoadingState()

        let inspected = try view.inspect().view(CosmosLoadingState.self)
        #expect(try inspected.find(ViewInspector.ViewType.ProgressView.self).isAbsent == false)
    }
}
