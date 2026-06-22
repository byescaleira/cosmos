import SwiftUI
import CosmosBase

/// A tab container atom that adapts to size class.
///
/// `CosmosTabView` wraps native SwiftUI containers. In compact width it uses
/// `TabView`; in regular width it uses `NavigationSplitView` with a sidebar
/// list of tabs. The host controls the strategy via `CosmosTabAdaptiveStrategy`
/// and can override it with the `.cosmosTabAdaptiveStrategy(_:)` environment
/// modifier.
///
/// Tabs are described by `CosmosTab` value types. Tab content is supplied
/// through a `@ViewBuilder` closure, which keeps the atom usable both inside
/// host SwiftUI code and from the JSON-driven `CosmosScreenRenderer`.
public struct CosmosTabView: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.cosmosTabAdaptiveStrategy) private var environmentStrategy

    @Binding var selection: String?
    let tabs: [CosmosTab]
    let strategy: CosmosTabAdaptiveStrategy
    let content: (CosmosTab) -> AnyView

    /// Creates an adaptive Cosmos tab view.
    public init(
        selection: Binding<String?>,
        tabs: [CosmosTab],
        strategy: CosmosTabAdaptiveStrategy = .automatic,
        @ViewBuilder content: @escaping (CosmosTab) -> some View
    ) {
        self._selection = selection
        self.tabs = tabs
        self.strategy = strategy
        self.content = { AnyView(content($0)) }
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var isEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly
    }

    private var effectiveStrategy: CosmosTabAdaptiveStrategy {
        let requested = environmentStrategy == .automatic ? strategy : environmentStrategy
        switch requested {
        case .automatic:
            return horizontalSizeClass == .regular ? .sidebar : .tabBar
        case .tabBar, .sidebar:
            return requested
        }
    }

    public var body: some View {
        tabBody
    }

    @ViewBuilder
    private var tabBody: some View {
        if effectiveVisible {
            switch effectiveStrategy {
            case .tabBar:
                tabBarBody
            case .sidebar:
                sidebarBody
            case .automatic:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var tabBarBody: some View {
        if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, visionOS 1, *) {
            TabView(selection: $selection) {
                ForEach(tabs) { tab in
                    content(tab)
                        .tabItem {
                            Label(tab.titleKey, systemImage: tab.systemImage ?? "")
                        }
                        .tag(tab.id)
                }
            }
            .disabled(!isEnabled)
            .accessibilityLabelOrNil(configuration.accessibility.label)
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    @ViewBuilder
    private var sidebarBody: some View {
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *) {
            NavigationSplitView {
                List(tabs, selection: $selection) { tab in
                    Label(tab.titleKey, systemImage: tab.systemImage ?? "")
                        .tag(tab.id)
                }
            } detail: {
                if let selection, let tab = tabs.first(where: { $0.id == selection }) {
                    content(tab)
                } else {
                    Text("Select a tab")
                }
            }
            .disabled(!isEnabled)
            .accessibilityLabelOrNil(configuration.accessibility.label)
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }
}

// MARK: - Tab descriptor

/// A lightweight description of a tab inside `CosmosTabView`.
///
/// `CosmosTab` carries only identity and label information; the content is
/// produced by the closure passed to `CosmosTabView`. This keeps the atom in
/// the `Cosmos` target free of `CosmosScreen` models and avoids a circular
/// dependency. The JSON renderer maps `CosmosTabModel` (which carries child
/// components) into `CosmosTab` + a recursive content builder.
public struct CosmosTab: Sendable, Equatable, Identifiable {
    public let id: String
    public let titleKey: String
    public let systemImage: String?
    public let role: CosmosTabRole

    public init(
        id: String,
        titleKey: String,
        systemImage: String? = nil,
        role: CosmosTabRole = .default
    ) {
        self.id = id
        self.titleKey = titleKey
        self.systemImage = systemImage
        self.role = role
    }
}

// MARK: - Environment modifier

extension View {
    /// Overrides the adaptive strategy for descendant `CosmosTabView` atoms.
    public func cosmosTabAdaptiveStrategy(_ strategy: CosmosTabAdaptiveStrategy) -> some View {
        environment(\.cosmosTabAdaptiveStrategy, strategy)
    }
}

private extension View {
    @ViewBuilder
    @available(iOS 14, macOS 11, tvOS 14, watchOS 7, visionOS 1, *)
    func redactedIfNeeded(_ isRedacted: Bool) -> some View {
        if isRedacted {
            self.redacted(reason: .placeholder)
        } else {
            self
        }
    }
}
