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
