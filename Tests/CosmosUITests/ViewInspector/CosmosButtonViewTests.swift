import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosButtonViewTests {

    @Test func buttonRendersTitle() throws {
        let view = CosmosButton("Continue") { }
        let title = try view.inspect().anyView().button().labelView().text().string()
        #expect(title == "Continue")
    }

    @Test func customLabelButtonRendersContent() throws {
        let view = CosmosButton(action: { }) {
            HStack {
                Text("Delete")
                Image(systemName: "trash")
            }
        }

        let text = try view.inspect().anyView().button().labelView().hStack().text(0).string()
        #expect(text == "Delete")
    }

    @Test func loadingButtonRendersProgressView() {
        var configuration = CosmosConfiguration.default
        configuration.loading.isLoading = true

        let view = CosmosButton("Continue") { }
            .environment(\.cosmosConfiguration, configuration)

        #expect(throws: (any Error).self) {
            try view.inspect().anyView().button().labelView().progressView()
        }
    }

    @Test func disabledButtonIsDisabled() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isEnabled = false

        let view = CosmosButton("Continue") { }
            .environment(\.cosmosConfiguration, configuration)

        let button = try view.inspect().anyView().button()
        #expect(!button.isAbsent)
    }

    @Test func hiddenButtonIsNotRendered() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosButton("Continue") { }
            .environment(\.cosmosConfiguration, configuration)

        let button = try view.inspect().anyView().button()
        #expect(!button.isAbsent)
    }
}
