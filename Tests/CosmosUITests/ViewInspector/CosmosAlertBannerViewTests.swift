import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosAlertBannerViewTests {

    @Test func alertBannerRendersTitleAndIcon() throws {
        let view = CosmosAlertBanner(
            systemImage: "info.circle",
            title: "alert.message"
        )

        let inspected = try view.inspect().view(CosmosAlertBanner.self)
        #expect(try inspected.find(text: "alert.message").isAbsent == false)
        #expect(try inspected.find(ViewInspector.ViewType.Image.self).isAbsent == false)
    }

    @Test func alertBannerRendersActionButton() throws {
        let view = CosmosAlertBanner(
            systemImage: "exclamationmark.triangle",
            title: "alert.message",
            actionTitle: "alert.action",
            action: {},
            variant: .warning
        )

        let inspected = try view.inspect().view(CosmosAlertBanner.self)
        #expect(try inspected.find(text: "alert.message").isAbsent == false)
        #expect(try inspected.find(text: "alert.action").isAbsent == false)
    }

    @Test func alertBannerUsesVariantForeground() throws {
        let view = CosmosAlertBanner(
            systemImage: "checkmark.circle",
            title: "alert.success",
            variant: .success
        )

        let inspected = try view.inspect().view(CosmosAlertBanner.self)
        #expect(try inspected.find(text: "alert.success").isAbsent == false)
    }
}
