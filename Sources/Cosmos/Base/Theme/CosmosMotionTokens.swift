import SwiftUI
import CoreGraphics

/// Canonical Cosmos spring presets. Wraps SwiftUI `Spring` (`Hashable & Sendable`, available
/// unconditionally at the Cosmos 26 baseline on all 5 platforms).
public struct CosmosSpring: Hashable, Sendable {
    public let spring: Spring
    public init(_ spring: Spring) { self.spring = spring }
    public init(duration: TimeInterval, bounce: Double = 0.0) {
        self.spring = Spring(duration: duration, bounce: bounce)
    }
    /// Legacy `Spring(response:dampingFraction:)` form. Prefer ``init(duration:bounce:)`` — the
    /// modern `Spring(duration:bounce:)` form (WWDC23-10158), which all other Cosmos presets use.
    /// `dampingFraction` maps to `bounce` via `bounce = 1 - dampingFraction²`; `response` ≈
    /// `duration` for moderate bounce. Deprecated with a migration runway (kept for the 26 minor;
    /// obsoletion in a later major, per VERSIONING.md).
    @available(*, deprecated, message: "Use init(duration:bounce:); bounce = 1 - dampingFraction²")
    public init(response: Double, dampingRatio: Double) {
        self.spring = Spring(duration: response, bounce: 1 - dampingRatio * dampingRatio)
    }
    /// The `Animation` for this spring (via `Animation.spring(_:blendDuration:)`).
    public var animation: Animation { Animation.spring(spring) }

    // SE-0299 dot-syntax statics (where Self == …)
    /// Calm, no overshoot — default state changes, sheet expansion.
    public static let cosmosSmooth: CosmosSpring = .init(duration: 0.4, bounce: 0.0)
    /// Brisk, slightly lively — press, value changes, focus.
    public static let cosmosSnappy: CosmosSpring = .init(duration: 0.3, bounce: 0.15)
    /// Playful — play/pause, delight.
    public static let cosmosBouncy: CosmosSpring = .init(duration: 0.35, bounce: 0.3)
    /// Slow, soft — large container transforms, visionOS-safe relocation.
    public static let cosmosGentle: CosmosSpring = .init(duration: 0.6, bounce: 0.0)
    /// Velocity-preserving — gestures, drag, slider/stepper thumb. The modern
    /// `Spring(duration:bounce:)` form (WWDC23-10158); the legacy `init(response:dampingRatio:)`
    /// is the deprecated escape hatch kept for the 26 minor.
    public static let cosmosInteractive: CosmosSpring = .init(duration: 0.3, bounce: 0.3)
}

/// Default spring selector (parallels ``CosmosButtonStyle``), with SE-0299 dot-syntax.
public enum CosmosSpringStyle: String, Sendable, Codable, CaseIterable {
    case smooth, snappy, bouncy, gentle, interactive
    public var spring: CosmosSpring {
        switch self {
        case .smooth: return .cosmosSmooth
        case .snappy: return .cosmosSnappy
        case .bouncy: return .cosmosBouncy
        case .gentle: return .cosmosGentle
        case .interactive: return .cosmosInteractive
        }
    }
}

/// Tiered duration scale (Carbon-hybrid). Pure enum — cases only, no same-named `static let`
/// constants (those would redeclare the cases). The value is exposed solely via `rawValue`.
/// Equatable/Hashable are auto-synthesized (cases without associated values).
public enum CosmosDuration: Sendable, Equatable, Hashable, CaseIterable {
    case instant, fast1, fast2, moderate1, moderate2, long, extraLong

    public var rawValue: TimeInterval {
        switch self {
        case .instant: return 0
        case .fast1: return 0.070
        case .fast2: return 0.110
        case .moderate1: return 0.150
        case .moderate2: return 0.240
        case .long: return 0.400
        case .extraLong: return 0.700
        }
    }
    /// `.instant` has rawValue 0 → `.linear(duration: 0)` is a valid no-op; no special case.
    public var linear: Animation { .linear(duration: rawValue) }
    public var easeInOut: Animation { .easeInOut(duration: rawValue) }
}

