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

    /// Shadow is suppressed when reduce-transparency is active *and* respected by config, or
    /// when reduce-motion is active. Config-aware (not the bare env value); tokens replace the
    /// hardcoded `0.08`/`8` from the pre-motion implementation.
    private var shadowHidden: Bool {
        (reduceTransparency && configuration.motion.respectReduceTransparency) || reduceMotion
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
            .stroke(theme.colors.outline, lineWidth: 1)
    }
}

// MARK: - Previews

#Preview("Card simple") {
    CosmosCard {
        CosmosText("preview.title").cosmosTextStyle(.headline)
        CosmosText("preview.description").cosmosTextStyle(.body)
    }
    .padding()
}

#Preview("Card header + footer") {
    CosmosCard {
        CosmosText("preview.title").cosmosTextStyle(.headline)
    } body: {
        CosmosText("preview.description").cosmosTextStyle(.body)
    } footer: {
        CosmosButton("welcome.continue") {}.cosmosButtonStyle(.secondary)
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Card landscape reflow") {
    CosmosCard {
        CosmosText("preview.title").cosmosTextStyle(.headline)
    } body: {
        CosmosText("preview.description").cosmosTextStyle(.body)
    } footer: {
        CosmosButton("welcome.continue") {}
    }
    .padding()
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("Card – mock content + reduce motion", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosCard {
            CosmosText(verbatim: CosmosMock.personName()).cosmosTextStyle(.headline)
        } body: {
            VStack(alignment: .leading, spacing: 6) {
                CosmosText(verbatim: CosmosMock.addressLine()).cosmosTextStyle(.body)
                CosmosText(verbatim: CosmosMock.phone()).cosmosTextStyle(.body)
            }
        } footer: {
            CosmosButton("welcome.continue") {}
        }
        .cosmosPreviewVariant(.reduceMotion)
        .padding()
    }
}