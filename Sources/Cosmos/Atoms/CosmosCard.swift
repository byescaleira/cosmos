import SwiftUI

/// A reference atom rendering a card container (header / body / footer) with token-driven
/// chrome, adaptive layout, accessibility combination, and tracking.
///
/// - Deprecated: ``CosmosCard`` is deprecated and will be removed in a future Cosmos major.
///   There is no single native counterpart that works on all 5 platforms, but the same layout
///   composes directly from `CosmosAdaptiveStack` + the theme's background/border/shadow tokens
///   (the same primitives this atom wraps) — prefer composing those explicitly.
///
/// Implemented as a plain `View` (not `GroupBoxStyle`) because `GroupBox` is absent on
/// tvOS/watchOS and `GroupBoxStyle` exposes no footer in its configuration. A plain view
/// works on all 5 platforms.
@available(*, deprecated, message: "CosmosCard is deprecated and will be removed in a future Cosmos major. Compose with CosmosAdaptiveStack + background tokens directly.")
public struct CosmosCard<Header: View, Body: View, Footer: View>: View {
    @ViewBuilder private let header: () -> Header
    @ViewBuilder private let bodyContent: () -> Body
    @ViewBuilder private let footer: () -> Footer

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    /// Shadow is suppressed when reduce-transparency collapses materials (config- and
    /// policy-aware via ``CosmosMotionPolicy/shouldCollapseTransparency``), or when motion is not
    /// emitting (config-aware via ``CosmosMotionPolicy/shouldEmit(isEnabled:respectReduceMotion:
    /// reduceMotion:)`` — NOT the bare `reduceMotion` env value, so `respectReduceMotion = false`
    /// can keep the shadow and `motion.isEnabled = false` still suppresses it). Mirrors
    /// `CosmosToastHost.shadowHidden`; tokens replace the hardcoded `0.08`/`8` from the
    /// pre-motion implementation.
    private var shadowHidden: Bool {
        CosmosMotionPolicy.shouldCollapseTransparency(
            respectReduceTransparency: configuration.motion.respectReduceTransparency,
            reduceTransparency: reduceTransparency,
            policy: configuration.motion.reduceTransparencyPolicy
        ) || !CosmosMotionPolicy.shouldEmit(
            isEnabled: configuration.motion.isEnabled,
            respectReduceMotion: configuration.motion.respectReduceMotion,
            reduceMotion: reduceMotion
        )
    }

    @available(*, deprecated, message: "CosmosCard is deprecated and will be removed in a future Cosmos major. Compose with CosmosAdaptiveStack + background tokens directly.")
    public init(
        @ViewBuilder header: @escaping () -> Header = { EmptyView() },
        @ViewBuilder body: @escaping () -> Body,
        @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }
    ) {
        self.header = header
        self.bodyContent = body
        self.footer = footer
    }

    public var body: some View {
        CosmosAdaptiveStack(horizontalAlignment: .top, verticalAlignment: .leading) {
            header()
            bodyContent()
            footer()
        }
        .padding(CosmosSpacingTokens.value(for: theme.padding))
        .background(CosmosCardBackground())
        .clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.card, style: .continuous))
        .overlay { CosmosCardBorder() }
        .shadow(
            color: theme.colors.primary.opacity(shadowHidden ? 0 : theme.motion.shadowOpacity),
            radius: shadowHidden ? 0 : theme.motion.shadowRadius,
            y: 4
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabelOrNil(configuration.accessibility.label)
        .accessibilityHintOrNil(configuration.accessibility.hint)
        .accessibilityIdentifierOrNil(configuration.accessibility.identifier)
        .accessibilitySortPriorityOrNil(configuration.accessibility.sortPriority)
        .accessibilityHiddenIf(configuration.accessibility.isHidden)
        .accessibilityCustomContentIfPresent(configuration.accessibility.customContent)
        .modifier(CosmosRespondsModifier(responds: configuration.accessibility.respondsToUserInteraction))
        .onAppear {
            configuration.tracking.track(.init(
                name: "card_appear",
                component: "CosmosCard",
                componentId: trackingId ?? configuration.accessibility.identifier,
                action: .appear
            ))
        }
    }
}

// MARK: - Extracted chrome (views.md: computed `some View` → dedicated View structs)

/// The card background — visionOS favors a glass material; other platforms use the surface token.
/// Extracted from ``CosmosCard``'s `body` (views.md). Reads ``CosmosTheme`` directly.
private struct CosmosCardBackground: View {
    @Environment(\.cosmosTheme) private var theme

    var body: some View {
        #if os(visionOS)
        RoundedRectangle(cornerRadius: CosmosRadiusTokens.card, style: .continuous)
            .fill(.ultraThinMaterial)
        #else
        RoundedRectangle(cornerRadius: CosmosRadiusTokens.card, style: .continuous)
            .fill(theme.colors.surface)
        #endif
    }
}

/// The card border — thickens under Increased Contrast (config-aware) so the card edge stays
/// legible. Extracted from ``CosmosCard``'s `body` (views.md). Reads ``CosmosTheme`` +
/// ``CosmosConfiguration`` + `colorSchemeContrast` directly and computes the contrast gate itself.
private struct CosmosCardBorder: View {
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var increasesContrast: Bool {
        CosmosAccessibilityPolicy.shouldIncreaseContrast(
            respectIncreaseContrast: configuration.accessibility.respectIncreaseContrast,
            contrast: colorSchemeContrast
        )
    }

    var body: some View {
        RoundedRectangle(cornerRadius: CosmosRadiusTokens.card, style: .continuous)
            .stroke(theme.colors.outline, lineWidth: increasesContrast ? 1.5 : 1)
    }
}

// MARK: - Previews
//
// `CosmosCard` is `@available(*, deprecated)` (migrate to `CosmosAdaptiveStack` + the theme's
// background/border/shadow tokens — the primitives this atom wraps). Each preview carries the
// matching `@available(*, deprecated)` passthrough so constructing the deprecated atom doesn't emit
// a warning — keeps the build warning-free for the removal runway (same pattern as
// ``CosmosCardTests``).

@available(*, deprecated, message: "Preview exercises deprecated CosmosCard during the removal runway.")
#Preview("CosmosCard – deprecated", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosCard {
            CosmosText("preview.title").cosmosFont(.headline)
        } body: {
            CosmosText("preview.description").cosmosFont(.body)
        }
    }
}

@available(*, deprecated, message: "Preview exercises deprecated CosmosCard during the removal runway.")
#Preview("CosmosCard – dark + accessibility", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosCard {
            CosmosText("welcome.headline").cosmosFont(.headline)
        } body: {
            CosmosText("preview.description").cosmosFont(.body)
        } footer: {
            CosmosText("preview.name").cosmosFont(.footnote)
        }
        .cosmosPreviewEnv(colorScheme: .dark, dynamicTypeSize: .accessibility3)
    }
}