import Testing
import Foundation
@testable import CosmosScreen

struct CosmosScreenRoundTripTests {

    private let loader = CosmosScreenLoader()

    private var screen: CosmosScreen {
        CosmosScreen(
            id: "welcome",
            titleKey: "welcome.title",
            layout: .init(
                root: .vStack,
                spacing: .medium,
                padding: .large,
                alignment: .center
            ),
            components: [
                .text(.init(contentKey: "welcome.headline")),
                .text(.init(contentKey: "welcome.body")),
                .spacer(.init()),
                .button(.init(
                    titleKey: "welcome.continue",
                    action: .init(id: "continue")
                )),
                .icon(.init(systemName: "star.fill")),
                .divider,
                .hStack(.init(
                    components: [
                        .text(.init(contentKey: "left")),
                        .text(.init(contentKey: "right"))
                    ],
                    spacing: .small,
                    alignment: .leading
                ))
            ]
        )
    }

    @Test func encodeThenDecodePreservesScreen() throws {
        let json = try loader.jsonString(for: screen)
        let decoded = try loader.screen(from: json)

        #expect(decoded == screen)
    }

    @Test func encodeThenDecodePreservesLayoutAndComponents() throws {
        let data = try loader.encode(screen: screen)
        let decoded = try loader.screen(from: data)

        #expect(decoded.id == "welcome")
        #expect(decoded.titleKey == "welcome.title")
        #expect(decoded.layout.root == CosmosContainerType.vStack)
        #expect(decoded.layout.spacing == CosmosPadding.medium)
        #expect(decoded.layout.padding == CosmosPadding.large)
        #expect(decoded.layout.alignment == CosmosStackAlignment.center)
        #expect(decoded.components.count == 7)

        guard case .hStack(let stack) = decoded.components[safe: 6] else {
            Issue.record("Expected hStack at index 6")
            return
        }
        #expect(stack.alignment == CosmosStackAlignment.leading)
        #expect(stack.spacing == CosmosPadding.small)
        #expect(stack.components.count == 2)
    }

    @Test func encodeThenDecodePreservesListAndSection() throws {
        let screen = CosmosScreen(
            id: "list-screen",
            components: [
                .list(.init(
                    style: .insetGrouped,
                    selectedItemIDs: ["one"],
                    sections: [
                        .init(
                            header: [.text(.init(contentKey: "section.header"))],
                            components: [
                                .text(.init(contentKey: "section.item"))
                            ]
                        )
                    ]
                ))
            ]
        )

        let data = try loader.encode(screen: screen)
        let decoded = try loader.screen(from: data)

        #expect(decoded == screen)
    }

    @Test func encodeThenDecodePreservesTabView() throws {
        let screen = CosmosScreen(
            id: "tab-screen",
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
                        ),
                        .init(
                            id: "settings",
                            titleKey: "tab.settings",
                            systemImage: "gear",
                            components: [.text(.init(contentKey: "settings.content"))]
                        )
                    ]
                ))
            ]
        )

        let data = try loader.encode(screen: screen)
        let decoded = try loader.screen(from: data)

        #expect(decoded == screen)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
