import SwiftUI

/// A slider atom wrapping `Slider` with token-driven tint, control size, accessibility, haptics,
/// tracking, and motion.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. There is **no**
/// `CosmosSliderStyle` selector — `Slider` has no style protocol (zero hits in either interface);
/// customization is limited to `.tint` (the min/filled track), `.controlSize`, and the label/value
/// content closures.
///
/// **Platform guard.** `Slider` is `@available(tvOS, unavailable)`; the entire atom + any
/// referencing public API are guarded `#if !os(tvOS)`. There is no in-place tvOS fallback —
/// app-level code uses a `Stepper`/`Picker` there. `V` is constrained to `BinaryFloatingPoint`
/// (Double/Float, **not** Int) and `V.Stride` to `BinaryFloatingPoint`, matching `Slider`'s
/// generic contract.
///
/// **Customization limits.** No style protocol — cannot customize track height/shape, thumb
/// size/shape/image, max-track color independently, or tick rendering pre-iOS-26. Only the min
/// (filled) track is tintable. The iOS 26 ticks/`neutralValue`/`enabledBounds`/`currentValueLabel`
/// cluster is deliberately **not** exposed here (it adds a `SliderTickBuilder`/
/// `SliderTickContent` surface that fragments the API); it can be added in a `.v27` init cluster
/// when the floor raises.
///
/// **Default step.** `step` defaults to `0` — **continuous**, matching native
/// `Slider(value:in:)` (the thumb is not quantized). Pass an explicit `step` for a discrete
/// slider; `steppedValue` is a passthrough when `step <= 0`. (A `step` default of `1` over the
/// default `0...1` bounds would make the default slider binary — avoided.)
///
/// **Accessibility:** VoiceOver adjustable element — VoiceOver uses a default increment when no
/// `step` is set; pass a `step` for meaningful discrete adjustment. Always supply a label and set
/// `.cosmosAccessibilityValue` when the displayed value differs from the raw `Double`. Do not
/// rely on tint alone (WCAG 1.4.1 — thumb position is the primary signal).
///
/// **Haptics:** `.selection` on step-snap (discrete `steppedValue` change), gated by
/// ``CosmosHapticsPolicy`` via `.cosmosHaptic`. The trigger is `nil` when `step <= 0` so a
/// continuous slider fires **no** per-pixel selection haptic (noisy/vestibular-hostile) — pass a
/// `step` for discrete haptics. The atom does **not** layer an edit-begin/end `.impact` to avoid
/// fighting the native drag (and because `.sensoryFeedback` on the binding `trigger` cannot
/// distinguish drag-begin cleanly without extra state).
///
/// **Motion:** `valueChange` — but the binding is **never** wrapped in `withAnimation` per drag
/// frame (`withAnimation` fights the gesture). The thumb/tint are gesture-tracked (not
/// Cosmos-driven); `.cosmosAnimation(.valueChange, value:)` animates only programmatic commits
/// (a caller writing the binding) and tint crossfades, snapping to instant under reduce-motion.
/// Thumb tracking is motion-as-sole-signal (`.preserve`, WCAG 2.3.3 exempt).
#if !os(tvOS)
public struct CosmosSlider<Label: View, ValueLabel: View>: View {
    private let value: Binding<Double>
    private let bounds: ClosedRange<Double>
    private let step: Double.Stride
    private let onEditingChanged: (Bool) -> Void
    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let minimumValueLabel: () -> ValueLabel
    @ViewBuilder private let maximumValueLabel: () -> ValueLabel

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

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
        self.onEditingChanged = onEditingChanged
        self.label = label
        self.minimumValueLabel = minimumValueLabel
        self.maximumValueLabel = maximumValueLabel
    }

    /// Creates a slider with a custom label (no min/max value labels).
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        step: Double.Stride = 0,
        @ViewBuilder label: @escaping () -> Label,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where ValueLabel == EmptyView {
        self.value = value
        self.bounds = bounds
        self.step = step
        self.onEditingChanged = onEditingChanged
        self.label = label
        self.minimumValueLabel = { EmptyView() }
        self.maximumValueLabel = { EmptyView() }
    }

    /// Creates a slider with no label and no value labels.
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        step: Double.Stride = 0,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where Label == EmptyView, ValueLabel == EmptyView {
        self.value = value
        self.bounds = bounds
        self.step = step
        self.onEditingChanged = onEditingChanged
        self.label = { EmptyView() }
        self.minimumValueLabel = { EmptyView() }
        self.maximumValueLabel = { EmptyView() }
    }

    public var body: some View {
        if configuration.enable.isVisible {
            slider
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

    @ViewBuilder private var slider: some View {
        if step > 0 {
            Slider(value: value, in: bounds, step: step, label: label,
                   minimumValueLabel: minimumValueLabel, maximumValueLabel: maximumValueLabel,
                   onEditingChanged: onEditingChanged)
        } else {
            // Continuous (no step): use the no-step `Slider` init so the thumb is not quantized —
            // matching native `Slider(value:in:)`. `steppedValue` is a passthrough when step <= 0.
            Slider(value: value, in: bounds, label: label,
                   minimumValueLabel: minimumValueLabel, maximumValueLabel: maximumValueLabel,
                   onEditingChanged: onEditingChanged)
        }
    }

    private var effectiveEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly && !configuration.loading.isLoading
    }

    /// The value quantized to `step` — used as the haptic + motion `trigger` so a `.selection`
    /// fires on step-snap (discrete), not per drag pixel, and `.cosmosAnimation(.valueChange)`
    /// animates only programmatic commits / step-snap (never per drag frame).
    private var steppedValue: Double {
        CosmosSliderMath.stepped(value: value.wrappedValue, lower: bounds.lowerBound, upper: bounds.upperBound, step: step)
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
        // when the quantized value moves, so this never double-fires per drag pixel. (The
        // previous `abs(newValue - steppedValue) < .ulpOfOne` gate desynced from the `==`-gated
        // haptic at non-trivial magnitude — FP residual exceeded `.ulpOfOne` and dropped events
        // the haptic emitted. Tracking the quantized value removes the float-compare entirely.)
        configuration.tracking.track(.init(
            name: "slider_change",
            component: "CosmosSlider",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .valueChange
        ))
    }
}
#endif // !os(tvOS) — atom above; math below is platform-agnostic (pure, testable on any host).

// MARK: - Stepping math (pure, testable without rendering)

/// Pure quantizer for ``CosmosSlider``: aligns a raw `value` to the nearest `step` within
/// `[lower, upper]`. Used as the haptic + motion `trigger` so feedback fires on step-snap
/// (discrete), not per drag pixel. `step <= 0` is a passthrough (no quantization).
public enum CosmosSliderMath {
    public static func stepped(value: Double, lower: Double, upper: Double, step: Double) -> Double {
        guard step > 0 else { return value }
        let raw = ((value - lower) / step).rounded() * step + lower
        return min(max(raw, lower), upper)
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
        self.value = value
        self.bounds = bounds
        self.step = step
        self.onEditingChanged = onEditingChanged
        self.label = { CosmosLocalizedText(key: titleKey) }
        self.minimumValueLabel = { EmptyView() }
        self.maximumValueLabel = { EmptyView() }
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
        self.value = value
        self.bounds = bounds
        self.step = step
        self.onEditingChanged = onEditingChanged
        self.label = { Text(verbatim: String(title)) }
        self.minimumValueLabel = { EmptyView() }
        self.maximumValueLabel = { EmptyView() }
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
#endif