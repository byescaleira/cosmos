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

extension View {
    /// Overrides the haptics configuration for descendant components.
    public func cosmosHaptics(_ haptics: CosmosHapticsConfiguration) -> some View { modifier(CosmosHapticsModifier(haptics: haptics)) }

    /// Overrides the motion configuration (behavior/policy) for descendant components.
    public func cosmosMotion(_ motion: CosmosMotionConfiguration) -> some View { modifier(CosmosMotionConfigModifier(motion: motion)) }

    /// Convenience: flip just `respectReduceMotion` on a subtree (previews/testing).
    public func cosmosReduceMotion(_ respect: Bool) -> some View { cosmosMotion(.init(respectReduceMotion: respect)) }

    /// Sets the analytics tracking id for descendant components.
    public func cosmosTrackingId(_ id: String?) -> some View { modifier(CosmosTrackingIdModifier(id: id)) }
}