import Foundation

/// Motion intent vocabulary (the single declaration site; referenced by the tokens file).
///
/// Atoms never pick a raw `Animation`; they declare the *intent* (`.press`, `.appear`, …) and
/// ``CosmosMotionTokens/animation(for:reduceMotion:policy:)`` resolves it to the canonical
/// spring. Every component animating the same intent lands on the identical curve — the
/// synchronization guarantee.
public enum CosmosMotionKind: String, Sendable, Codable, CaseIterable {
    case press, appear, disappear, valueChange, tabSwitch
    case sheet, focus, containerTransform, listInsert, listRemove
}

/// A motion emission, for tracking when a motion fires.
///
/// Callers write `.motion(.press)` via the synthesized case constructor. There is deliberately
/// no `static func motion(_:)` — it would conflict with the synthesized case constructor of
/// identical signature.
public enum CosmosMotionEvent: Sendable {
    case motion(CosmosMotionKind)
}

/// What to do when `accessibilityReduceMotion` is active.
public enum CosmosReduceMotionPolicy: String, Sendable, Codable, CaseIterable {
    /// Spatial motion → opacity crossfade (vestibular-safe, keeps feedback). Default.
    case substitute
    /// Snap to final state with no transition (decorative reveals).
    case instant
    /// Keep the motion (only when it is the sole state signal — WCAG 2.3.3 exempt).
    case preserve
}

/// What to do when `accessibilityReduceTransparency` is active.
public enum CosmosReduceTransparencyPolicy: String, Sendable, Codable, CaseIterable {
    /// Collapse materials/shadows to solid tokens. Default.
    case substitute
    /// Keep materials/shadows.
    case preserve
}

/// Stagger configuration for delay cascades.
public struct CosmosStaggerConfig: Sendable {
    public var step: CosmosDuration
    public var maxSteps: Int
    public init(step: CosmosDuration = .moderate1, maxSteps: Int = 3) {
        self.step = step
        self.maxSteps = maxSteps
    }
    public static let `default` = CosmosStaggerConfig()
}

/// Motion behavior contract (the 9th cross-cutting contract).
///
/// Mirrors the haptics contract shape and extends it with reduce-motion policy,
/// reduce-transparency policy, and stagger config (haptics has none of these). Atoms apply
/// `.cosmosAnimation`/`.cosmosTransition`/`.cosmosContentTransition`/`.cosmosStagger` gated by
/// `isEnabled` and `respectReduceMotion`, resolving the concrete `Animation`/`AnyTransition`
/// from ``CosmosMotionTokens`` in ``CosmosTheme``. `handler` is `@Sendable` and is invoked *in
/// addition to* the visual motion when it fires, so consumers can track motion usage.
/// Passive by default (handler no-op).
public struct CosmosMotionConfiguration: Sendable {
    /// Whether motion may apply at all (global kill switch for testing/screenshots).
    public var isEnabled: Bool
    /// When true, suppresses/adapts motion if `accessibilityReduceMotion` is active.
    public var respectReduceMotion: Bool
    /// How to adapt motion when reduce-motion is active and respected.
    public var reduceMotionPolicy: CosmosReduceMotionPolicy
    /// When true, collapses materials/shadows if `accessibilityReduceTransparency` is active.
    public var respectReduceTransparency: Bool
    /// How to adapt transparency when reduce-transparency is active and respected.
    public var reduceTransparencyPolicy: CosmosReduceTransparencyPolicy
    /// Stagger base delay step + cap (for `.cosmosStagger`).
    public var stagger: CosmosStaggerConfig
    /// Invoked when a motion fires (for tracking). `@Sendable` (SE-0302).
    public var handler: @Sendable (CosmosMotionEvent) -> Void

    public init(
        isEnabled: Bool = true,
        respectReduceMotion: Bool = true,
        reduceMotionPolicy: CosmosReduceMotionPolicy = .substitute,
        respectReduceTransparency: Bool = true,
        reduceTransparencyPolicy: CosmosReduceTransparencyPolicy = .substitute,
        stagger: CosmosStaggerConfig = .default,
        handler: @escaping @Sendable (CosmosMotionEvent) -> Void = { _ in }
    ) {
        self.isEnabled = isEnabled
        self.respectReduceMotion = respectReduceMotion
        self.reduceMotionPolicy = reduceMotionPolicy
        self.respectReduceTransparency = respectReduceTransparency
        self.reduceTransparencyPolicy = reduceTransparencyPolicy
        self.stagger = stagger
        self.handler = handler
    }

    public static let `default` = CosmosMotionConfiguration()
}