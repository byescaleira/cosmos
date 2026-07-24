import SwiftUI

/// Decides whether motion may apply, combining the motion config with the
/// `accessibilityReduceMotion` environment gate. Mirrors ``CosmosHapticsPolicy``.
public enum CosmosMotionPolicy {
    public static func shouldEmit(isEnabled: Bool, respectReduceMotion: Bool, reduceMotion: Bool) -> Bool {
        isEnabled && (!respectReduceMotion || !reduceMotion)
    }

    /// Whether to collapse a material/transparency to a solid token when Reduce Transparency is
    /// active. Config-aware (`respectReduceTransparency` can override to keep materials) and
    /// policy-aware (``CosmosReduceTransparencyPolicy/preserve`` keeps materials even when
    /// reduce-transparency is active and respected; `.substitute` — the default — collapses).
    /// The single chokepoint for reduce-transparency, mirroring ``shouldEmit(isEnabled:respectReduceMotion:reduceMotion:)``.
    public static func shouldCollapseTransparency(
        respectReduceTransparency: Bool,
        reduceTransparency: Bool,
        policy: CosmosReduceTransparencyPolicy
    ) -> Bool {
        reduceTransparency && respectReduceTransparency && policy == .substitute
    }

    /// Picks the transition variant per reduce-motion policy.
    public static func transition(
        full: AnyTransition,
        substitute: AnyTransition = .opacity,
        reduceMotion: Bool,
        policy: CosmosReduceMotionPolicy
    ) -> AnyTransition? {
        guard !reduceMotion || policy == .preserve else {
            return policy == .instant ? .identity : substitute
        }
        return full
    }
}

/// Gated `.animation(_:value:)` — the single chokepoint. `@ViewBuilder` + opaque `some View`
/// preserves structural identity (WWDC21-10022 "Demystify SwiftUI"); `AnyView` would erase it.
private struct CosmosAnimationModifier<V: Equatable & Sendable>: ViewModifier {
    let kind: CosmosMotionKind
    let value: V
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ViewBuilder
    func body(content: Content) -> some View {
        let motion = configuration.motion
        if CosmosMotionPolicy.shouldEmit(
            isEnabled: motion.isEnabled,
            respectReduceMotion: motion.respectReduceMotion,
            reduceMotion: reduceMotion
        ) {
            let animation = theme.motion.animation(
                for: kind, reduceMotion: reduceMotion, policy: motion.reduceMotionPolicy
            )
            content.animation(animation, value: value)
        } else {
            content
        }
    }
}

/// Gated `.transition(_:)`.
private struct CosmosTransitionModifier: ViewModifier {
    let preset: CosmosTransition
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ViewBuilder
    func body(content: Content) -> some View {
        let motion = configuration.motion
        // `BlurReplaceTransition` is a concrete `Transition` (MainActor) that cannot be erased
        // into `AnyTransition`, so it is applied here via the generic `.transition<T>(_:)` View
        // overload. It is vestibular-safe — it has no spatial component (it blurs the outgoing
        // content and resolves the incoming content in place, like an opacity/blur crossfade),
        // so it stays under reduce-motion `.substitute`/`.preserve` (the substitute the HIG
        // recommends), collapsing only under `.instant` (snap to `.identity`). Motion disabled
        // entirely also collapses it. The `body` is MainActor-isolated (ViewModifier
        // requirement), so the MainActor `BlurReplaceTransition(configuration:)` init is
        // reachable here without isolation work.
        let reduceInstant = reduceMotion && motion.reduceMotionPolicy == .instant
        if case .blurReplace = preset, motion.isEnabled, !reduceInstant {
            content.transition(BlurReplaceTransition(configuration: .downUp))
        } else if let resolved = theme.motion.transition(
            preset, reduceMotion: reduceMotion, policy: motion.reduceMotionPolicy
        ) {
            content.transition(resolved)
        } else {
            content
        }
    }
}

/// Gated `.contentTransition(_:)`. Symbol effects (`.symbolReplace`) auto-respect reduce-motion
/// and are gated on `isEnabled` only. Non-symbol presets (`.numeric`/`.contentOpacity`) route
/// through ``CosmosMotionPolicy`` (they do NOT auto-respect reduce-motion).
private struct CosmosContentTransitionModifier: ViewModifier {
    let preset: CosmosContentTransitionPreset
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ViewBuilder
    func body(content: Content) -> some View {
        let motion = configuration.motion
        // Symbol effects auto-respect reduce-motion; gate on isEnabled only (do NOT double-gate).
        let applies = preset.isSymbolEffect
            ? motion.isEnabled
            : CosmosMotionPolicy.shouldEmit(
                isEnabled: motion.isEnabled,
                respectReduceMotion: motion.respectReduceMotion,
                reduceMotion: reduceMotion
            )
        if applies {
            content.contentTransition(preset.contentTransition)
        } else {
            content
        }
    }
}

/// Stagger delay cascade (identical curve, shifted `delay`). Fully implemented — takes an
/// explicit `index` and `value` (a single `ViewModifier` cannot know its list position). A `nil`
/// `step`/`maxSteps` falls back to ``CosmosMotionConfiguration/stagger`` so the cascade base is
/// configurable app-wide without per-call-site repetition.
private struct CosmosStaggerModifier<V: Equatable & Sendable>: ViewModifier {
    let kind: CosmosMotionKind
    let index: Int
    let value: V
    let step: CosmosDuration?
    let maxSteps: Int?
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ViewBuilder
    func body(content: Content) -> some View {
        let motion = configuration.motion
        if CosmosMotionPolicy.shouldEmit(
            isEnabled: motion.isEnabled,
            respectReduceMotion: motion.respectReduceMotion,
            reduceMotion: reduceMotion
        ) {
            let stagger = motion.stagger
            let step = self.step ?? stagger.step
            let maxSteps = self.maxSteps ?? stagger.maxSteps
            let base = theme.motion.animation(
                for: kind, reduceMotion: reduceMotion, policy: motion.reduceMotionPolicy
            )
            let delay = Double(min(index, max(0, maxSteps))) * step.rawValue
            content.animation(base?.delay(delay), value: value)
        } else {
            content
        }
    }
}

extension View {
    /// Gated, token-driven animation. The single chokepoint for reduce-motion.
    public func cosmosAnimation<V: Equatable & Sendable>(_ kind: CosmosMotionKind, value: V) -> some View {
        modifier(CosmosAnimationModifier(kind: kind, value: value))
    }
    /// Gated, token-driven transition.
    public func cosmosTransition(_ preset: CosmosTransition) -> some View {
        modifier(CosmosTransitionModifier(preset: preset))
    }
    /// Gated content transition. Symbol presets gated on isEnabled only; others through policy.
    public func cosmosContentTransition(_ preset: CosmosContentTransitionPreset) -> some View {
        modifier(CosmosContentTransitionModifier(preset: preset))
    }
    /// Stagger delay cascade (identical curve, shifted delay). `index` is the item position.
    /// A `nil` `step`/`maxSteps` (the default) falls back to ``CosmosMotionConfiguration/stagger``,
    /// so the cascade base delay and cap are configurable app-wide.
    public func cosmosStagger<V: Equatable & Sendable>(
        _ kind: CosmosMotionKind,
        index: Int,
        value: V,
        step: CosmosDuration? = nil,
        maxSteps: Int? = nil
    ) -> some View {
        modifier(CosmosStaggerModifier(kind: kind, index: index, value: value, step: step, maxSteps: maxSteps))
    }
}