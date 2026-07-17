import SwiftUI

/// A slider atom wrapping `Slider` with token-driven tint, control size, accessibility, haptics,
/// tracking, and motion.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. There is **no**
/// `CosmosSliderStyle` selector — `Slider` has no style protocol (zero hits in either interface);
/// customization is limited to `.tint` (the min/filled track), `.controlSize`, and the label/value
/// content closures (plus the iOS 26 cluster: `neutralValue` / `enabledBounds` / `currentValueLabel`
/// / ticks).
///
/// **Platform guard.** `Slider` is `@available(tvOS, unavailable)`; the entire atom + any
/// referencing public API are guarded `#if !os(tvOS)`. There is no in-place tvOS fallback —
/// app-level code uses a `Stepper`/`Picker` there. `V` is constrained to `BinaryFloatingPoint`
/// (Double/Float, **not** Int) and `V.Stride` to `BinaryFloatingPoint`, matching `Slider`'s
/// generic contract. Cosmos pins `V = Double` (Double conforms) so the atom stays non-generic in
/// its value type.
///
/// **AnyView-in-init.** The native `Slider` cluster inits (iOS 26) take an opaque
/// `@SliderTickBuilder` tick content (`() -> some SliderTickContent<V>`) that cannot be stored
/// without a new generic parameter. So — like ``CosmosTabView`` — every init builds its concrete
/// native `Slider` **in the init** (where the per-init generic constraints are concrete), type-erases
/// to `AnyView`, and `body` applies the env-driven modifiers (tint, control size, accessibility,
/// motion, haptics, tracking). Modifiers read `@Environment` lazily at render, so building in the
/// init is safe.
///
/// **Customization limits.** No style protocol — cannot customize track height/shape, thumb
/// size/shape/image, or max-track color independently. Only the min (filled) track is tintable.
/// The iOS 26 cluster (`neutralValue` / `enabledBounds` / `currentValueLabel` / ticks) is exposed in
/// a `.v26` init cluster (available iOS/macOS/watchOS/visionOS 26, tvOS unavailable — the atom guard
/// covers tvOS).
///
/// **Default step.** `step` defaults to `0` — **continuous**, matching native
/// `Slider(value:in:)` (the thumb is not quantized). Pass an explicit `step` for a discrete
/// slider; `steppedValue` is a passthrough when `step <= 0`. (A `step` default of `1` over the
/// default `0...1` bounds would make the default slider binary — avoided.)
///
/// **Accessibility:** VoiceOver adjustable element — VoiceOver uses a default increment when no
/// `step` is set; pass a `step` for meaningful discrete adjustment. Always supply a label and set
/// `.cosmosAccessibilityValue` when the displayed value differs from the raw `Double`. When
/// `enabledBounds` narrows the adjustable subrange, set `.cosmosAccessibilityValue`/`.Hint` to
/// reflect the enabled range (the native control announces ticks). Do not rely on tint alone
/// (WCAG 1.4.1 — thumb position is the primary signal).
///
/// **Haptics:** `.selection` on step-snap (discrete `steppedValue` change), gated by
/// ``CosmosHapticsPolicy`` via `.cosmosHaptic`. The trigger is `nil` when `step <= 0` so a
/// continuous slider fires **no** per-pixel selection haptic (noisy/vestibular-hostile) — pass a
/// `step` for discrete haptics. The atom does **not** layer an edit-begin/end `.impact` to avoid
/// fighting the native drag.
///
/// **Motion:** `valueChange` — but the binding is **never** wrapped in `withAnimation` per drag
/// frame (`withAnimation` fights the gesture). The thumb/tint are gesture-tracked (not
/// Cosmos-driven); `.cosmosAnimation(.valueChange, value:)` animates only programmatic commits
/// (a caller writing the binding) and tint crossfades (e.g. when the value crosses `neutralValue`),
/// snapping to instant under reduce-motion. Thumb tracking is motion-as-sole-signal (`.preserve`,
/// WCAG 2.3.3 exempt).
#if !os(tvOS)
public struct CosmosSlider<Label: View, ValueLabel: View>: View {
    private let value: Binding<Double>
    private let bounds: ClosedRange<Double>
    private let step: Double.Stride
    private let neutralValue: Double?
    private let enabledBounds: ClosedRange<Double>?
    private let resolved: AnyView

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    // MARK: Legacy inits (no cluster)

