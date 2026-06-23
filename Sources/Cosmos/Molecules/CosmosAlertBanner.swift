import SwiftUI
import CosmosBase

/// An inline alert banner molecule.
///
/// `CosmosAlertBanner` composes a leading icon, a message, and an optional
/// action button into the standard inline alert pattern. It reads visibility,
/// accessibility, and theme from the environment.
public struct CosmosAlertBanner: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let systemImage: String
    let titleKey: String
    let actionTitleKey: String?
    let action: (() throws -> Void)?
    let variant: Variant

    /// Creates an alert banner molecule.
    public init(
        systemImage: String,
        title titleKey: String,
        actionTitle actionTitleKey: String? = nil,
        action: (() throws -> Void)? = nil,
        variant: Variant = .info
    ) {
        self.systemImage = systemImage
        self.titleKey = titleKey
        self.actionTitleKey = actionTitleKey
        self.action = action
        self.variant = variant
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var resolvedTitle: String {
        configuration.localization.string(for: titleKey)
    }

    private var resolvedActionTitle: String? {
        actionTitleKey.map { configuration.localization.string(for: $0) }
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? resolvedTitle
    }

    public var body: some View {
        if effectiveVisible {
            HStack(spacing: theme.spacing.small) {
                CosmosIcon(systemImage)
                    .foregroundStyle(foregroundColor)

                Text(resolvedTitle)
                    .font(theme.typography.font(for: theme.textStyle))
                    .foregroundStyle(theme.colors.primary)

                Spacer()

                if let resolvedActionTitle, let action {
                    CosmosButton(resolvedActionTitle, action: action)
                        .tint(foregroundColor)
                }
            }
            .padding(theme.spacing.small)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: theme.radii.small))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(resolvedAccessibilityLabel))
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    private var backgroundColor: Color {
        foregroundColor.opacity(0.15)
    }

    private var foregroundColor: Color {
        switch variant {
        case .info:
            return theme.colors.accent
        case .success:
            return theme.colors.success
        case .warning:
            return theme.colors.warning
        case .error:
            return theme.colors.error
        }
    }
}

extension CosmosAlertBanner {
    /// Semantic emphasis of an alert banner.
    public enum Variant: String, Sendable, Codable, Equatable, CaseIterable {
        case info
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
