import SwiftUI
import CosmosBase

/// A status row molecule.
///
/// `CosmosStatusRow` composes a leading icon or image, a title/subtitle stack,
/// and a trailing badge into the standard notification or activity row pattern.
/// It reads visibility, accessibility, and spacing from the environment.
public struct CosmosStatusRow: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let imageSource: CosmosImage.Source?
    let systemImage: String?
    let titleKey: String
    let subtitleKey: String?
    let badge: CosmosBadge?

    /// Creates a status row with a leading image, title, optional subtitle,
    /// and optional badge.
    public init(
        image imageSource: CosmosImage.Source? = nil,
        systemImage: String? = nil,
        title titleKey: String,
        subtitle subtitleKey: String? = nil,
        badge: CosmosBadge? = nil
    ) {
        self.imageSource = imageSource
        self.systemImage = systemImage
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.badge = badge
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var resolvedTitle: String {
        configuration.localization.string(for: titleKey)
    }

    private var resolvedSubtitle: String? {
        subtitleKey.map { configuration.localization.string(for: $0) }
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? resolvedTitle
    }

    public var body: some View {
        if effectiveVisible {
            HStack(spacing: theme.spacing.small) {
                leadingImage

                textStack

                Spacer()

                if let badge {
                    badge
                }
            }
            .padding(.vertical, theme.spacing.small)
            .contentShape(Rectangle())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(resolvedAccessibilityLabel))
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    @ViewBuilder
    private var leadingImage: some View {
        if let imageSource {
            renderImage(imageSource)
                .frame(width: theme.spacing.large, height: theme.spacing.large)
        } else if let systemImage {
            CosmosIcon(systemImage)
                .foregroundStyle(theme.colors.accent)
        }
    }

    @ViewBuilder
    private var textStack: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(resolvedTitle)
                .font(theme.typography.font(for: theme.textStyle))
                .foregroundStyle(theme.colors.primary)

            if let resolvedSubtitle {
                Text(resolvedSubtitle)
                    .font(theme.typography.font(for: .caption2))
                    .foregroundStyle(theme.colors.secondary)
            }
        }
    }

    @ViewBuilder
    private func renderImage(_ source: CosmosImage.Source) -> some View {
        switch source {
        case .resource(let name, let bundle):
            CosmosImage(resourceName: name, bundle: bundle, resizable: true)
        case .system(let name):
            CosmosImage(systemName: name, resizable: true)
        case .url(let url):
            CosmosImage(url: url, resizable: true)
        case .urlString(let string):
            CosmosImage(urlString: string, resizable: true)
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