    /// Creates a slider with a custom label and min/max value labels.
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        step: Double.Stride = 0,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder minimumValueLabel: @escaping () -> ValueLabel,
        @ViewBuilder maximumValueLabel: @escaping () -> ValueLabel,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.value = value
        self.bounds = bounds
        self.step = step
        self.neutralValue = nil
        self.enabledBounds = nil
        if step > 0 {
            self.resolved = AnyView(Slider(value: value, in: bounds, step: step, label: label,
                                           minimumValueLabel: minimumValueLabel, maximumValueLabel: maximumValueLabel,
                                           onEditingChanged: onEditingChanged))
        } else {
            // Continuous (no step): use the no-step `Slider` init so the thumb is not quantized —
            // matching native `Slider(value:in:)`. `steppedValue` is a passthrough when step <= 0.
            self.resolved = AnyView(Slider(value: value, in: bounds, label: label,
                                           minimumValueLabel: minimumValueLabel, maximumValueLabel: maximumValueLabel,
                                           onEditingChanged: onEditingChanged))
        }
    }

    /// Creates a slider with a custom label (no min/max value labels).
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        step: Double.Stride = 0,
        @ViewBuilder label: @escaping () -> Label,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where ValueLabel == EmptyView {
        self.init(value: value, in: bounds, step: step,
                  label: label,
                  minimumValueLabel: { EmptyView() }, maximumValueLabel: { EmptyView() },
                  onEditingChanged: onEditingChanged)
    }

    /// Creates a slider with no label and no value labels.
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        step: Double.Stride = 0,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where Label == EmptyView, ValueLabel == EmptyView {
        self.init(value: value, in: bounds, step: step,
                  label: { EmptyView() },
                  minimumValueLabel: { EmptyView() }, maximumValueLabel: { EmptyView() },
                  onEditingChanged: onEditingChanged)
    }

    // MARK: iOS 26 cluster inits (within floor: iOS/macOS/watchOS/visionOS 26; tvOS unavailable — atom guard covers)
    //
    // Source: `@available(iOS 26.0, macOS 26.0, watchOS 26.0, visionOS 26.0, *) @available(tvOS,
    // unavailable) extension Slider { init(value:in:neutralValue:enabledBounds:label:currentValueLabel:
    // minimumValueLabel:maximumValueLabel:onEditingChanged:) … }` (Xcode 27 Beta 3 interface).
    // `neutralValue: V? = nil`, `enabledBounds: ClosedRange<V>? = nil` (a plain optional
    // `ClosedRange`, NOT a `Binding`, NOT `Float`-only), `currentValueLabel: () -> some View =
    // { EmptyView() }`. `ticks` is an init parameter via `@SliderTickBuilder<V>` (NOT a
    // `.ticks(_:)` modifier); the step variant takes `tick: (V) -> SliderTick<V>?`. There is NO
    // `TickConfiguration` type. Forwarded with `V = Double` (Double conforms) — no generic rewrite.
    //
    // Each cluster init builds the native `Slider` in the init and type-erases to `AnyView` so the
    // opaque `@SliderTickBuilder` tick content needs no stored generic parameter (AnyView-in-init,
    // cf. ``CosmosTabView``). `currentValueLabel` is an opaque `() -> some View` baked into the
    // erased view — not a struct generic.

    /// Creates a slider with the iOS 26 cluster: `neutralValue`, `enabledBounds`, a current-value
    /// label, and min/max value labels (no ticks, no step). Available since Cosmos 26.
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        neutralValue: Double? = nil,
        enabledBounds: ClosedRange<Double>? = nil,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder currentValueLabel: @escaping () -> some View,
        @ViewBuilder minimumValueLabel: @escaping () -> ValueLabel,
        @ViewBuilder maximumValueLabel: @escaping () -> ValueLabel,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.value = value
        self.bounds = bounds
        self.step = 0
        self.neutralValue = neutralValue
        self.enabledBounds = enabledBounds
        self.resolved = AnyView(Slider(value: value, in: bounds, neutralValue: neutralValue,
                                       enabledBounds: enabledBounds, label: label,
                                       currentValueLabel: currentValueLabel,
                                       minimumValueLabel: minimumValueLabel, maximumValueLabel: maximumValueLabel,
                                       onEditingChanged: onEditingChanged))
    }

    /// Creates a slider with the iOS 26 cluster and declarative ticks via `@SliderTickBuilder`
    /// (no step). Available since Cosmos 26.
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        neutralValue: Double? = nil,
        enabledBounds: ClosedRange<Double>? = nil,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder currentValueLabel: @escaping () -> some View,
        @ViewBuilder minimumValueLabel: @escaping () -> ValueLabel,
        @ViewBuilder maximumValueLabel: @escaping () -> ValueLabel,
        @SliderTickBuilder<Double> ticks: @escaping () -> some SliderTickContent<Double>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.value = value
        self.bounds = bounds
        self.step = 0
        self.neutralValue = neutralValue
        self.enabledBounds = enabledBounds
        self.resolved = AnyView(Slider(value: value, in: bounds, neutralValue: neutralValue,
                                       enabledBounds: enabledBounds, label: label,
                                       currentValueLabel: currentValueLabel,
                                       minimumValueLabel: minimumValueLabel, maximumValueLabel: maximumValueLabel,
                                       ticks: ticks, onEditingChanged: onEditingChanged))
    }

    /// Creates a slider with the iOS 26 cluster, a discrete `step`, and a per-value `tick` closure.
    /// Available since Cosmos 26.
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double>,
        step: Double.Stride = 1,
        neutralValue: Double? = nil,
        enabledBounds: ClosedRange<Double>? = nil,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder currentValueLabel: @escaping () -> some View,
        @ViewBuilder minimumValueLabel: @escaping () -> ValueLabel,
        @ViewBuilder maximumValueLabel: @escaping () -> ValueLabel,
        tick: @escaping (Double) -> SliderTick<Double>?,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.value = value
        self.bounds = bounds
        self.step = step
        self.neutralValue = neutralValue
        self.enabledBounds = enabledBounds
        self.resolved = AnyView(Slider(value: value, in: bounds, step: step, neutralValue: neutralValue,
                                       enabledBounds: enabledBounds, label: label,
                                       currentValueLabel: currentValueLabel,
                                       minimumValueLabel: minimumValueLabel, maximumValueLabel: maximumValueLabel,
                                       tick: tick, onEditingChanged: onEditingChanged))
    }

    /// Creates a slider with the iOS 26 cluster and a custom label (no min/max value labels); the
    /// current-value label defaults to empty. The most common cluster form. Available since Cosmos 26.
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        neutralValue: Double? = nil,
        enabledBounds: ClosedRange<Double>? = nil,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder currentValueLabel: @escaping () -> some View = { EmptyView() },
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where ValueLabel == EmptyView {
        self.value = value
        self.bounds = bounds
        self.step = 0
        self.neutralValue = neutralValue
        self.enabledBounds = enabledBounds
        self.resolved = AnyView(Slider(value: value, in: bounds, neutralValue: neutralValue,
                                       enabledBounds: enabledBounds, label: label,
                                       currentValueLabel: currentValueLabel,
                                       onEditingChanged: onEditingChanged))
    }

    /// Creates a slider with the iOS 26 cluster, declarative ticks via `@SliderTickBuilder`, and a
    /// custom label (no min/max value labels); the current-value label defaults to empty. Available
    /// since Cosmos 26.
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        neutralValue: Double? = nil,
        enabledBounds: ClosedRange<Double>? = nil,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder currentValueLabel: @escaping () -> some View = { EmptyView() },
        @SliderTickBuilder<Double> ticks: @escaping () -> some SliderTickContent<Double>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where ValueLabel == EmptyView {
        self.value = value
        self.bounds = bounds
        self.step = 0
        self.neutralValue = neutralValue
        self.enabledBounds = enabledBounds
        self.resolved = AnyView(Slider(value: value, in: bounds, neutralValue: neutralValue,
                                       enabledBounds: enabledBounds, label: label,
                                       currentValueLabel: currentValueLabel,
                                       ticks: ticks, onEditingChanged: onEditingChanged))
    }

    /// Creates a slider with the iOS 26 cluster, a discrete `step`, a per-value `tick` closure, and
    /// a custom label (no min/max value labels); the current-value label defaults to empty.
    /// Available since Cosmos 26.
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double>,
        step: Double.Stride = 1,
        neutralValue: Double? = nil,
        enabledBounds: ClosedRange<Double>? = nil,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder currentValueLabel: @escaping () -> some View = { EmptyView() },
        tick: @escaping (Double) -> SliderTick<Double>?,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where ValueLabel == EmptyView {
        self.value = value
        self.bounds = bounds
        self.step = step
        self.neutralValue = neutralValue
        self.enabledBounds = enabledBounds
        self.resolved = AnyView(Slider(value: value, in: bounds, step: step, neutralValue: neutralValue,
                                       enabledBounds: enabledBounds, label: label,
                                       currentValueLabel: currentValueLabel,
                                       tick: tick, onEditingChanged: onEditingChanged))
    }

    public var body: some View {
        if configuration.enable.isVisible {
            resolved
                .tint(theme.colors.accent)
                .controlSize(theme.controlSize.controlSize)
                .disabled(!effectiveEnabled)
                .opacity(configuration.loading.isLoading ? 0.6 : 1.0)
                .applyCosmosAccessibility(configuration.accessibility)
                .cosmosAnimation(.valueChange, value: steppedValue)
                .cosmosHaptic(.selection, trigger: step > 0 ? steppedValue : nil)
                .onAppear { trackAppear() }
                .onChange(of: steppedValue) { _, _ in trackStepChange() }
        } else {
            EmptyView()
        }
    }

    private var effectiveEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly && !configuration.loading.isLoading
    }

    /// The value quantized to `step` (and clamped to `enabledBounds` when present) — used as the
    /// haptic + motion `trigger` so a `.selection` fires on step-snap (discrete), not per drag
    /// pixel, and `.cosmosAnimation(.valueChange)` animates only programmatic commits / step-snap
    /// (never per drag frame). The native `Slider` already restricts the thumb to `enabledBounds`;
    /// this is a pure mirror so derived triggers respect the enabled subrange.
    private var steppedValue: Double {
        var v = CosmosSliderMath.stepped(value: value.wrappedValue, lower: bounds.lowerBound, upper: bounds.upperBound, step: step)
        if let enabled = enabledBounds {
            v = CosmosSliderMath.clampedToEnabledBounds(v, enabled: enabled)
        }
        return v
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "slider_appear",
            component: "CosmosSlider",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }

    private func trackStepChange() {
        // Track on step-snap (discrete) or per change (continuous): `steppedValue` only changes
        // when the quantized value moves, so this never double-fires per drag pixel.
        configuration.tracking.track(.init(
            name: "slider_change",
            component: "CosmosSlider",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .valueChange
        ))
    }
}
#endif // !os(tvOS) — atom above; math + availability below are platform-agnostic (pure, testable on any host).

