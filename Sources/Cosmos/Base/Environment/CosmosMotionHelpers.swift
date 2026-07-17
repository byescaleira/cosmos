import SwiftUI

/// Decides whether motion may apply, combining the motion config with the
/// `accessibilityReduceMotion` environment gate. Mirrors ``CosmosHapticsPolicy``.
public enum CosmosMotionPolicy {
    public static func shouldEmit(isEnabled: Bool, respectReduceMotion: Bool, reduceMotion: Bool) -> Bool {
        isEnabled && (!respectReduceMotion || !reduceMotion)
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

/// Gated `.animation(_:value:)` — the single chokepoint. Uses `AnyView` early-return to match
/// the existing ``CosmosHapticFeedbackModifier`` pattern (consistency).
private struct CosmosAnimationModifier<V: Equatable & Sendable>: ViewModifier {
    let kind: CosmosMotionKind
    let value: V
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let motion = configuration.motion
        guard CosmosMotionPolicy.shouldEmit(
            isEnabled: motion.isEnabled,
            respectReduceMotion: motion.respectReduceMotion,
            reduceMotion: reduceMotion
        ) else { return AnyView(content) }
        let animation = theme.motion.animation(
            for: kind, reduceMotion: reduceMotion, policy: motion.reduceMotionPolicy
        )
        return AnyView(content.animation(animation, value: value))
    }
}

/// Gated `.transition(_:)`.
private struct CosmosTransitionModifier: ViewModifier {
    let preset: CosmosTransition
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let motion = configuration.motion
        let shouldReduce = reduceMotion && motion.reduceMotionPolicy != .preserve
        // `BlurReplaceTransition` is a concrete `Transition` (MainActor) that cannot be erased
        // into `AnyTransition`, so it is applied here via the generic `.transition<T>(_:)` View
        // overload when motion is fully on. Under reduce-motion it falls through to the
        // `AnyTransition` substitute (`.opacity`/`.identity`) returned by `resolved()`.
        // The `body` is MainActor-isolated (ViewModifier requirement), so the MainActor
        // `BlurReplaceTransition(configuration:)` init is reachable here without isolation work.
        if case .blurReplace = preset, !shouldReduce {
            return AnyView(content.transition(BlurReplaceTransition(configuration: .downUp)))
        }
        let resolved = theme.motion.transition(
            preset, reduceMotion: reduceMotion, policy: motion.reduceMotionPolicy
        )
        if let resolved { return AnyView(content.transition(resolved)) }
        return AnyView(content)
    }
}

/// Gated `.contentTransition(_:)`. Symbol effects (`.symbolReplace`) auto-respect reduce-motion
/// and are gated on `isEnabled` only. Non-symbol presets (`.numeric`/`.contentOpacity`) route
/// through ``CosmosMotionPolicy`` (they do NOT auto-respect reduce-motion).
private struct CosmosContentTransitionModifier: ViewModifier {
    let preset: CosmosContentTransitionPreset
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let motion = configuration.motion
        let applies: Bool
        if preset.isSymbolEffect {
            // Symbol effects auto-respect reduce-motion; gate on isEnabled only (do NOT double-gate).
            applies = motion.isEnabled
        } else {
            applies = CosmosMotionPolicy.shouldEmit(
                isEnabled: motion.isEnabled,
                respectReduceMotion: motion.respectReduceMotion,
                reduceMotion: reduceMotion
            )
        }
        guard applies else { return AnyView(content) }
        return AnyView(content.contentTransition(preset.contentTransition))
    }
}

/// Stagger delay cascade (identical curve, shifted `delay`). Fully implemented — takes an
/// explicit `index` and `value` (a single `ViewModifier` cannot know its list position).
private struct CosmosStaggerModifier<V: Equatable & Sendable>: ViewModifier {
    let kind: CosmosMotionKind
    let index: Int
    let value: V
    let step: CosmosDuration
    let maxSteps: Int
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let motion = configuration.motion
        guard CosmosMotionPolicy.shouldEmit(
            isEnabled: motion.isEnabled,
            respectReduceMotion: motion.respectReduceMotion,
            reduceMotion: reduceMotion
        ) else { return AnyView(content) }
        let base = theme.motion.animation(
            for: kind, reduceMotion: reduceMotion, policy: motion.reduceMotionPolicy
        )
        let delay = Double(min(index, max(0, maxSteps))) * step.rawValue
        return AnyView(content.animation(base?.delay(delay), value: value))
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
    public func cosmosStagger<V: Equatable & Sendable>(
        _ kind: CosmosMotionKind,
        index: Int,
        value: V,
        step: CosmosDuration = .moderate1,
        maxSteps: Int = 3
    ) -> some View {
        modifier(CosmosStaggerModifier(kind: kind, index: index, value: value, step: step, maxSteps: maxSteps))
    }
}