/// Transition presets. `indirect` is required: `asymmetric` references the enum recursively.
/// Not `CaseIterable` (the `asymmetric` associated values break it); use `presets` for matrices.
public indirect enum CosmosTransition: Sendable {
    case fade, slide, scale, push, blurReplace
    case sheet           // .move(.bottom) + .opacity
    case listInsert      // asymmetric: insert moderate1+ease-out, remove fast2+ease-in
    case listRemove      // asymmetric: insert fast2+ease-out, remove moderate1+ease-in
    case focus           // scale + opacity
    case tabSwitch       // fade-through (opacity)
    case asymmetric(insertion: CosmosTransition, removal: CosmosTransition)

    /// Preview/iteration matrix (no associated-value cases).
    public static let presets: [CosmosTransition] = [
        .fade, .slide, .scale, .push, .blurReplace,
        .sheet, .listInsert, .listRemove, .focus, .tabSwitch
    ]

    /// Resolves to an `AnyTransition` (or `nil`/`.identity` under reduce-motion per policy).
    /// Fully implemented — no `fatalError`.
    ///
    /// `@MainActor` because `AnyTransition.blurReplace` is MainActor-isolated in the SDK; this
    /// resolver is only ever invoked from `ViewModifier` bodies (MainActor) at render time.
    @MainActor
    public func resolved(
        reduceMotion: Bool,
        policy: CosmosReduceMotionPolicy,
        tokens: CosmosMotionTokens
    ) -> AnyTransition? {
        // Reduce-motion: substitute → opacity crossfade; instant → identity; preserve → full.
        guard !reduceMotion || policy == .preserve else {
            return policy == .instant ? .identity : .opacity
        }
        switch self {
        case .fade:
            return .opacity
        case .slide:
            return .move(edge: .top).combined(with: .opacity)
        case .scale:
            return .scale.combined(with: .opacity)
        case .push:
            return .move(edge: .trailing).combined(with: .opacity)
        case .blurReplace:
            // `BlurReplaceTransition` is a concrete `Transition` (MainActor-isolated) with no
            // public erasing init into `AnyTransition` — its `.blurReplace` static lives on
            // `Transition where Self == BlurReplaceTransition`, so it cannot resolve against
            // `AnyTransition`. Returning `nil` here is a sentinel: ``CosmosTransitionModifier``
            // applies the concrete transition via the generic `.transition<T>(_:)` View overload.
            // (The reduce-motion guard above already returned `.opacity`/`.identity` for this
            // case when motion is reduced, so reaching here means motion is fully on.)
            return nil
        case .sheet:
            return .move(edge: .bottom).combined(with: .opacity)
        case .listInsert:
            return .asymmetric(
                insertion: .move(edge: .top)
                    .combined(with: .opacity)
                    .animation(.easeOut(duration: CosmosDuration.moderate1.rawValue)),
                removal: .opacity
                    .animation(.easeIn(duration: CosmosDuration.fast2.rawValue))
            )
        case .listRemove:
            return .asymmetric(
                insertion: .opacity
                    .animation(.easeOut(duration: CosmosDuration.fast2.rawValue)),
                removal: .move(edge: .bottom)
                    .combined(with: .opacity)
                    .animation(.easeIn(duration: CosmosDuration.moderate1.rawValue))
            )
        case .focus:
            return .scale(scale: 0.96).combined(with: .opacity)
        case .tabSwitch:
            return .opacity
        case .asymmetric(let insertion, let removal):
            let i = insertion.resolved(reduceMotion: reduceMotion, policy: policy, tokens: tokens) ?? .opacity
            let r = removal.resolved(reduceMotion: reduceMotion, policy: policy, tokens: tokens) ?? .opacity
            return .asymmetric(insertion: i, removal: r)
        }
    }
}

