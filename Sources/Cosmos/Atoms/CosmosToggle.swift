import SwiftUI

/// A toggle atom wrapping `Toggle` with token-driven tint, control size, accessibility, haptics,
/// tracking, and a custom conforming ``CosmosToggleChrome`` style that re-applies the
/// `.isToggle` trait + value string.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. The visual variant
/// comes from ``CosmosTheme/toggleStyle`` (default `.automatic`).
///
/// **Haptics:** a `.selection` haptic is attached **only** for the `.button` variant — the
/// native `.switch`/`.automatic` styles (and ``CosmosToggleChrome``, which delegates to
/// `.switch`) emit their own selection haptic on flip, so Cosmos does not double-haptic. (On
/// tvOS `.sensoryFeedback` is a no-op, so this guard is harmless there.) The deprecated
/// `SwitchToggleStyle(tint:)` initializer is never used; the accent tint is applied via
/// `.tint(_:)`.
///
/// **Motion:** the native switch thumb animation is system-driven, so Cosmos deliberately does
/// NOT layer `.cosmosAnimation(.valueChange)` on it (that would desync). The motion handler is
/// not fired for the toggle; only the tracking `.valueChange` event is emitted on flip.
public struct CosmosToggle<Label: View>: View {
    private let isOn: Binding<Bool>
    @ViewBuilder private let label: () -> Label

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    /// Creates a toggle with a custom label view.
    public init(isOn: Binding<Bool>, @ViewBuilder label: @escaping () -> Label) {
        self.isOn = isOn
        self.label = label
    }

    private var effectiveEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly && !configuration.loading.isLoading
    }

    /// `true` only for `.button` — the only variant without a native selection haptic.
    private var shouldEmitHaptic: Bool {
        CosmosToggleAccessibility.shouldEmitSelectionHaptic(style: theme.toggleStyle)
    }

    public var body: some View {
        if configuration.enable.isVisible {
            Toggle(isOn: isOn) { label() }
                .modifier(CosmosToggleStyleApplier(style: theme.toggleStyle))
                .controlSize(theme.controlSize.controlSize)
                .tint(theme.colors.accent)
                .disabled(!effectiveEnabled)
                .opacity(configuration.loading.isLoading ? 0.6 : 1.0)
                .applyCosmosAccessibility(configuration.accessibility, extraTraits: .isToggle)
                .onAppear { trackAppear() }
                .onChange(of: isOn.wrappedValue) { _, _ in trackValueChange() }
                .modifier(CosmosToggleSelectionHapticModifier(enabled: shouldEmitHaptic, isOn: isOn.wrappedValue))
        } else {
            EmptyView()
        }
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "toggle_appear",
            component: "CosmosToggle",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }

    private func trackValueChange() {
        configuration.tracking.track(.init(
            name: "toggle_change",
            component: "CosmosToggle",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .valueChange
        ))
    }
}

// MARK: - Convenience inits

extension CosmosToggle where Label == CosmosLocalizedText {
    /// Creates a toggle from a localized String Catalog key.
    public init(_ titleKey: String, isOn: Binding<Bool>) {
        self.isOn = isOn
        self.label = { CosmosLocalizedText(key: titleKey) }
    }
}

extension CosmosToggle where Label == Text {
    /// Creates a toggle from verbatim (non-localized) text.
    public init<S: StringProtocol>(verbatim title: S, isOn: Binding<Bool>) {
        self.isOn = isOn
        self.label = { Text(verbatim: String(title)) }
    }
}

extension CosmosToggle where Label == SwiftUI.Label<CosmosLocalizedText, Image> {
    /// Creates a toggle from a localized String Catalog key and an SF Symbol.
    public init(_ titleKey: String, systemImage: String, isOn: Binding<Bool>) {
        self.isOn = isOn
        self.label = { Label { CosmosLocalizedText(key: titleKey) } icon: { Image(systemName: systemImage) } }
    }
}

// MARK: - Style resolution

