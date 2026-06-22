import SwiftUI
import CosmosBase

/// A list container atom.
///
/// `CosmosList` wraps SwiftUI `List` and reads visibility, enablement,
/// accessibility, and theme from the environment. It accepts content through
/// `@ViewBuilder`. Provide a `Binding<Set<String>>` for multi-selection, or
/// omit selection for a display-only list.
///
/// The list style is controlled by a cross-platform `CosmosListStyle` token;
/// the atom maps it to the appropriate SwiftUI `ListStyle` at runtime.
public struct CosmosList<Content: View>: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    @Binding var selection: Set<String>
    let style: CosmosListStyle
    let content: Content

    /// Creates a Cosmos list with multi-selection support.
    public init(
        selection: Binding<Set<String>>,
        style: CosmosListStyle = .automatic,
        @ViewBuilder content: () -> Content
    ) {
        self._selection = selection
        self.style = style
        self.content = content()
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var isEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly
    }

    public var body: some View {
        listBody
    }

    @ViewBuilder
    private var listBody: some View {
        if effectiveVisible {
            List(selection: $selection) {
                content
            }
            .cosmosListStyle(style)
            .disabled(!isEnabled)
            .accessibilityLabelOrNil(configuration.accessibility.label)
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }
}

// MARK: - Convenience initializers

extension CosmosList {
    /// Creates a Cosmos list without selection.
    public init(
        style: CosmosListStyle = .automatic,
        @ViewBuilder content: () -> Content
    ) {
        self.init(selection: .constant([]), style: style, content: content)
    }
}

// MARK: - Style mapping

private extension View {
    @ViewBuilder
    func cosmosListStyle(_ style: CosmosListStyle) -> some View {
        switch style {
        case .automatic:
            self.listStyle(.automatic)
        case .plain:
            self.listStyle(.plain)
        case .grouped:
            #if os(iOS) || os(tvOS) || os(watchOS)
            self.listStyle(.grouped)
            #else
            self.listStyle(.automatic)
            #endif
        case .insetGrouped:
            #if os(iOS) || os(tvOS) || os(watchOS)
            self.listStyle(.insetGrouped)
            #else
            self.listStyle(.automatic)
            #endif
        case .sidebar:
            #if canImport(UIKit)
            self.listStyle(.sidebar)
            #elseif os(macOS)
            if #available(macOS 13, *) {
                self.listStyle(.sidebar)
            } else {
                self.listStyle(.automatic)
            }
            #else
            self.listStyle(.automatic)
            #endif
        }
    }

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
