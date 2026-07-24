import SwiftUI

/// A reference atom wrapping `Button` that demonstrates every cross-cutting concern:
/// accessibility, haptics, localization, tracking — plus multiplatform chrome (including
/// Liquid Glass on iOS/macOS/visionOS 26) and reduce-motion awareness.
///
/// State and theme are **global**: this atom reads ``CosmosConfiguration`` and
/// ``CosmosTheme`` from the environment and overrides per-instance via `.cosmos*` modifiers.
public struct CosmosButton<Label: View>: View {
    private let action: () -> Void
    @ViewBuilder private let label: () -> Label

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var tapCounter = 0

    /// Creates a button with a custom label.
    public init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }

    /// Creates a button with a localized title (resolved from the Cosmos String Catalog).
    public init(_ titleKey: String, action: @escaping () -> Void) where Label == Text {
        self.action = action
        self.label = { Text(LocalizedStringKey(titleKey), bundle: CosmosResources.bundle) }
    }

    private var effectiveEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly && !configuration.loading.isLoading
    }

    private func performAction() {
        tapCounter &+= 1
        configuration.tracking.track(.init(
            name: "button_tap",
            component: "CosmosButton",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .tap
        ))
        configuration.log.log(.info, "CosmosButton tapped")
        action()
    }

    public var body: some View {
        if configuration.enable.isVisible {
            Button(action: performAction) { label() }
                .modifier(CosmosButtonChromeApplier(style: theme.buttonStyle))
                .controlSize(theme.controlSize.controlSize)
                .disabled(!effectiveEnabled)
                .cosmosHaptic(.impact(weight: .light), trigger: tapCounter)
                // Coordinated motion tracking alongside the haptic on the same tapCounter
                // trigger, gated by the motion policy (not duplicated, not ungated).
                .onChange(of: tapCounter) { _, _ in
                    if CosmosMotionPolicy.shouldEmit(
                        isEnabled: configuration.motion.isEnabled,
                        respectReduceMotion: configuration.motion.respectReduceMotion,
                        reduceMotion: reduceMotion
                    ) {
                        configuration.motion.handler(.motion(.press))
                    }
                }
                .applyCosmosAccessibility(configuration.accessibility, extraTraits: .isButton)
                .opacity(configuration.loading.isLoading ? 0.6 : 1.0)
        } else {
            EmptyView()
        }
    }
}

/// Applies the right `ButtonStyle` for the variant, routing `.glass` to the native Liquid
/// Glass style on iOS/macOS 26 and falling back to ``CosmosButtonChrome`` elsewhere.
/// `.glassProminent` is a `ButtonStyle` available on iOS 26 + macOS 26 only; visionOS 26
/// exposes Liquid Glass through the `.glassEffect()` modifier (not a button style), so it
/// routes to the chrome fallback here.
private struct CosmosButtonChromeApplier: ViewModifier {
    let style: CosmosButtonStyle

    func body(content: Content) -> some View {
        if style == .glass {
            #if os(iOS) || os(macOS)
            if #available(iOS 26, macOS 26, *) {
                content.buttonStyle(.glassProminent)
            } else {
                content.buttonStyle(CosmosButtonChrome(variant: .primary))
            }
            #else
            content.buttonStyle(CosmosButtonChrome(variant: .primary))
            #endif
        } else {
            content.buttonStyle(CosmosButtonChrome(variant: style))
        }
    }
}

