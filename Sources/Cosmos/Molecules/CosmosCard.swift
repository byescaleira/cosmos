import SwiftUI
import CosmosBase

/// A content card molecule.
///
/// `CosmosCard` composes an optional top image, a title, an optional subtitle,
/// and an optional badge or button into the standard iOS content card pattern.
/// It reads visibility, accessibility, and spacing from the environment.
public struct CosmosCard: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let imageSource: CosmosImage.Source?
    let titleKey: String
    let subtitleKey: String?
    let badge: CosmosBadge?
    let buttonTitleKey: String?
    let buttonAction: (() throws -> Void)?

    /// Creates a content card molecule.
    public init(
        image imageSource: CosmosImage.Source? = nil,
        title titleKey: String,
        subtitle subtitleKey: String? = nil,
        badge: CosmosBadge? = nil,
        buttonTitle buttonTitleKey: String? = nil,
        buttonAction: (() throws -> Void)? = nil
    ) {
        self.imageSource = imageSource
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.badge = badge
        self.buttonTitleKey = buttonTitleKey
        self.buttonAction = buttonAction
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

    private var resolvedButtonTitle: String? {
        buttonTitleKey.map { configuration.localization.string(for: $0) }
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? resolvedTitle
    }

    public var body: some View {
        if effectiveVisible {
            VStack(alignment: .leading, spacing: theme.spacing.small) {
                if let imageSource {
                    renderImage(imageSource)
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: theme.spacing.xxl * 6)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: theme.radii.small))
                }

                HStack(spacing: theme.spacing.small) {
                    Text(resolvedTitle)
                        .font(theme.typography.font(for: .headline))
                        .foregroundStyle(theme.colors.primary)

                    Spacer()

                    if let badge {
                        badge
                    }
                }

                if let resolvedSubtitle {
                    Text(resolvedSubtitle)
                        .font(theme.typography.font(for: .subheadline))
                        .foregroundStyle(theme.colors.secondary)
                }

                if let resolvedButtonTitle, let buttonAction {
                    HStack {
                        Spacer()
                        CosmosButton(resolvedButtonTitle, action: buttonAction)
                    }
                }
            }
            .padding(theme.spacing.medium)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radii.medium))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(resolvedAccessibilityLabel))
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
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
