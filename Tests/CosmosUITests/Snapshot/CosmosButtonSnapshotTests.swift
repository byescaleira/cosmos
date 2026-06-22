#if canImport(UIKit)
import Testing
import SwiftUI
import SnapshotTesting
import UIKit
@testable import Cosmos

@MainActor
struct CosmosButtonSnapshotTests {

    @Test func primaryButton() {
        let view = CosmosButton("Continue") { }
            .frame(width: 200, height: 44)
            .padding(16)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 232, height: 76)

        assertSnapshot(of: controller, as: .image)
    }

    @Test func disabledButton() {
        let view = CosmosButton("Continue") { }
            .cosmosEnabled(false)
            .frame(width: 200, height: 44)
            .padding(16)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 232, height: 76)

        assertSnapshot(of: controller, as: .image)
    }

    @Test func loadingButton() {
        let view = CosmosButton("Continue") { }
            .cosmosLoading(true)
            .frame(width: 200, height: 44)
            .padding(16)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 232, height: 76)

        assertSnapshot(of: controller, as: .image)
    }
}
#endif