// MARK: - Stepping math (pure, testable without rendering)

/// Pure quantizer for ``CosmosSlider``: aligns a raw `value` to the nearest `step` within
/// `[lower, upper]`, clamps to an `enabledBounds` subrange, and snaps to the nearest tick. Used as
/// the haptic + motion `trigger` so feedback fires on step-snap (discrete), not per drag pixel.
/// `step <= 0` is a passthrough (no quantization).
public enum CosmosSliderMath {
    /// Aligns `value` to the nearest `step` within `[lower, upper]`. `step <= 0` → passthrough.
    public static func stepped(value: Double, lower: Double, upper: Double, step: Double) -> Double {
        guard step > 0 else { return value }
        let raw = ((value - lower) / step).rounded() * step + lower
        return min(max(raw, lower), upper)
    }

    /// Clamps `value` into the `enabled` subrange: below → lower bound, above → upper bound,
    /// otherwise unchanged. The native `Slider` already restricts the thumb to `enabledBounds`;
    /// this pure mirror keeps derived triggers/values consistent.
    public static func clampedToEnabledBounds(_ value: Double, enabled: ClosedRange<Double>) -> Double {
        min(max(value, enabled.lowerBound), enabled.upperBound)
    }

    /// Aligns `value` to the nearest tick value in `tickValues`. If empty, returns `value`
    /// unchanged. `tickValues` need not be sorted (nearest by absolute distance).
    public static func tickSnap(value: Double, tickValues: [Double]) -> Double {
        guard let nearest = tickValues.min(by: { abs($0 - value) < abs($1 - value) }) else { return value }
        return nearest
    }
}

