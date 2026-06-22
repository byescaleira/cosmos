#if canImport(UIKit)
import Testing
import SwiftUI
import SnapshotTesting
import UIKit
@testable import CosmosScreen

@MainActor
struct CosmosScreenSnapshotTests {

    private let sampleScreen = CosmosScreen(
        id: "welcome",
        components: [
            .text(.init(contentKey: "Welcome")),
            .text(.init(contentKey: "Get started with Cosmos")),
            .spacer,
            .button(.init(titleKey: "Continue", action: .init(id: "continue")))
        ]
    )

    @Test func renderedScreen() {
        let view = CosmosScreenRenderer(screen: sampleScreen, registry: .init())
            .frame(width: 320, height: 480)

        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)

        assertSnapshot(of: controller, as: .image)
    }
}
#endif