/// Content-transition presets (wraps `ContentTransition`). `.numeric`/`.contentOpacity` are
/// NOT symbol effects and do NOT auto-respect reduce-motion — the modifier routes them through
/// ``CosmosMotionPolicy``; only `.symbolReplace` is gated on `isEnabled` alone.
public enum CosmosContentTransitionPreset: Sendable, CaseIterable {
    case numeric          // .numericText()
    case symbolReplace    // .symbolEffect(.replace) — symbol effects auto-respect reduce-motion
    case contentOpacity   // .opacity
    case identity         // .identity
    public var contentTransition: ContentTransition {
        switch self {
        case .numeric: return .numericText()
        case .symbolReplace: return .symbolEffect(.replace)
        case .contentOpacity: return .opacity
        case .identity: return .identity
        }
    }
    /// True if this preset is a symbol effect that auto-respects reduce-motion.
    public var isSymbolEffect: Bool { self == .symbolReplace }
}

/// Semantic motion tokens (visual). The single source of truth for spring curves, durations,
/// and transition presets. Mirrors ``CosmosTypographyTokens``. Behavior/policy lives in
/// ``CosmosMotionConfiguration`` (inside ``CosmosConfiguration``); only token values live here.
public struct CosmosMotionTokens: Sendable {
    /// Global default spring style.
    public var defaultSpringStyle: CosmosSpringStyle
    /// Shadow radius used by container atoms (gated by reduce-motion/reduce-transparency).
    public var shadowRadius: CGFloat
    /// Shadow opacity used by container atoms.
    public var shadowOpacity: Double

    public init(
        defaultSpringStyle: CosmosSpringStyle = .snappy,
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.08
    ) {
        self.defaultSpringStyle = defaultSpringStyle
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
    }

    public static let `default` = CosmosMotionTokens()

    /// Resolves a `CosmosSpring` for a style.
    public func spring(for style: CosmosSpringStyle) -> CosmosSpring { style.spring }

    /// The global default spring.
    public var defaultSpring: CosmosSpring { spring(for: defaultSpringStyle) }

    /// The single resolver: intent → preset → `Animation?`. Every component animating the same
    /// intent lands on the identical curve — the synchronization guarantee.
    /// Fully implemented — no `fatalError`.
    public func animation(
        for kind: CosmosMotionKind,
        reduceMotion: Bool,
        policy: CosmosReduceMotionPolicy
    ) -> Animation? {
        // Reduce-motion: instant → nil (snap); substitute → short easeInOut (opacity crossfade).
        if reduceMotion && policy != .preserve {
            return policy == .instant ? nil : .easeInOut(duration: CosmosDuration.fast2.rawValue)
        }
        let preset: CosmosSpring
        switch kind {
        case .press, .valueChange, .focus, .listRemove:
            preset = .cosmosSnappy
        case .appear, .disappear, .tabSwitch, .listInsert:
            preset = .cosmosSmooth
        case .sheet, .containerTransform:
            preset = .cosmosGentle
        }
        return preset.animation
    }

    /// Resolves a `CosmosTransition` preset through the policy. `@MainActor` (see
    /// ``CosmosTransition/resolved(reduceMotion:policy:tokens:)``).
    @MainActor
    public func transition(
        _ preset: CosmosTransition,
        reduceMotion: Bool,
        policy: CosmosReduceMotionPolicy
    ) -> AnyTransition? {
        preset.resolved(reduceMotion: reduceMotion, policy: policy, tokens: self)
    }
}

/// Example custom transition demonstrating `static var properties` (the protocol requirement is
/// static; an instance var does not satisfy it and the auto-substitution is silently lost). Uses
/// the protocol's `Content` typealias (not `some View`) and a single unified ternary so all
/// branches share one underlying opaque type.
public struct CosmosScaleFadeTransition: Transition {
    public init() {}
    public static var properties: TransitionProperties { .init(hasMotion: true) }
    @ViewBuilder
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .scaleEffect(phase == .willAppear ? 0.92 : (phase == .didDisappear ? 1.08 : 1.0))
            .opacity(phase.isIdentity ? 1.0 : 0.0)
    }
}