// MARK: - Button chrome (token-driven ButtonStyle for the non-glass variants)

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
    /// Read-only public env gate (`accessibilityShowBorders`, iOS 14+/macOS 11+/tvOS 14+/
    /// watchOS 7+, `@backDeployed` to 26.1 — née `accessibilityShowButtonShapes`; fully
    /// available at the Cosmos 26 floor on all 5 platforms). Drives the borderless `.ghost`
    /// shape outline when the user enables "Show button shapes".
    @Environment(\.accessibilityShowBorders) private var showBorders

    private var resolvedTint: Color { tint ?? theme.colors.accent }

    /// When the "Show button shapes" accessibility setting (or a config override) is on,
    /// borderless controls must reveal their tappable shape. For `.ghost` — the only truly
    /// chromeless variant — we draw a subtle capsule outline; resolved through the
    /// ``CosmosAccessibilityPolicy`` chokepoint so `respectShowBorders = false` can opt out.
    /// `.glass` is handled by the native Liquid Glass style (which always shows its shape),
    /// and the filled variants already carry visible chrome, so this only applies to `.ghost`.
    private var showsGhostBorder: Bool {
        variant == .ghost
            && CosmosAccessibilityPolicy.shouldShowBorders(
                respectShowBorders: cosmosConfiguration.accessibility.respectShowBorders,
                showBorders: showBorders
            )
    }

    var body: some View {
        configuration.label
            .font(theme.typography.font(for: theme.textStyle))
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
            // Borderless `.ghost` reveals a capsule outline under "Show button shapes"
            // (config-aware via `showsGhostBorder`). The capsule matches the `.glassEffect`
            // shape above so the revealed shape is the real tappable shape, not an impostor.
            .overlay {
                if showsGhostBorder {
                    Capsule().stroke(theme.colors.outline, lineWidth: 1)
                }
            }
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

// MARK: - Previews

#Preview("Button styles") {
    VStack(spacing: 12) {
        CosmosButton("welcome.headline") {}
        CosmosButton("welcome.continue") {}.cosmosButtonStyle(.secondary)
        CosmosButton("welcome.continue") {}.cosmosButtonStyle(.danger)
        CosmosButton("welcome.continue") {}.cosmosButtonStyle(.ghost)
        CosmosButton("welcome.continue") {}.cosmosButtonStyle(.glass)
    }
    .padding()
}

#Preview("Button states") {
    VStack(spacing: 12) {
        CosmosButton("welcome.headline") {}
        CosmosButton("welcome.continue") {}.cosmosEnabled(false)
        CosmosButton("welcome.continue") {}.cosmosLoading(true)
    }
    .padding()
}

#Preview("Dark + Dynamic Type") {
    VStack(spacing: 12) {
        CosmosButton("welcome.headline") {}
        CosmosButton("welcome.continue") {}.cosmosButtonStyle(.secondary)
    }
    .padding()
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.accessibility5)
}

#Preview("Button – mock + variants matrix", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(spacing: 12) {
            CosmosButton(action: {}) { Text(verbatim: CosmosMock.personName()) }
            CosmosButton(action: {}) { Text(verbatim: CosmosMock.email()) }.cosmosButtonStyle(.secondary)
            CosmosButton("welcome.continue") {}.cosmosButtonStyle(.glass)
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}

// SwiftUI-shaped per-subtree overrides: .cosmosFont / .cosmosTint / .cosmosForegroundStyle compose
// without building a whole CosmosTheme. The button label now honors theme typography (so .cosmosFont
// reaches the label), and .cosmosTint/.cosmosForegroundStyle re-skin the accent/foreground tokens.
#Preview("Button – SwiftUI-shaped overrides", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(spacing: 12) {
            CosmosButton("welcome.continue") {}
                .cosmosFont(.body, weight: .bold, design: .rounded)
                .cosmosTint(.purple)
                .cosmosForegroundStyle(.white)
            CosmosButton("welcome.continue") {}
                .cosmosButtonStyle(.secondary)
                .cosmosFont(.headline, design: .serif)
                .cosmosTint(.teal)
        }
        .padding()
    }
}

// "Show button shapes" accessibility: the borderless `.ghost` variant reveals a capsule outline
// matching its real tappable shape; filled/secondary/danger already carry visible chrome and the
// `.glass` style always shows its Liquid Glass shape, so only `.ghost` adapts. Resolved through
// `CosmosAccessibilityPolicy.shouldShowBorders` (config-aware: `respectShowBorders` can opt out).
#Preview("Button – show borders (a11y)", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(spacing: 12) {
            CosmosButton("welcome.continue") {}.cosmosButtonStyle(.ghost)
            CosmosButton("welcome.continue") {}.cosmosButtonStyle(.secondary)
            CosmosButton("welcome.headline") {}
        }
        .padding()
        .cosmosPreviewVariant(.showBorders)
    }
}
