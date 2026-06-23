import SwiftUI
import CosmosBase

/// A centered loading-state molecule.
///
/// `CosmosLoadingState` composes an optional title, an optional subtitle, and a
/// progress indicator into the standard loading placeholder pattern. It reads
/// visibility, accessibility, and spacing from the environment.
public struct CosmosLoadingState: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let titleKey: String?
    let subtitleKey: String?
    let progressValue: Double?

    /// Creates a loading-state molecule.
    public init(
        title titleKey: String? = nil,
        subtitle subtitleKey: String? = nil,
        progressValue: Double? = nil
    ) {
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.progressValue = progressValue
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var resolvedTitle: String? {
        titleKey.map { configuration.localization.string(for: $0) }
    }

    private var resolvedSubtitle: String? {
        subtitleKey.map { configuration.localization.string(for: $0) }
    }

    private var resolvedAccessibilityLabel: String {
        if let label = configuration.accessibility.label { return label }
        return [resolvedTitle, resolvedSubtitle]
            .compactMap { $0 }
            .joined(separator: " ")
    }

    public var body: some View {
        if effectiveVisible {
            VStack(spacing: theme.spacing.medium) {
                Spacer()

                CosmosProgress(value: progressValue)
                    .frame(width: theme.spacing.xxl * 2, height: theme.spacing.xxl * 2)

                if let resolvedTitle {
                    Text(resolvedTitle)
                        .font(theme.typography.font(for: .headline))
                        .foregroundStyle(theme.colors.primary)
                        .multilineTextAlignment(.center)
                }

                if let resolvedSubtitle {
                    Text(resolvedSubtitle)
                        .font(theme.typography.font(for: .subheadline))
                        .foregroundStyle(theme.colors.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding(theme.spacing.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(resolvedAccessibilityLabel))
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
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
