import SwiftUI

/// A stepper atom wrapping `Stepper` with token-driven tint, control size, typography,
/// accessibility, tracking, and motion — plus a `CosmosButton` +/- pair fallback on tvOS (where
/// `Stepper` is unavailable).
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. There is **no**
/// `CosmosStepperStyle` selector — `Stepper` has no style protocol (zero hits in either
/// interface); customization is limited to `.tint`, `.controlSize`, `.font`, and the label.
///
/// **Platform guard.** `Stepper` is `@available(tvOS, unavailable)` at the type level. Unlike a
/// pure guard, this atom keeps a uniform public API on all 5 platforms: on tvOS it renders a
/// `CosmosButton` +/- pair; on iOS/macOS/watchOS/visionOS it renders the native `Stepper`. The
/// native + tvOS paths share one set of increment/decrement closures — value/step/bounds inits
/// synthesize closures (capturing only init parameters, never `self`) that mutate the binding
/// with bounds clamping, so the two paths behave identically.
///
/// **Init ordering.** Only label-first builder inits are exposed (the deprecated trailing-closure-
/// last `onEditingChanged`-before-`label` form is never used — it triggers warnings-as-failures).
/// The `format`-based inits (`F.FormatInput: BinaryFloatingPoint`, iOS 16+) are deliberately not
/// exposed here (they add a `ParseableFormatStyle` generic surface); use the `Strideable` value
/// inits for `Double`/`Float`, or the closures inits.
///
/// **Haptics:** the native `Stepper` auto-emits system haptics on iOS/watchOS, so Cosmos adds
/// **none** on the native branch (no double-fire). The tvOS `CosmosButton` fallback fires its own
/// press haptic (gated by config via ``CosmosButton``) — native haptics are absent on tvOS's
/// `Stepper` because there is no `Stepper` there, so the button's press haptic is additive, not a
/// double. Cosmos does not layer an extra `.cosmosHaptic(.selection)` to keep the source of
/// haptic truth in `CosmosButton`.
///
/// **Motion:** `none` — Cosmos applies **no** `.cosmosAnimation` here. The native `Stepper`
/// animates its own value changes and respects Reduce Motion natively (via SwiftUI's environment);
/// layering a token-driven `.cosmosAnimation(.valueChange, value:)` on top would animate the
/// same property with a differing curve and desync (CLAUDE.md: "avoid per-view `.animation(_:value:)`
/// with differing curves"). The value-form inits synthesize increment/decrement closures (so
/// there is no observable binding on the atom to drive a Cosmos animation against in any case).
/// `onEditingChanged(true→false)` brackets an edit session (fired by the native `Stepper`, or by
/// the tvOS fallback's `bracket(_:)`); do not use `appear`/`disappear`/`sheet`.
public struct CosmosStepper<Label: View>: View {
    private let onIncrement: () -> Void
    private let onDecrement: () -> Void
    private let onEditingChanged: (Bool) -> Void
    @ViewBuilder private let label: () -> Label

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    /// Creates a stepper whose label and increment/decrement actions are custom views/closures.
    public init(
        @ViewBuilder label: @escaping () -> Label,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.label = label
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
        self.onEditingChanged = onEditingChanged
    }

