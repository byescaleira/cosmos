import SwiftUI
import CosmosBase

/// A centered empty-state molecule.
///
/// `CosmosEmptyState` composes an optional image, a title, an optional subtitle,
/// and an optional button into the standard empty/error/onboarding placeholder
/// pattern. It reads visibility, accessibility, and spacing from the environment.
public struct CosmosEmptyState: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let imageSource: CosmosImage.Source?
    let titleKey: String
    let subtitleKey: String?
    let buttonTitleKey: String?
    let buttonAction: (() throws -> Void)?

    /// Creates an empty-state molecule.
    public init(
        image imageSource: CosmosImage.Source? = nil,
        title titleKey: String,
        subtitle subtitleKey: String? = nil,
        buttonTitle buttonTitleKey: String? = nil,
        buttonAction: (() throws -> Void)? = nil
    ) {
        self.imageSource = imageSource
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
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

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? resolvedTitle
    }

    public var body: some View {
        if effectiveVisible {
            VStack(spacing: theme.spacing.medium) {
                Spacer()

                if let imageSource {
                    renderImage(imageSource)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: theme.spacing.xxl * 4, height: theme.spacing.xxl * 4)
                }

                Text(resolvedTitle)
                    .font(theme.typography.font(for: .headline))
                    .foregroundStyle(theme.colors.primary)
                    .multilineTextAlignment(.center)

                if let resolvedSubtitle {
                    Text(resolvedSubtitle)
                        .font(theme.typography.font(for: .subheadline))
                        .foregroundStyle(theme.colors.secondary)
                        .multilineTextAlignment(.center)
                }

                if let resolvedButtonTitle, let buttonAction {
                    CosmosButton(resolvedButtonTitle, action: buttonAction)
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
