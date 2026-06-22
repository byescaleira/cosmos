import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos
@testable import CosmosScreen

@MainActor
struct CosmosScreenRendererTests {

    private let loginScreen = CosmosScreen(
        id: "login",
        components: [
            .text(.init(contentKey: "login.welcome")),
            .spacer(.init()),
            .button(.init(titleKey: "login.continue", action: .init(id: "continue")))
        ]
    )

    @Test func rendererProducesVStack() throws {
        let view = CosmosScreenRenderer(screen: loginScreen, registry: .init())
        let vstack = try view.inspect().anyView().vStack()
        #expect(!vstack.isAbsent)
    }

    @Test func rendererContainsExpectedChildren() throws {
        let view = CosmosScreenRenderer(screen: loginScreen, registry: .init())
        let children = try view.inspect().anyView().vStack().forEach(0)

        _ = try children.anyView(0).view(CosmosText.self).text(0)
        _ = try children.anyView(1).view(CosmosSpacer.self).spacer(0)
        _ = try children.anyView(2).view(CosmosButton<Text>.self).anyView().button(0)
    }

    @Test func nestedStackRendererProducesHierarchy() throws {
        let screen = CosmosScreen(
            id: "nested",
            components: [
                .hStack(.init(components: [
                    .text(.init(contentKey: "left")),
                    .text(.init(contentKey: "right"))
                ]))
            ]
        )

        let view = CosmosScreenRenderer(screen: screen, registry: .init())
            .environment(
                \.cosmosConfiguration,
                .default.withLocalization(locale: Locale(identifier: "en"))
            )

        let hstack = try view.inspect().anyView().vStack().forEach(0).anyView(0).hStack(0)
        let left = try hstack.forEach(0).anyView(0).view(CosmosText.self).text(0).string()
        let right = try hstack.forEach(0).anyView(1).view(CosmosText.self).text(0).string()

        #expect(left == "Left")
        #expect(right == "Right")
    }

    @Test func rendererRendersListWithSection() throws {
        let screen = CosmosScreen(
            id: "list",
            components: [
                .list(.init(
                    style: .plain,
                    sections: [
                        .init(
                            header: [.text(.init(contentKey: "list.header"))],
                            components: [
                                .text(.init(contentKey: "list.item"))
                            ]
                        )
                    ]
                ))
            ]
        )

        let view = CosmosScreenRenderer(screen: screen, registry: .init())
            .environment(
                \.cosmosConfiguration,
                .default.withLocalization(locale: Locale(identifier: "en"))
            )

        let rendered = try view.inspect().anyView().vStack().forEach(0).anyView(0)
        #expect(try rendered.find(text: "list.header").string() == "list.header")
        #expect(try rendered.find(text: "list.item").string() == "list.item")
    }

    @Test func rendererRendersTabView() throws {
        let screen = CosmosScreen(
            id: "tabs",
            components: [
                .tabView(.init(
                    strategy: .tabBar,
                    selectedTabID: "home",
                    tabs: [
                        .init(
                            id: "home",
                            titleKey: "tab.home",
                            systemImage: "house",
                            components: [.text(.init(contentKey: "home.content"))]
                        )
                    ]
                ))
            ]
        )

        let view = CosmosScreenRenderer(screen: screen, registry: .init())

        let rendered = try view.inspect().anyView().vStack().forEach(0).anyView(0)
        #expect(try rendered.find(text: "tab.home").isAbsent == false)
        #expect(try rendered.find(text: "home.content").isAbsent == false)
    }
}
