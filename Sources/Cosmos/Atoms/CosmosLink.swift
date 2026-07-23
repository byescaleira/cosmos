import SwiftUI

/// A link atom wrapping `Link` with token-driven foreground style + typography, accessibility,
/// tracking, and a centralized URL-open intercept.
///
/// `Link` has **no style protocol** (there is no `LinkStyle`; `LinkButtonStyle` is a
/// `PrimitiveButtonStyle` for `Button`, macOS-only — NOT a `Link` style and must never be wired as
/// one), so this atom wraps a `View` per the Cosmos wrap-view discipline. `Link` is URL-driven
/// only — there is no action closure and no press-state exposure; press/highlight is
/// system-controlled.
///
/// **Color override.** Like ``CosmosIcon``, the atom applies ``CosmosColorTokens/accent`` as the
/// default foreground style; a color applied inside the label content is closer to the rendered
/// text and wins, so the theme accent is only the fallback.
///
/// **URL handling.** ``Link`` resolves opens through the environment's `openURL` action. Cosmos
/// centralizes that intercept in ``View/cosmosOpenURL(inApp:)`` (tracking + in-app routing) rather
/// than having each link own it. Apply it once above a hierarchy of links.
///
/// **Accessibility:** set `.cosmosAccessibilityLabel` when the label is iconic, and
/// `.cosmosAccessibilityHint` to announce the destination. Keyboard/focus navigable on tvOS/macOS.
/// **Haptics:** none — there is no observable state change to trigger on. **Motion:** `none`;
/// label content may carry its own `symbolEffect` (auto-respects Reduce Motion — gate `isEnabled`
/// only). `Link` is `@MainActor @preconcurrency ~Sendable`; this atom keeps MainActor isolation
/// clean under Swift 6.
public struct CosmosLink<Label: View>: View {
    private let destination: URL
    @ViewBuilder private let label: () -> Label

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    /// Creates a link with a custom label view.
    public init(destination: URL, @ViewBuilder label: @escaping () -> Label) {
        self.destination = destination
        self.label = label
    }

    public var body: some View {
        if configuration.enable.isVisible {
            Link(destination: destination) { label() }
                .foregroundStyle(theme.colors.accent)
                .font(theme.typography.font(for: theme.textStyle))
                .applyCosmosAccessibility(configuration.accessibility, extraTraits: .isLink)
                .onAppear { trackAppear() }
        } else {
            EmptyView()
        }
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "link_appear",
            component: "CosmosLink",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}

// MARK: - Convenience inits

extension CosmosLink where Label == CosmosLocalizedText {
    /// Creates a link from a localized String Catalog key (resolved via the configuration).
    public init(_ titleKey: String, destination: URL) {
        self.destination = destination
        self.label = { CosmosLocalizedText(key: titleKey) }
    }
}

extension CosmosLink where Label == Text {
    /// Creates a link from verbatim (non-localized) text.
    public init<S: StringProtocol>(verbatim title: S, destination: URL) {
        self.destination = destination
        self.label = { Text(verbatim: String(title)) }
    }
}

// MARK: - Previews

#Preview("Link – text") {
    VStack(alignment: .leading, spacing: 12) {
        CosmosLink("welcome.headline", destination: URL(string: "https://example.com")!)
        CosmosLink(verbatim: "https://example.com", destination: URL(string: "https://example.com")!)
            .cosmosFont(.body)
    }
    .padding()
}

#Preview("Link – iconic label") {
    CosmosLink(destination: URL(string: "https://example.com")!) {
        Label { CosmosText("welcome.continue") } icon: { Image(systemName: "arrow.up.right.square.fill") }
    }
    .cosmosAccessibilityLabel("Open external site")
    .padding()
}

#Preview("Link – dark + accessibility size", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(alignment: .leading, spacing: 12) {
            CosmosLink("welcome.headline", destination: CosmosMock.url()).cosmosFont(.headline)
            CosmosLink(verbatim: CosmosMock.url().absoluteString, destination: CosmosMock.url())
                .cosmosFont(.body)
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}