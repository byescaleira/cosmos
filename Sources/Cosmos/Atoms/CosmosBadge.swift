import SwiftUI
import CosmosBase

/// A badge atom.
///
/// `CosmosBadge` reads its visibility, accessibility, color, and spacing from
/// the SwiftUI environment. It accepts text or a dot mode through its
/// initializer. Override appearance through the `.cosmos*` modifiers and theme.
public struct CosmosBadge: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let text: String?
    let variant: Variant

    /// Creates a Cosmos badge atom that displays text inside a pill.
    public init(_ text: String, variant: Variant = .primary) {
        self.text = text
        self.variant = variant
    }

    /// Creates a Cosmos badge atom that renders a small dot.
    public init(dot variant: Variant = .primary) {
        self.text = nil
        self.variant = variant
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? text ?? "Badge"
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary: theme.colors.accent
        case .secondary: theme.colors.secondary
        case .success: theme.colors.success
        case .warning: theme.colors.warning
        case .error: theme.colors.error
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary, .success, .error, .warning: theme.colors.background
        case .secondary: theme.colors.primary
        }
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
        if let text {
            Text(text)
                .font(theme.typography.font(for: .caption2))
                .foregroundStyle(foregroundColor)
                .padding(.horizontal, theme.spacing.small)
                .padding(.vertical, theme.spacing.xs)
                .background(backgroundColor)
                .clipShape(Capsule())
        } else {
            Circle()
                .fill(backgroundColor)
                .frame(width: theme.spacing.small, height: theme.spacing.small)
        }
    }
}

extension CosmosBadge {
    /// Visual emphasis of a badge.
    public enum Variant: String, Sendable, Codable, CaseIterable {
        case primary
        case secondary
        case success
        case warning
        case error
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
