import SwiftUI

/// A label atom wrapping `Label` with token-driven foreground style + typography, localization,
/// accessibility, tracking, and motion-aware symbol effects.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. The visual variant
/// comes from ``CosmosTheme/labelStyle`` (default `.automatic`); `.cosmos` routes through the
/// custom conforming ``CosmosLabelChrome`` style.
///
/// **Accessibility:** the title is the VoiceOver label — this atom deliberately does NOT re-state
/// it as `accessibilityLabel` (no double-labeling). Callers may still override via the
/// accessibility configuration. `LabelStyle` is `@preconcurrency @MainActor`; the conforming
/// ``CosmosLabelChrome`` keeps its body in a `View` (MainActor) and holds no non-Sendable state.
public struct CosmosLabel<Title: View, Icon: View>: View {
    @ViewBuilder private let title: () -> Title
    @ViewBuilder private let icon: () -> Icon

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    /// Creates a label with custom title and icon views.
    public init(@ViewBuilder title: @escaping () -> Title, @ViewBuilder icon: @escaping () -> Icon) {
        self.title = title
        self.icon = icon
    }

    public var body: some View {
        if configuration.enable.isVisible {
            Label { title() } icon: { icon() }
                .modifier(CosmosLabelStyleApplier(style: theme.labelStyle))
                .foregroundStyle(theme.colors.primary)
                .font(theme.typography.font(for: theme.textStyle))
                .applyCosmosAccessibility(configuration.accessibility)
                .onAppear { trackAppear() }
        } else {
            EmptyView()
        }
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "label_appear",
            component: "CosmosLabel",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}

// MARK: - Convenience inits (Title == Text / localized text; Icon == Image)

extension CosmosLabel where Title == CosmosLocalizedText, Icon == Image {
    /// Creates a label from a localized String Catalog key (resolved via the configuration) and
    /// an SF Symbol name.
    public init(_ titleKey: String, systemImage: String) {
        self.title = { CosmosLocalizedText(key: titleKey) }
        self.icon = { Image(systemName: systemImage) }
    }

    /// Creates a label from a localized String Catalog key and a bundled asset image name.
    public init(_ titleKey: String, image: String) {
        self.title = { CosmosLocalizedText(key: titleKey) }
        self.icon = { Image(image) }
    }
}

extension CosmosLabel where Title == Text, Icon == Image {
    /// Creates a label from verbatim (non-localized) text and an SF Symbol name.
    public init<S: StringProtocol>(verbatim title: S, systemImage: String) {
        self.title = { Text(verbatim: String(title)) }
        self.icon = { Image(systemName: systemImage) }
    }

    /// Creates a label from verbatim text and a bundled asset image name.
    public init<S: StringProtocol>(verbatim title: S, image: String) {
        self.title = { Text(verbatim: String(title)) }
        self.icon = { Image(image) }
    }
}

// MARK: - Style resolution

/// Resolves a ``CosmosLabelStyle`` to a concrete `LabelStyle`: built-ins delegate to the native
/// statics; `.cosmos` routes through the custom ``CosmosLabelChrome``.
private struct CosmosLabelStyleApplier: ViewModifier {
    let style: CosmosLabelStyle
    func body(content: Content) -> some View {
        switch style {
        case .automatic:   content.labelStyle(.automatic)
        case .titleAndIcon: content.labelStyle(.titleAndIcon)
        case .iconOnly:    content.labelStyle(.iconOnly)
        case .titleOnly:   content.labelStyle(.titleOnly)
        case .cosmos:      content.labelStyle(CosmosLabelChrome())
        }
    }
}

/// Custom `LabelStyle` composing `configuration.title` + `configuration.icon` with token-driven
/// foreground style and typography. The pieces are opaque (`Body == Never`) so they are composed
/// only — never introspected.
public struct CosmosLabelChrome: LabelStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        CosmosLabelChromeBody(configuration: configuration)
    }
}

private struct CosmosLabelChromeBody: View {
    let configuration: LabelStyle.Configuration
    @Environment(\.cosmosTheme) private var theme

    var body: some View {
        // The icon is a symbol-aware view; callers may attach `.symbolEffect` to the `Image` they
        // pass in (symbol effects auto-respect Reduce Motion — gate on `motion.isEnabled` only).
        HStack(spacing: CosmosSpacingTokens.small) {
            configuration.icon
            configuration.title
        }
        .foregroundStyle(theme.colors.primary)
        .font(theme.typography.font(for: theme.textStyle))
    }
}

/// Resolves a localized String Catalog key through ``CosmosLocalizationConfiguration`` (honoring
/// the configured `locale`), so ``CosmosLabel``'s key-based inits flow through the same pipeline
/// as ``CosmosText``.
public struct CosmosLocalizedText: View {
    private let key: String
    @Environment(\.cosmosConfiguration) private var configuration

    public init(key: String) { self.key = key }

    @ViewBuilder
    public var body: some View {
        // `string(for:)` is optional-aware (returns `nil` for a `nil` key or an unresolved key);
        // render nothing when unresolved, mirroring ``CosmosText``'s nil-handling.
        if let resolved = configuration.localization.string(for: key) {
            Text(resolved)
        }
    }
}

// MARK: - Previews

#Preview("Label styles") {
    VStack(alignment: .leading, spacing: 12) {
        CosmosLabel("preview.title", systemImage: "star.fill")
        CosmosLabel("preview.title", systemImage: "star.fill").cosmosLabelStyle(.iconOnly)
        CosmosLabel("preview.title", systemImage: "star.fill").cosmosLabelStyle(.titleOnly)
        CosmosLabel("preview.title", systemImage: "star.fill").cosmosLabelStyle(.titleAndIcon)
        CosmosLabel("preview.title", systemImage: "star.fill").cosmosLabelStyle(.cosmos)
    }
    .padding()
}

#Preview("Label – text styles + dark") {
    VStack(alignment: .leading, spacing: 12) {
        CosmosLabel("preview.title", systemImage: "sparkles").cosmosTextStyle(.headline)
        CosmosLabel("preview.description", systemImage: "text.alignleft").cosmosTextStyle(.body)
        CosmosLabel("preview.name", systemImage: "person.fill").cosmosTextStyle(.caption)
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Label – accessibility size + languages", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(alignment: .leading, spacing: 12) {
            CosmosLabel("preview.title", systemImage: "star.fill").cosmosTextStyle(.title)
            CosmosLabel(verbatim: CosmosMock.personName(), systemImage: "person.crop.circle")
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3, locale: Locale(identifier: "pt-BR"))
    }
}