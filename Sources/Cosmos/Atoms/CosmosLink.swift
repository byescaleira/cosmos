import SwiftUI
import CosmosBase

/// A link atom.
///
/// `CosmosLink` reads its visibility, accessibility, and color from the SwiftUI
/// environment. It accepts a destination URL and a label through its initializer.
/// Override theme and state through the `.cosmos*` modifiers.
public struct CosmosLink<Label: View>: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let url: URL
    let label: Label
    let underline: Bool

    /// Creates a Cosmos link atom with a custom label view.
    public init(
        url: URL,
        underline: Bool = true,
        @ViewBuilder label: () -> Label
    ) {
        self.url = url
        self.underline = underline
        self.label = label()
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? url.absoluteString
    }

    public var body: some View {
        if effectiveVisible {
            Link(destination: url) {
                label
                    .foregroundStyle(theme.colors.accent)
                    .underline(underline)
            }
            .accessibilityLabel(Text(resolvedAccessibilityLabel))
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }
}

// MARK: - Convenience initializers

extension CosmosLink where Label == Text {
    /// Creates a Cosmos link atom that displays a localized string.
    public init(
        _ titleKey: String,
        url: URL,
        underline: Bool = true
    ) {
        self.init(url: url, underline: underline) {
            Text(titleKey)
        }
    }
}

extension CosmosLink where Label == Text {
    /// Creates a Cosmos link atom from a URL string.
    public init?(
        _ titleKey: String,
        urlString: String,
        underline: Bool = true
    ) {
        guard let url = URL(string: urlString),
              url.scheme != nil,
              url.host() != nil
        else { return nil }
        self.init(titleKey, url: url, underline: underline)
    }
}

private extension View {
    @ViewBuilder
    func underline(_ underline: Bool) -> some View {
        if underline {
            self.underline()
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
