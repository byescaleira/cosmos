import SwiftUI
import CosmosBase

/// A text atom.
///
/// `CosmosText` reads its visibility, accessibility, typography, color, and
/// text behavior from the SwiftUI environment. It accepts only a localization
/// key through its initializer and resolves the displayed string using the
/// current `CosmosLocalizationConfiguration`.
public struct CosmosText: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let contentKey: String
    let verbatim: String?
    let lineLimit: Int?
    let alignment: TextAlignment?
    let truncationMode: Text.TruncationMode?

    /// Creates a Cosmos text atom from a localization key.
    ///
    /// The key is resolved through the environment's localization configuration,
    /// falling back to the raw key when no translation is found.
    public init(
        _ contentKey: String,
        lineLimit: Int? = nil,
        alignment: TextAlignment? = nil,
        truncationMode: Text.TruncationMode? = nil
    ) {
        self.contentKey = contentKey
        self.verbatim = nil
        self.lineLimit = lineLimit
        self.alignment = alignment
        self.truncationMode = truncationMode
    }

    /// Creates a Cosmos text atom that displays a raw, non-localized string.
    ///
    /// Use this initializer for user-generated content, numbers, or formatted
    /// strings that should not pass through the localization bundle.
    public init(
        verbatim: String,
        lineLimit: Int? = nil,
        alignment: TextAlignment? = nil,
        truncationMode: Text.TruncationMode? = nil
    ) {
        self.contentKey = verbatim
        self.verbatim = verbatim
        self.lineLimit = lineLimit
        self.alignment = alignment
        self.truncationMode = truncationMode
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var resolvedText: String {
        verbatim ?? configuration.localization.string(for: contentKey)
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? resolvedText
    }

    public var body: some View {
        if effectiveVisible {
            let text = Text(resolvedText)
                .font(theme.typography.font(for: theme.textStyle))
                .foregroundStyle(theme.colors.primary)

            textWithBehavior(text)
                .accessibilityLabel(Text(resolvedAccessibilityLabel))
                .accessibilityHintOrNil(configuration.accessibility.hint)
                .accessibilityHidden(configuration.accessibility.isHidden)
                .accessibilitySortPriority(configuration.accessibility.sortPriority)
                .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    @ViewBuilder
    private func textWithBehavior(_ text: Text) -> some View {
        if let lineLimit {
            text
                .lineLimit(lineLimit)
        } else if let alignment, let truncationMode {
            text
                .multilineTextAlignment(alignment)
                .truncationMode(truncationMode)
        } else if let alignment {
            text
                .multilineTextAlignment(alignment)
        } else if let truncationMode {
            text
                .truncationMode(truncationMode)
        } else {
            text
        }
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
