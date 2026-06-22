import SwiftUI
import CosmosBase

/// A configurable image atom.
///
/// `CosmosImage` reads its visibility, accessibility, and loading state from
/// the SwiftUI environment. It accepts only a source description through its
/// initializer: an app resource name, an SF Symbol name, or a remote URL
/// (`URL` or `String`). Override caching, placeholders, and redaction through
/// the `.cosmos*` modifiers and the environment.
public struct CosmosImage: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let source: Source
    let renderingMode: Image.TemplateRenderingMode?
    let resizable: Bool
    let aspectRatio: CGFloat?
    let contentMode: ContentMode?
    let contentShape: ContentShape?

    /// Creates a Cosmos image atom from a local asset name.
    public init(
        resourceName: String,
        bundle: Bundle? = nil,
        renderingMode: Image.TemplateRenderingMode? = nil,
        resizable: Bool = false,
        aspectRatio: CGFloat? = nil,
        contentMode: ContentMode? = nil,
        contentShape: ContentShape? = nil
    ) {
        self.source = .resource(name: resourceName, bundle: bundle)
        self.renderingMode = renderingMode
        self.resizable = resizable
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        self.contentShape = contentShape
    }

    /// Creates a Cosmos image atom from an SF Symbol name.
    public init(
        systemName: String,
        renderingMode: Image.TemplateRenderingMode? = nil,
        resizable: Bool = false,
        aspectRatio: CGFloat? = nil,
        contentMode: ContentMode? = nil,
        contentShape: ContentShape? = nil
    ) {
        self.source = .system(name: systemName)
        self.renderingMode = renderingMode
        self.resizable = resizable
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        self.contentShape = contentShape
    }

    /// Creates a Cosmos image atom from a remote URL.
    public init(
        url: URL,
        renderingMode: Image.TemplateRenderingMode? = nil,
        resizable: Bool = true,
        aspectRatio: CGFloat? = nil,
        contentMode: ContentMode? = nil,
        contentShape: ContentShape? = nil
    ) {
        self.source = .url(url)
        self.renderingMode = renderingMode
        self.resizable = resizable
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        self.contentShape = contentShape
    }

    /// Creates a Cosmos image atom from a remote URL string.
    public init(
        urlString: String,
        renderingMode: Image.TemplateRenderingMode? = nil,
        resizable: Bool = true,
        aspectRatio: CGFloat? = nil,
        contentMode: ContentMode? = nil,
        contentShape: ContentShape? = nil
    ) {
        self.source = .urlString(urlString)
        self.renderingMode = renderingMode
        self.resizable = resizable
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        self.contentShape = contentShape
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? source.accessibilityLabel
    }

    public var body: some View {
        if effectiveVisible {
            content
                .accessibilityLabel(Text(resolvedAccessibilityLabel))
                .accessibilityHintOrNil(configuration.accessibility.hint)
                .accessibilityHidden(configuration.accessibility.isHidden)
                .accessibilitySortPriority(configuration.accessibility.sortPriority)
                .redactedIfNeeded(configuration.redaction.isRedacted || configuration.loading.isLoading)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch source {
        case .resource(let name, let bundle):
            configured(Image(name, bundle: bundle))
        case .system(let name):
            configured(Image(systemName: name))
        case .url(let url):
            remoteImage(url: url)
        case .urlString(let string):
            if let url = URL(string: string) {
                remoteImage(url: url)
            } else {
                placeholder
            }
        }
    }

    @ViewBuilder
    private func remoteImage(url: URL) -> some View {
        AsyncImage(
            url: url,
            content: { phase in
                switch phase {
                case .success(let image):
                    configured(image)
                case .failure:
                    placeholder
                case .empty:
                    loadingPlaceholder
                @unknown default:
                    loadingPlaceholder
                }
            }
        )
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

    @ViewBuilder
    private var placeholder: some View {
        if let contentShape {
            contentShape
                .shapeView(theme: theme)
        } else {
            theme.colors.secondary
                .opacity(0.3)
        }
    }

    @ViewBuilder
    private var loadingPlaceholder: some View {
        if let contentShape {
            contentShape
                .shapeView(theme: theme)
        } else {
            theme.colors.secondary
                .opacity(0.15)
        }
    }
}

// MARK: - Source

extension CosmosImage {
    /// A description of where an image originates.
    public enum Source: Sendable, Equatable {
        case resource(name: String, bundle: Bundle?)
        case system(name: String)
        case url(URL)
        case urlString(String)

        var accessibilityLabel: String {
            switch self {
            case .resource(let name, _): name
            case .system(let name): name
            case .url(let url): url.absoluteString
            case .urlString(let string): string
            }
        }
    }

    /// A shape that can stand in for an image while loading or on failure.
    public enum ContentShape: Sendable, Equatable {
        case circle
        case roundedRectangle(radius: CosmosRadius)
        case rectangle

        @ViewBuilder
        func shapeView(theme: CosmosTheme) -> some View {
            switch self {
            case .circle:
                Circle()
                    .fill(theme.colors.secondary.opacity(0.3))
            case .roundedRectangle(let radius):
                RoundedRectangle(cornerRadius: radiusValue(radius, theme: theme))
                    .fill(theme.colors.secondary.opacity(0.3))
            case .rectangle:
                Rectangle()
                    .fill(theme.colors.secondary.opacity(0.3))
            }
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

private func radiusValue(_ radius: CosmosRadius, theme: CosmosTheme) -> CGFloat {
    switch radius {
    case .none: theme.radii.none
    case .small: theme.radii.small
    case .medium: theme.radii.medium
    case .large: theme.radii.large
    case .full: theme.radii.full
    }
}
