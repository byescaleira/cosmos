import SwiftUI
import CosmosBase

/// A menu atom.
///
/// `CosmosMenu` reads its visibility, enablement, accessibility, and theme from
/// the SwiftUI environment. It accepts a label and native `Menu` content
/// through its initializer. Override state and appearance through the
/// `.cosmos*` modifiers.
public struct CosmosMenu<Label: View, Content: View>: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let label: Label
    let content: Content

    /// Creates a Cosmos menu atom with a custom label and menu content.
    public init(
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label()
        self.content = content()
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var isEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? "Menu"
    }

    public var body: some View {
        if effectiveVisible {
            Menu(content: { content }, label: { label })
                .tint(theme.colors.accent)
                .disabled(!isEnabled)
                .controlSizeIfNeeded(theme.controlSize)
                .accessibilityLabel(Text(resolvedAccessibilityLabel))
                .accessibilityHintOrNil(configuration.accessibility.hint)
                .accessibilityHidden(configuration.accessibility.isHidden)
                .accessibilitySortPriority(configuration.accessibility.sortPriority)
                .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }
}

// MARK: - Convenience initializers

extension CosmosMenu where Label == Text {
    /// Creates a Cosmos menu atom with a localized title label.
    public init(
        _ titleKey: String,
        @ViewBuilder content: () -> Content
    ) {
        self.init(label: { Text(titleKey) }, content: content)
    }
}

private extension View {
    @ViewBuilder
    func controlSizeIfNeeded(_ size: CosmosControlSize) -> some View {
        if #available(iOS 15, macOS 11, tvOS 16, watchOS 9, visionOS 1, *) {
            self.controlSize(size.swiftUIValue)
        } else {
            self
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
