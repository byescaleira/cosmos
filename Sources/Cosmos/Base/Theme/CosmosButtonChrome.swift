import SwiftUI

/// Token-driven button chrome for the non-glass ``CosmosButtonStyle`` variants.
///
/// `glass` is intentionally **not** handled here: the Liquid Glass button styles
/// (`.glass` / `.glassProminent`, iOS 26) are not customizable through `ButtonStyle`, so
/// ``CosmosButton`` applies them directly. This style renders `primary`, `secondary`,
/// `danger`, and `ghost` with token-driven background, foreground, corner radius, and a
/// `accessibilityReduceMotion`-aware pressed state.
///
/// Dot-syntax conveniences (SE-0299) enable `.buttonStyle(.cosmosPrimary)`.
public struct CosmosButtonChrome: ButtonStyle {

    public let variant: CosmosButtonStyle
    public let tint: Color?

    public init(variant: CosmosButtonStyle, tint: Color? = nil) {
        precondition(
            variant != .glass,
            "CosmosButtonChrome does not handle .glass; apply .buttonStyle(.glassProminent) on iOS 26 instead."
        )
        self.variant = variant
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        ChromeBody(variant: variant, tint: tint, configuration: configuration)
    }

    // MARK: - Dot-syntax conveniences (SE-0299: `where Self == …`)

    /// `.buttonStyle(.cosmosPrimary)` — filled, accent-tinted.
    public static var cosmosPrimary: CosmosButtonChrome { .init(variant: .primary) }
    /// `.buttonStyle(.cosmosSecondary)` — surface-filled.
    public static var cosmosSecondary: CosmosButtonChrome { .init(variant: .secondary) }
    /// `.buttonStyle(.cosmosDanger)` — filled, error-tinted.
    public static var cosmosDanger: CosmosButtonChrome { .init(variant: .danger) }
    /// `.buttonStyle(.cosmosGhost)` — borderless, no chrome.
    public static var cosmosGhost: CosmosButtonChrome { .init(variant: .ghost) }
}

// MARK: - Rendering body (reads theme + accessibility from the environment)

private struct ChromeBody: View {
    let variant: CosmosButtonStyle
    let tint: Color?
    let configuration: ButtonStyle.Configuration
    @Environment(\.cosmosTheme) private var theme
    /// Distinctly named — the existing `let configuration: ButtonStyle.Configuration` (above)
    /// is the ButtonStyle config and has no `.motion`; this is the Cosmos behavior aggregate.
    @Environment(\.cosmosConfiguration) private var cosmosConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var resolvedTint: Color { tint ?? theme.colors.accent }

    var body: some View {
        configuration.label
            .padding(.horizontal, CosmosSpacingTokens.large)
            .padding(.vertical, CosmosSpacingTokens.medium)
            .foregroundStyle(chromeForeground)
            // Capsule is Apple's Liquid Glass default for filled/prominent buttons
            // (WWDC25-323: "Bordered buttons now have a capsule shape by default"). The native
            // `.glassProminent` already renders capsule; this fallback chrome matches it so the
            // design rhythm is consistent on platforms without the glass style and for the
            // non-glass variants. Use a discrete `RoundedRectangle` radius only for grouped /
            // card-nested content (concentricity), not for standalone prominent buttons.
            // Press scale is UNCONDITIONAL — press feedback is a state signal, not decorative
            // motion (reduce-motion ≠ no feedback). Only the `.animation` is gated, so the scale
            // snaps instantly instead of animating under reduce-motion (vestibular-safe).
            .glassEffect(.regular.tint(chromeBackground), in: .capsule)
            .animation(
                CosmosMotionPolicy.shouldEmit(
                    isEnabled: cosmosConfiguration.motion.isEnabled,
                    respectReduceMotion: cosmosConfiguration.motion.respectReduceMotion,
                    reduceMotion: reduceMotion
                )
                    ? theme.motion.animation(for: .press, reduceMotion: reduceMotion, policy: cosmosConfiguration.motion.reduceMotionPolicy)
                    : nil,
                value: configuration.isPressed
            )
    }

    private var chromeBackground: Color {
        switch variant {
        case .primary:
            return resolvedTint
        case .secondary:
            return theme.colors.surface
        case .danger:
            return theme.colors.error
        case .ghost, .glass:
            // `.glass` is unreachable (precondition in init); `.ghost` is chromeless.
            return Color.clear
        }
    }

    private var chromeForeground: Color {
        switch variant {
        case .primary, .danger:
            return .white
        case .secondary, .ghost, .glass:
            return theme.colors.primary
        }
    }
}
