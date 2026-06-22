import SwiftUI
import CosmosBase

/// A system icon atom.
///
/// `CosmosIcon` reads its visibility, accessibility, scale, rendering mode,
/// and color from the SwiftUI environment. It accepts only the system image
/// name through its initializer. Override theme selectors and accessibility
/// through the `.cosmos*` modifiers.
public struct CosmosIcon: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let systemName: String
    let renderingMode: Image.TemplateRenderingMode?
    let resizable: Bool
    let aspectRatio: CGFloat?
    let contentMode: ContentMode?

    /// Creates a Cosmos icon atom.
    public init(
        _ systemName: String,
        renderingMode: Image.TemplateRenderingMode? = nil,
        resizable: Bool = false,
        aspectRatio: CGFloat? = nil,
        contentMode: ContentMode? = nil
    ) {
        self.systemName = systemName
        self.renderingMode = renderingMode
        self.resizable = resizable
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? systemName
    }

    private var iconColor: Color {
        configuration.accessibility.label == nil
            ? theme.colors.primary
            : theme.colors.accent
    }

    public var body: some View {
        if effectiveVisible {
            let image = Image(systemName: systemName)

            configured(image)
                .imageScale(theme.iconScale.imageScale)
                .foregroundStyle(iconColor)
                .accessibilityLabel(Text(resolvedAccessibilityLabel))
                .accessibilityHintOrNil(configuration.accessibility.hint)
                .accessibilityHidden(configuration.accessibility.isHidden)
                .accessibilitySortPriority(configuration.accessibility.sortPriority)
                .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    @ViewBuilder
    private func configured(_ image: Image) -> some View {
        let base = renderingMode != nil ? image.renderingMode(renderingMode) : image

        if resizable, let aspectRatio, let contentMode {
            base
                .resizable()
                .aspectRatio(aspectRatio, contentMode: contentMode)
        } else if resizable {
            base
                .resizable()
        } else {
            base
        }
    }
}

extension CosmosIconScale {
    var imageScale: Image.Scale {
        switch self {
        case .small: .small
        case .medium: .medium
        case .large: .large
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