// MARK: - Cluster availability (pure, testable on any host)

/// Pure availability table for the iOS 26 `Slider` cluster (`neutralValue` / `enabledBounds` /
/// `currentValueLabel` / ticks). The cluster is `@available(iOS 26.0, macOS 26.0, watchOS 26.0,
/// visionOS 26.0, *) @available(tvOS, unavailable)` — within-floor on the four Slider platforms,
/// unavailable on tvOS (the whole atom is `#if !os(tvOS)`).
public enum CosmosSliderClusterAvailability {
    /// The cluster is available on iOS / macOS / watchOS / visionOS at the Cosmos 26 floor; never
    /// on tvOS.
    public static func isAvailable(on platform: CosmosPlatform) -> Bool {
        switch platform {
        case .ios, .macos, .watchos, .visionos: return true
        case .tvos: return false
        }
    }
}

// MARK: - Convenience inits

#if !os(tvOS)
extension CosmosSlider where Label == CosmosLocalizedText, ValueLabel == EmptyView {
    /// Creates a slider from a localized String Catalog key (no min/max value labels).
    public init(
        _ titleKey: String,
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        step: Double.Stride = 0,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(value: value, in: bounds, step: step,
                  label: { CosmosLocalizedText(key: titleKey) },
                  onEditingChanged: onEditingChanged)
    }

