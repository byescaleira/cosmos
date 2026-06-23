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

    @Test func encodeThenDecodePreservesInputRow() throws {
        let screen = CosmosScreen(
            id: "input-screen",
            components: [
                .inputRow(.init(
                    labelKey: "login.name_label",
                    promptKey: "login.name_prompt",
                    secure: false,
                    initialText: "Rafael",
                    textChangeAction: .init(id: "name.changed")
                ))
            ]
        )

        let data = try loader.encode(screen: screen)
        let decoded = try loader.screen(from: data)

        #expect(decoded == screen)
    }

    @Test func encodeThenDecodePreservesListRow() throws {
        let screen = CosmosScreen(
            id: "listrow-screen",
            components: [
                .listRow(.init(
                    titleKey: "settings.account",
                    subtitleKey: "settings.account_subtitle",
                    systemImage: "person",
                    trailing: .chevron,
                    action: .init(id: "open.account")
                ))
            ]
        )

        let data = try loader.encode(screen: screen)
        let decoded = try loader.screen(from: data)

        #expect(decoded == screen)
    }

    @Test func encodeThenDecodePreservesFormRow() throws {
        let screen = CosmosScreen(
            id: "formrow-screen",
            components: [
                .formRow(.init(
                    titleKey: "settings.notifications",
                    systemImage: "bell",
                    control: .toggle,
                    initialValue: .bool(true),
                    valueChangeAction: .init(id: "notifications.changed")
                ))
            ]
        )

        let data = try loader.encode(screen: screen)
        let decoded = try loader.screen(from: data)

        #expect(decoded == screen)
    }

    @Test func encodeThenDecodePreservesEmptyState() throws {
        let screen = CosmosScreen(
            id: "empty-screen",
            components: [
                .emptyState(.init(
                    image: .system(name: "magnifyingglass"),
                    titleKey: "empty.title",
                    subtitleKey: "empty.subtitle",
                    buttonTitleKey: "empty.action",
                    buttonAction: .init(id: "empty.action")
                ))
            ]
        )

        let data = try loader.encode(screen: screen)
        let decoded = try loader.screen(from: data)

        #expect(decoded == screen)
    }

    @Test func encodeThenDecodePreservesButtonRow() throws {
        let screen = CosmosScreen(
            id: "buttonrow-screen",
            components: [
                .buttonRow(.init(
                    titleKey: "continue.title",
                    systemImage: "arrow.right",
                    variant: .primary,
                    action: .init(id: "continue")
                ))
            ]
        )

        let data = try loader.encode(screen: screen)
        let decoded = try loader.screen(from: data)

        #expect(decoded == screen)
    }

    @Test func encodeThenDecodePreservesSearchBar() throws {
        let screen = CosmosScreen(
            id: "searchbar-screen",
            components: [
                .searchBar(.init(
                    placeholderKey: "search.placeholder",
                    initialText: "query",
                    textChangeAction: .init(id: "search.textChanged"),
                    clearAction: .init(id: "search.cleared")
                ))
            ]
        )

        let data = try loader.encode(screen: screen)
        let decoded = try loader.screen(from: data)

        #expect(decoded == screen)
    }

    @Test func encodeThenDecodePreservesStatusRow() throws {
        let screen = CosmosScreen(
            id: "statusrow-screen",
            components: [
                .statusRow(.init(
                    systemImage: "bell.fill",
                    titleKey: "notification.title",
                    subtitleKey: "notification.subtitle",
                    badge: .init(text: "3", variant: .primary)
                ))
            ]
        )

        let data = try loader.encode(screen: screen)
        let decoded = try loader.screen(from: data)

        #expect(decoded == screen)
    }

    @Test func encodeThenDecodePreservesCard() throws {
        let screen = CosmosScreen(
            id: "card-screen",
            components: [
                .card(.init(
                    image: .system(name: "photo"),
                    titleKey: "card.title",
                    subtitleKey: "card.subtitle",
                    badge: .init(text: "New", variant: .success),
                    buttonTitleKey: "card.action",
                    buttonAction: .init(id: "card.tapped")
                ))
            ]
        )

        let data = try loader.encode(screen: screen)
        let decoded = try loader.screen(from: data)

        #expect(decoded == screen)
    }

    @Test func encodeThenDecodePreservesAlertBanner() throws {
        let screen = CosmosScreen(
            id: "alert-screen",
            components: [
                .alertBanner(.init(
                    systemImage: "exclamationmark.triangle",
                    titleKey: "alert.title",
                    actionTitleKey: "alert.action",
                    action: .init(id: "alert.tapped"),
                    variant: .warning
                ))
            ]
        )

        let data = try loader.encode(screen: screen)
        let decoded = try loader.screen(from: data)

        #expect(decoded == screen)
    }

    @Test func encodeThenDecodePreservesLoadingState() throws {
        let screen = CosmosScreen(
            id: "loading-screen",
            components: [
                .loadingState(.init(
                    titleKey: "loading.title",
                    subtitleKey: "loading.subtitle",
                    progressValue: 0.42
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