    /// Creates a stepper bound to a `Strideable` value that mutates by `step` per press.
    public init<V: Strideable>(
        value: Binding<V>,
        step: V.Stride = 1,
        @ViewBuilder label: @escaping () -> Label,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: Sendable, V.Stride: Sendable {
        self.label = label
        self.onEditingChanged = onEditingChanged
        self.onIncrement = { CosmosStepper.step(value, by: step, bounds: nil) }
        self.onDecrement = { CosmosStepper.step(value, by: -step, bounds: nil) }
    }

    /// Creates a stepper bound to a `Strideable` value constrained to `bounds`, mutating by `step`.
    public init<V: Strideable & Comparable>(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride = 1,
        @ViewBuilder label: @escaping () -> Label,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: Sendable, V.Stride: Sendable {
        self.label = label
        self.onEditingChanged = onEditingChanged
        self.onIncrement = { CosmosStepper.step(value, by: step, bounds: bounds) }
        self.onDecrement = { CosmosStepper.step(value, by: -step, bounds: bounds) }
    }

    public var body: some View {
        if configuration.enable.isVisible {
            #if os(tvOS)
            tvOSFallback
            #else
            nativeStepper
            #endif
        } else {
            EmptyView()
        }
    }

    #if !os(tvOS)
    @ViewBuilder private var nativeStepper: some View {
        Stepper(label: label, onIncrement: onIncrement, onDecrement: onDecrement, onEditingChanged: onEditingChanged)
            .tint(theme.colors.accent)
            .controlSize(theme.controlSize.controlSize)
            .font(theme.typography.font(for: theme.textStyle))
            .disabled(!effectiveEnabled)
            .opacity(configuration.loading.isLoading ? 0.6 : 1.0)
            .applyCosmosAccessibility(configuration.accessibility)
            .onAppear { trackAppear() }
    }
    #endif

    #if os(tvOS)
    @ViewBuilder private var tvOSFallback: some View {
        HStack(spacing: CosmosSpacingTokens.small) {
            CosmosButton(action: { bracket(onDecrement) }) {
                Text("−").font(theme.typography.font(for: theme.textStyle))
            }
            label().font(theme.typography.font(for: theme.textStyle))
            CosmosButton(action: { bracket(onIncrement) }) {
                Text("+").font(theme.typography.font(for: theme.textStyle))
            }
        }
        .tint(theme.colors.accent)
        .disabled(!effectiveEnabled)
        .opacity(configuration.loading.isLoading ? 0.6 : 1.0)
        // tvOS has no `Stepper` and no `.isAdjustable` trait (that trait is iOS-only), so the
        // +/- `CosmosButton`s are the operable controls — each its own focusable button, which is
        // the tvOS idiom (Siri Remote moves focus between them). Do NOT mark the HStack itself as
        // a button (that produced a button-containing-buttons accessibility tree). The caller's
        // label/hint apply to the grouping; `bracket(_:)` fires `onEditingChanged` per press
        // (which the native `Stepper` would fire itself, but there is none on tvOS).
        .applyCosmosAccessibility(configuration.accessibility)
        .onAppear { trackAppear() }
    }

    /// Wraps a +/- action in an edit-session bracket (`onEditingChanged` true→false), mirroring
    /// what the native `Stepper` fires itself (which the tvOS fallback must do manually since
    /// there is no native `Stepper` on tvOS).
    private func bracket(_ action: () -> Void) {
        onEditingChanged(true)
        action()
        onEditingChanged(false)
    }
    #endif

    private var effectiveEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly && !configuration.loading.isLoading
    }

    /// Mutates `value` by `stride`, clamping to `bounds` when present. A static free function so
    /// the synthesized value-form closures capture only init parameters (the `Binding` and
    /// `V.Stride`), never `self` — keeping the closures `Sendable`-clean and avoiding
    /// self-capture-before-init. Does **not** call `onEditingChanged`: on the native branch the
    /// `Stepper(label:onIncrement:onDecrement:onEditingChanged:)` fires `onEditingChanged` itself
    /// (once per session), so synthesizing it here would double-fire (`true,true,false,false`);
    /// on the tvOS branch the fallback brackets each press separately.
    private static func step<V: Strideable>(
        _ value: Binding<V>,
        by stride: V.Stride,
        bounds: ClosedRange<V>?
    ) where V: Strideable, V.Stride: Sendable {
        value.wrappedValue = CosmosStepperMath.advance(value.wrappedValue, by: stride, in: bounds)
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "stepper_appear",
            component: "CosmosStepper",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}

// MARK: - Stepping math (pure, testable without rendering)

/// Pure advance/clamp for ``CosmosStepper``. When `bounds` is present, the stride is clamped to
/// the remaining in-bounds distance **before** `advanced(by:)` — so fixed-width `Strideable`
/// types (e.g. `Int`) do not trap on overflow/underflow before the post-clamp could catch it
/// (e.g. `value = Int.max - 1`, `stride = 2`, `bounds = 0...Int.max` clamps the stride to `1`,
/// yielding `Int.max` with no trap). `Sendable`-clean (no `self` capture) so the synthesized init
/// closures stay nonisolated.
public enum CosmosStepperMath {
    public static func advance<V: Strideable>(
        _ value: V,
        by stride: V.Stride,
        in bounds: ClosedRange<V>?
    ) -> V where V: Strideable {
        if let bounds {
            // Clamp the stride into [distance(to: lower), distance(to: upper)] so the result stays
            // within `bounds` and `advanced(by:)` cannot overflow for fixed-width types.
            let toLower = value.distance(to: bounds.lowerBound)
            let toUpper = value.distance(to: bounds.upperBound)
            let clampedStride = min(max(stride, toLower), toUpper)
            return value.advanced(by: clampedStride)
        }
        return value.advanced(by: stride)
    }
}

// MARK: - Convenience inits

extension CosmosStepper where Label == CosmosLocalizedText {
    /// Creates a stepper from a localized String Catalog key with increment/decrement closures.
    public init(
        _ titleKey: String,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.label = { CosmosLocalizedText(key: titleKey) }
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
        self.onEditingChanged = onEditingChanged
    }

    /// Creates a stepper from a localized String Catalog key bound to a `Strideable` value.
    public init<V: Strideable>(
        _ titleKey: String,
        value: Binding<V>,
        step: V.Stride = 1,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: Sendable, V.Stride: Sendable {
        self.label = { CosmosLocalizedText(key: titleKey) }
        self.onEditingChanged = onEditingChanged
        self.onIncrement = { CosmosStepper.step(value, by: step, bounds: nil) }
        self.onDecrement = { CosmosStepper.step(value, by: -step, bounds: nil) }
    }

    /// Creates a stepper from a localized String Catalog key bound to a bounded `Strideable` value.
    public init<V: Strideable & Comparable>(
        _ titleKey: String,
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride = 1,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: Sendable, V.Stride: Sendable {
        self.label = { CosmosLocalizedText(key: titleKey) }
        self.onEditingChanged = onEditingChanged
        self.onIncrement = { CosmosStepper.step(value, by: step, bounds: bounds) }
        self.onDecrement = { CosmosStepper.step(value, by: -step, bounds: bounds) }
    }
}

extension CosmosStepper where Label == Text {
    /// Creates a stepper from verbatim (non-localized) label text bound to a `Strideable` value.
    public init<V: Strideable>(
        verbatim title: String,
        value: Binding<V>,
        step: V.Stride = 1,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: Sendable, V.Stride: Sendable {
        self.label = { Text(verbatim: title) }
        self.onEditingChanged = onEditingChanged
        self.onIncrement = { CosmosStepper.step(value, by: step, bounds: nil) }
        self.onDecrement = { CosmosStepper.step(value, by: -step, bounds: nil) }
    }
}

// MARK: - Previews

#Preview("Stepper – value + bounds") {
    @Previewable @State var count = 5
    @Previewable @State var rating = 3.0
    VStack(spacing: 24) {
        CosmosStepper("preview.title", value: $count, in: 0...10, step: 1)
        CosmosStepper(value: $rating, step: 0.5) { Label("preview.title", systemImage: "star") }
        CosmosStepper(label: { Text("preview.title") }, onIncrement: { count += 2 }, onDecrement: { count -= 2 })
    }
    .padding()
}

#Preview("Stepper – dark + accessibility size", traits: .sizeThatFitsLayout) {
    @Previewable @State var value = 0
    CosmosPreviewContainer {
        VStack(spacing: 24) {
            CosmosStepper(verbatim: CosmosMock.sentence(wordCount: 3), value: $value, step: 1)
                .cosmosControlSize(.small)
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}