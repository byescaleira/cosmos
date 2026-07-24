import SwiftUI

/// Modifier that overrides the haptics contract in ``CosmosConfiguration``.
private struct CosmosHapticsModifier: ViewModifier {
    let haptics: CosmosHapticsConfiguration
    @Environment(\.cosmosConfiguration) private var configuration
    func body(content: Content) -> some View {
        content.environment(\.cosmosConfiguration, configuration.withHaptics(haptics))
    }
}

/// Modifier that sets the tracking id (an `@Entry` environment value, not part of the
/// configuration aggregate). Atoms fall back to `accessibilityIdentifier` when nil.
private struct CosmosTrackingIdModifier: ViewModifier {
    let id: String?
    func body(content: Content) -> some View {
        content.environment(\.cosmosTrackingId, id)
    }
}

/// Modifier that overrides the motion contract in ``CosmosConfiguration``.
private struct CosmosMotionConfigModifier: ViewModifier {
    let motion: CosmosMotionConfiguration
    @Environment(\.cosmosConfiguration) private var configuration
    func body(content: Content) -> some View {
        content.environment(\.cosmosConfiguration, configuration.withMotion(motion))
    }
}

/// Convenience modifier for ``View/cosmosReduceMotion(_:)``: flips only
/// ``CosmosMotionConfiguration/respectReduceMotion`` while preserving every sibling field
/// (`isEnabled`, `respectReduceTransparency`, the reduce-motion / reduce-transparency policies,
/// `stagger`, `handler`). Mirrors ``CosmosEnabledModifier``'s read-env → mutate-one-field →
/// reinject-via-``CosmosConfiguration/withMotion(_:)`` shape — does NOT rebuild the config from
/// memberwise defaults (which would silently reset the whole motion contract for the subtree).
private struct CosmosReduceMotionModifier: ViewModifier {
    let respect: Bool
    @Environment(\.cosmosConfiguration) private var configuration
    func body(content: Content) -> some View {
        var motion = configuration.motion
        motion.respectReduceMotion = respect
        return content.environment(\.cosmosConfiguration, configuration.withMotion(motion))
    }
}

extension View {
    /// Overrides the haptics configuration for descendant components.
    public func cosmosHaptics(_ haptics: CosmosHapticsConfiguration) -> some View { modifier(CosmosHapticsModifier(haptics: haptics)) }

    /// Overrides the motion configuration (behavior/policy) for descendant components.
    public func cosmosMotion(_ motion: CosmosMotionConfiguration) -> some View { modifier(CosmosMotionConfigModifier(motion: motion)) }

    /// Convenience: flip just `respectReduceMotion` on a subtree (previews/testing) without
    /// resetting the rest of the motion contract — preserves sibling fields via
    /// ``CosmosReduceMotionModifier``.
    public func cosmosReduceMotion(_ respect: Bool) -> some View { modifier(CosmosReduceMotionModifier(respect: respect)) }

    /// Sets the analytics tracking id for descendant components.
    public func cosmosTrackingId(_ id: String?) -> some View { modifier(CosmosTrackingIdModifier(id: id)) }
}