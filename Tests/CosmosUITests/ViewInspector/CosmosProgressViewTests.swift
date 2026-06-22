import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosProgressViewTests {

    @Test func progressRendersIndeterminateSpinner() throws {
        let view = CosmosProgress()
        let progress = try view.inspect().progressView()
        #expect(!progress.isAbsent)
    }

    @Test func progressRendersDeterminateBar() throws {
        let view = CosmosProgress(value: 0.5)
        let progress = try view.inspect().progressView()
        #expect(!progress.isAbsent)
    }

    @Test func progressIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosProgress()
            .environment(\.cosmosConfiguration, configuration)

        let progress = try view.inspect().progressView()
        #expect(!progress.isAbsent)
    }
}
