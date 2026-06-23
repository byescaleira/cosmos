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

    @Test func rendererRendersInputRow() throws {
        let screen = CosmosScreen(
            id: "input",
            components: [
                .inputRow(.init(
                    labelKey: "login.name_label",
                    promptKey: "login.name_prompt",
                    secure: false,
                    initialText: "Rafael"
                ))
            ]
        )

        let view = CosmosScreenRenderer(screen: screen, registry: .init())
            .environment(
                \.cosmosConfiguration,
                .default.withLocalization(locale: Locale(identifier: "en"))
            )

        let rendered = try view.inspect().anyView().vStack().forEach(0).anyView(0)
        #expect(try rendered.find(text: "login.name_label").isAbsent == false)
        #expect(try rendered.find(ViewInspector.ViewType.TextField.self).isAbsent == false)
    }

    @Test func rendererRendersListRow() throws {
        let screen = CosmosScreen(
            id: "listrow",
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

        let view = CosmosScreenRenderer(screen: screen, registry: .init())
            .environment(
                \.cosmosConfiguration,
                .default.withLocalization(locale: Locale(identifier: "en"))
            )

        let rendered = try view.inspect().anyView().vStack().forEach(0).anyView(0)
        #expect(try rendered.find(text: "settings.account").isAbsent == false)
        #expect(try rendered.find(text: "settings.account_subtitle").isAbsent == false)
    }

    @Test func rendererRendersCard() throws {
        let screen = CosmosScreen(
            id: "card",
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

        let view = CosmosScreenRenderer(screen: screen, registry: .init())
            .environment(
                \.cosmosConfiguration,
                .default.withLocalization(locale: Locale(identifier: "en"))
            )

        let rendered = try view.inspect().anyView().vStack().forEach(0).anyView(0)
        #expect(try rendered.find(text: "card.title").isAbsent == false)
        #expect(try rendered.find(text: "card.subtitle").isAbsent == false)
        #expect(try rendered.find(text: "New").isAbsent == false)
    }

    @Test func rendererRendersStatusRow() throws {
        let screen = CosmosScreen(
            id: "statusrow",
            components: [
                .statusRow(.init(
                    systemImage: "bell.fill",
                    titleKey: "notification.title",
                    subtitleKey: "notification.subtitle",
                    badge: .init(text: "3", variant: .primary)
                ))
            ]
        )

        let view = CosmosScreenRenderer(screen: screen, registry: .init())
            .environment(
                \.cosmosConfiguration,
                .default.withLocalization(locale: Locale(identifier: "en"))
            )

        let rendered = try view.inspect().anyView().vStack().forEach(0).anyView(0)
        #expect(try rendered.find(text: "notification.title").isAbsent == false)
        #expect(try rendered.find(text: "notification.subtitle").isAbsent == false)
        #expect(try rendered.find(text: "3").isAbsent == false)
    }

    @Test func rendererRendersAlertBanner() throws {
        let screen = CosmosScreen(
            id: "alert",
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

        let view = CosmosScreenRenderer(screen: screen, registry: .init())
            .environment(
                \.cosmosConfiguration,
                .default.withLocalization(locale: Locale(identifier: "en"))
            )

        let rendered = try view.inspect().anyView().vStack().forEach(0).anyView(0)
        #expect(try rendered.find(text: "alert.title").isAbsent == false)
        #expect(try rendered.find(text: "alert.action").isAbsent == false)
    }

    @Test func rendererRendersLoadingState() throws {
        let screen = CosmosScreen(
            id: "loading",
            components: [
                .loadingState(.init(
                    titleKey: "loading.title",
                    subtitleKey: "loading.subtitle",
                    progressValue: 0.42
                ))
            ]
        )

        let view = CosmosScreenRenderer(screen: screen, registry: .init())
            .environment(
                \.cosmosConfiguration,
                .default.withLocalization(locale: Locale(identifier: "en"))
            )

        let rendered = try view.inspect().anyView().vStack().forEach(0).anyView(0)
        #expect(try rendered.find(text: "loading.title").isAbsent == false)
        #expect(try rendered.find(text: "loading.subtitle").isAbsent == false)
    }

    @Test func rendererRendersSearchBar() throws {
        let screen = CosmosScreen(
            id: "searchbar",
            components: [
                .searchBar(.init(
                    placeholderKey: "search.placeholder",
                    initialText: "query"
                ))
            ]
        )

        let view = CosmosScreenRenderer(screen: screen, registry: .init())
            .environment(
                \.cosmosConfiguration,
                .default.withLocalization(locale: Locale(identifier: "en"))
            )

        let rendered = try view.inspect().anyView().vStack().forEach(0).anyView(0)
        #expect(try rendered.find(ViewInspector.ViewType.TextField.self).isAbsent == false)
        #expect(try rendered.find(ViewInspector.ViewType.Image.self).isAbsent == false)
    }

    @Test func rendererRendersButtonRow() throws {
        let screen = CosmosScreen(
            id: "buttonrow",
            components: [
                .buttonRow(.init(
                    titleKey: "continue.title",
                    systemImage: "arrow.right",
                    variant: .primary,
                    action: .init(id: "continue")
                ))
            ]
        )

        let view = CosmosScreenRenderer(screen: screen, registry: .init())
            .environment(
                \.cosmosConfiguration,
                .default.withLocalization(locale: Locale(identifier: "en"))
            )

        let rendered = try view.inspect().anyView().vStack().forEach(0).anyView(0)
        #expect(try rendered.find(text: "continue.title").isAbsent == false)
        #expect(try rendered.find(ViewInspector.ViewType.Image.self).isAbsent == false)
    }

    @Test func rendererRendersEmptyState() throws {
        let screen = CosmosScreen(
            id: "empty",
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

        let view = CosmosScreenRenderer(screen: screen, registry: .init())
            .environment(
                \.cosmosConfiguration,
                .default.withLocalization(locale: Locale(identifier: "en"))
            )

        let rendered = try view.inspect().anyView().vStack().forEach(0).anyView(0)
        #expect(try rendered.find(text: "empty.title").isAbsent == false)
        #expect(try rendered.find(text: "empty.subtitle").isAbsent == false)
        #expect(try rendered.find(text: "empty.action").isAbsent == false)
    }

    @Test func rendererRendersFormRow() throws {
        let screen = CosmosScreen(
            id: "formrow",
            components: [
                .formRow(.init(
                    titleKey: "settings.notifications",
                    systemImage: "bell",
                    control: .toggle,
                    initialValue: .bool(true)
                ))
            ]
        )

        let view = CosmosScreenRenderer(screen: screen, registry: .init())
            .environment(
                \.cosmosConfiguration,
                .default.withLocalization(locale: Locale(identifier: "en"))
            )

        let rendered = try view.inspect().anyView().vStack().forEach(0).anyView(0)
        #expect(try rendered.find(text: "settings.notifications").isAbsent == false)
        #expect(try rendered.find(ViewInspector.ViewType.Toggle.self).isAbsent == false)
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