    /// Creates a slider with the iOS 26 cluster from a localized String Catalog key (no current /
    /// min / max value labels). Available since Cosmos 26.
    public init(
        _ titleKey: String,
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        neutralValue: Double? = nil,
        enabledBounds: ClosedRange<Double>? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(value: value, in: bounds, neutralValue: neutralValue, enabledBounds: enabledBounds,
                  label: { CosmosLocalizedText(key: titleKey) },
                  onEditingChanged: onEditingChanged)
    }
}

extension CosmosSlider where Label == Text, ValueLabel == EmptyView {
    /// Creates a slider from verbatim (non-localized) label text (no min/max value labels).
    public init<S: StringProtocol>(
        verbatim title: S,
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        step: Double.Stride = 0,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(value: value, in: bounds, step: step,
                  label: { Text(verbatim: String(title)) },
                  onEditingChanged: onEditingChanged)
    }
}
#endif // !os(tvOS) — convenience inits reference the guarded atom.

// MARK: - Previews (Slider is unavailable on tvOS — guard the preview blocks)

#if !os(tvOS)
#Preview("Slider – label + bounds") {
    @Previewable @State var value = 0.5
    VStack(spacing: 24) {
        CosmosSlider("preview.title", value: $value, in: 0...1, step: 0.1)
        CosmosSlider(value: $value, in: 0...1, step: 0.05) {
            Label("preview.title", systemImage: "speedometer")
        }
        CosmosSlider(value: $value, in: 0...10, step: 1) {
            Image(systemName: "speaker.wave.1.fill")
        } minimumValueLabel: {
            Image(systemName: "speaker.wave.1.fill")
        } maximumValueLabel: {
            Image(systemName: "speaker.wave.3.fill")
        }
    }
    .padding()
}

#Preview("Slider – dark + accessibility size", traits: .sizeThatFitsLayout) {
    @Previewable @State var value = 0.3
    CosmosPreviewContainer {
        VStack(spacing: 24) {
            CosmosSlider("preview.title", value: $value, in: 0...1, step: 0.1)
                .cosmosControlSize(.small)
            CosmosSlider(verbatim: CosmosMock.sentence(wordCount: 3), value: $value, in: 0...1)
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}

#Preview("Slider – iOS 26 cluster (neutralValue + enabledBounds)", traits: .sizeThatFitsLayout) {
    @Previewable @State var value = 0.4
    CosmosPreviewContainer {
        VStack(spacing: 24) {
            CosmosSlider("preview.title", value: $value, in: 0...1,
                         neutralValue: 0.5, enabledBounds: 0.2...0.8)
            CosmosSlider(value: $value, in: 0...1, neutralValue: 0.5, enabledBounds: 0.2...0.8) {
                Label("preview.title", systemImage: "speedometer")
            } currentValueLabel: {
                Text(value, format: .percent)
            }
        }
        .padding()
    }
}

#Preview("Slider – iOS 26 cluster (ticks)", traits: .sizeThatFitsLayout) {
    @Previewable @State var value = 0.25
    CosmosPreviewContainer {
        VStack(spacing: 24) {
            CosmosSlider(value: $value, in: 0...1, neutralValue: 0.5) {
                Label("preview.title", systemImage: "speedometer")
            } ticks: {
                SliderTick(0.0)
                SliderTick(0.25)
                SliderTick(0.5)
                SliderTick(0.75)
                SliderTick(1.0)
            }
            CosmosSlider(value: $value, in: 0...1, step: 0.25, neutralValue: 0.5) {
                Label("preview.title", systemImage: "speedometer")
            } tick: { v in
                v == 0.5 ? SliderTick(v) : nil
            }
        }
        .padding()
        .cosmosPreviewVariant(.dark)
    }
}
#endif