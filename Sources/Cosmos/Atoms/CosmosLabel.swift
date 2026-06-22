import SwiftUI
import CosmosBase

/// A label atom that pairs an icon with text.
///
/// `CosmosLabel` reads its visibility, accessibility, typography, and color
/// from the SwiftUI environment. It accepts a title localization key and an
/// SF Symbol name through its initializer. Override layout, spacing, and theme
/// through the surrounding view hierarchy using the `.cosmos*` modifiers.
public struct CosmosLabel: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let titleKey: String
    let systemImage: String?
    let spacing: CosmosPadding?
    let iconPosition: IconPosition?

    /// Creates a Cosmos label atom with an optional SF Symbol.
    public init(
        _ titleKey: String,
        systemImage: String? = nil,
        spacing: CosmosPadding? = nil,
        iconPosition: IconPosition? = nil
    ) {
        self.titleKey = titleKey
        self.systemImage = systemImage
        self.spacing = spacing
        self.iconPosition = iconPosition
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var resolvedTitle: String {
        configuration.localization.string(for: titleKey)
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? resolvedTitle
    }

    private var effectiveSpacing: CGFloat {
        theme.spacing.value(for: spacing ?? .small)
    }

    public var body: some View {
        if effectiveVisible {
            content
                .accessibilityLabel(Text(resolvedAccessibilityLabel))
                .accessibilityHintOrNil(configuration.accessibility.hint)
                .accessibilityHidden(configuration.accessibility.isHidden)
                .accessibilitySortPriority(configuration.accessibility.sortPriority)
                .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    @ViewBuilder
    private var content: some View {
        if let systemImage {
            switch iconPosition ?? .leading {
            case .leading:
                HStack(spacing: effectiveSpacing) {
                    CosmosIcon(systemImage)
                    title
                }
            case .trailing:
                HStack(spacing: effectiveSpacing) {
                    title
                    CosmosIcon(systemImage)
                }
            }
        } else {
            title
        }
    }

    private var title: some View {
        Text(resolvedTitle)
            .font(theme.typography.font(for: theme.textStyle))
            .foregroundStyle(theme.colors.primary)
    }
}

extension CosmosLabel {
    /// Horizontal placement of the icon relative to the title.
    public enum IconPosition: String, Sendable, Codable, CaseIterable {
        case leading
        case trailing
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