/// Resolves a ``CosmosToggleStyle`` to a concrete `ToggleStyle`. `.button` is unavailable on tvOS
/// (it falls back to ``CosmosToggleChrome`` there); `.switch` routes through the custom chrome
/// (which delegates to the native switch and re-applies accessibility).
private struct CosmosToggleStyleApplier: ViewModifier {
    let style: CosmosToggleStyle
    func body(content: Content) -> some View {
        switch style {
        case .automatic: content.toggleStyle(.automatic)
        case .switch:    content.toggleStyle(CosmosToggleChrome())
        case .button:
            #if os(tvOS)
            content.toggleStyle(CosmosToggleChrome())
            #else
            content.toggleStyle(.button)
            #endif
        }
    }
}

/// Pure accessibility helper for toggle rendering (testable without rendering views).
public enum CosmosToggleAccessibility {
    /// The VoiceOver value string for a toggle: "Mixed" when indeterminate, else "On"/"Off".
    public static func valueString(isOn: Bool, isMixed: Bool) -> String {
        if isMixed { return "Mixed" }
        return isOn ? "On" : "Off"
    }

    /// Whether the `.selection` haptic should fire for the given toggle style. Only `.button`
    /// lacks a native selection haptic; `.switch`/`.automatic` (and the ``CosmosToggleChrome``
    /// that delegates to `.switch`) emit their own on flip, so Cosmos attaches one only for
    /// `.button` to avoid a double haptic. On tvOS `.button` is remapped to the switch chrome, but
    /// `.sensoryFeedback` is a no-op there, so emitting remains harmless.
    public static func shouldEmitSelectionHaptic(style: CosmosToggleStyle) -> Bool {
        style == .button
    }
}

/// Custom `ToggleStyle` that delegates to the native `.switch` (inheriting the accent tint from
/// the environment) and re-applies the `.isToggle` trait + a Cosmos value string — demonstrating
/// the accessibility re-application required when a custom style reimplements rendering.
public struct CosmosToggleChrome: ToggleStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        CosmosToggleChromeBody(configuration: configuration)
    }
}

private struct CosmosToggleChromeBody: View {
    let configuration: ToggleStyle.Configuration
    var body: some View {
        Toggle(configuration)
            .toggleStyle(.switch)
            .accessibilityAddTraits(.isToggle)
            .accessibilityValue(Text(CosmosToggleAccessibility.valueString(
                isOn: configuration.isOn,
                isMixed: configuration.isMixed
            )))
    }
}

/// Attaches the canonical `.cosmosHaptic(.selection)` only when `enabled` (i.e. only for
/// `.button`); otherwise a pass-through. Delegates the sensory-feedback emission, the
/// `@Sendable` handler forwarding, and the `CosmosHapticsPolicy`/Reduce-Motion gating to
/// ``View/cosmosHaptic(_:trigger:)`` so the toggle does not duplicate that logic — only the
/// `.button`-only gate is toggle-specific (see ``CosmosToggleAccessibility/shouldEmitSelectionHaptic(style:)``).
private struct CosmosToggleSelectionHapticModifier: ViewModifier {
    let enabled: Bool
    let isOn: Bool

    func body(content: Content) -> some View {
        guard enabled else { return AnyView(content) }
        return AnyView(content.cosmosHaptic(.selection, trigger: isOn))
    }
}

// MARK: - Previews

#Preview("Toggle styles") {
    @Previewable @State var isOn = false
    VStack(alignment: .leading, spacing: 12) {
        CosmosToggle("preview.title", isOn: $isOn)
        CosmosToggle("preview.title", isOn: $isOn).cosmosToggleStyle(.switch)
        CosmosToggle("preview.title", isOn: $isOn).cosmosToggleStyle(.button)
        CosmosToggle("preview.title", systemImage: "wifi", isOn: $isOn)
    }
    .padding()
}

#Preview("Toggle – states") {
    @Previewable @State var a = true
    @Previewable @State var b = false
    VStack(alignment: .leading, spacing: 12) {
        CosmosToggle("preview.title", isOn: $a)
        CosmosToggle("preview.title", isOn: $b).cosmosEnabled(false)
        CosmosToggle("preview.title", isOn: $b).cosmosLoading(true)
    }
    .padding()
}

#Preview("Toggle – dark + accessibility size", traits: .sizeThatFitsLayout) {
    @Previewable @State var isOn = false
    CosmosPreviewContainer {
        VStack(alignment: .leading, spacing: 12) {
            CosmosToggle("preview.title", isOn: $isOn)
            CosmosToggle("preview.title", systemImage: "bell.fill", isOn: $isOn).cosmosToggleStyle(.button)
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}