import SwiftUI

/// A reference atom rendering a card container (header / body / footer) with token-driven
/// chrome, adaptive layout, accessibility combination, and tracking.
///
/// Implemented as a plain `View` (not `GroupBoxStyle`) because `GroupBox` is absent on
/// tvOS/watchOS and `GroupBoxStyle` exposes no footer in its configuration. A plain view
/// works on all 5 platforms.
public struct CosmosCard<Header: View, Body: View, Footer: View>: View {
    @ViewBuilder private let header: () -> Header
    @ViewBuilder private let bodyContent: () -> Body
    @ViewBuilder private let footer: () -> Footer

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    /// Shadow is suppressed when reduce-transparency collapses materials (config- and
    /// policy-aware via ``CosmosMotionPolicy/shouldCollapseTransparency``), or when reduce-motion
    /// is active. Config-aware (not the bare env value); tokens replace the hardcoded
    /// `0.08`/`8` from the pre-motion implementation.
    private var shadowHidden: Bool {
        CosmosMotionPolicy.shouldCollapseTransparency(
            respectReduceTransparency: configuration.motion.respectReduceTransparency,
            reduceTransparency: reduceTransparency,
            policy: configuration.motion.reduceTransparencyPolicy
        ) || reduceMotion
    }

    /// Under Increased Contrast (config-aware), the card border thickens so the card edge stays
    /// legible against the background — the synthetic outline is the part the UIKit-backed tokens
    /// don't already adapt.
    private var increasesContrast: Bool {
        CosmosAccessibilityPolicy.shouldIncreaseContrast(
            respectIncreaseContrast: configuration.accessibility.respectIncreaseContrast,
            contrast: colorSchemeContrast
        )
    }

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
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.card, style: .continuous))
        .overlay(cardBorder)
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

    @ViewBuilder
    private var cardBackground: some View {
        // visionOS favors a glass background; other platforms use the surface token.
        #if os(visionOS)
        RoundedRectangle(cornerRadius: CosmosRadiusTokens.card, style: .continuous)
            .fill(.ultraThinMaterial)
        #else
        RoundedRectangle(cornerRadius: CosmosRadiusTokens.card, style: .continuous)
            .fill(theme.colors.surface)
        #endif
    }

    @ViewBuilder
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: CosmosRadiusTokens.card, style: .continuous)
            .stroke(theme.colors.outline, lineWidth: increasesContrast ? 1.5 : 1)
    }
}

// MARK: - Previews

#Preview("Card simple") {
    CosmosCard {
        CosmosText("preview.title").cosmosFont(.headline)
        CosmosText("preview.description").cosmosFont(.body)
    }
    .padding()
}

#Preview("Card header + footer") {
    CosmosCard {
        CosmosText("preview.title").cosmosFont(.headline)
    } body: {
        CosmosText("preview.description").cosmosFont(.body)
    } footer: {
        CosmosButton("welcome.continue") {}.cosmosButtonStyle(.secondary)
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Card landscape reflow") {
    CosmosCard {
        CosmosText("preview.title").cosmosFont(.headline)
    } body: {
        CosmosText("preview.description").cosmosFont(.body)
    } footer: {
        CosmosButton("welcome.continue") {}
    }
    .padding()
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("Card – mock content + reduce motion", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosCard {
            CosmosText(verbatim: CosmosMock.personName()).cosmosFont(.headline)
        } body: {
            VStack(alignment: .leading, spacing: 6) {
                CosmosText(verbatim: CosmosMock.addressLine()).cosmosFont(.body)
                CosmosText(verbatim: CosmosMock.phone()).cosmosFont(.body)
            }
        } footer: {
            CosmosButton("welcome.continue") {}
        }
        .cosmosPreviewVariant(.reduceMotion)
        .padding()
    }
}