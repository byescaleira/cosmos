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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var resolvedTint: Color { tint ?? theme.colors.accent }

    var body: some View {
        configuration.label
            .padding(.horizontal, CosmosSpacingTokens.large)
            .padding(.vertical, CosmosSpacingTokens.medium)
            .frame(minHeight: 44, alignment: .center)
            .background(chromeBackground)
            .foregroundStyle(chromeForeground)
            .clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: configuration.isPressed)
    }

    @ViewBuilder
    private var chromeBackground: some View {
        switch variant {
        case .primary:
            RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous).fill(resolvedTint)
        case .secondary:
            RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous).fill(theme.colors.surface)
        case .danger:
            RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous).fill(theme.colors.error)
        case .ghost, .glass:
            // `.glass` is unreachable (precondition in init); `.ghost` is chromeless.
            Color.clear
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