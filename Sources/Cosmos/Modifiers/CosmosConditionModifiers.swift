import SwiftUI

/// Modifiers that override the enable/visibility/read-only and loading contracts in
/// ``CosmosConfiguration``. Each reads the current configuration from the environment,
/// mutates a copy, and re-injects it so descendant atoms pick up the override.

private struct CosmosEnabledModifier: ViewModifier {
    let isEnabled: Bool
    @Environment(\.cosmosConfiguration) private var configuration
    func body(content: Content) -> some View {
        content.environment(\.cosmosConfiguration, configuration.withEnable(
            .init(isEnabled: isEnabled, isVisible: configuration.enable.isVisible, isReadOnly: configuration.enable.isReadOnly)
        ))
    }
}

private struct CosmosVisibleModifier: ViewModifier {
    let isVisible: Bool
    @Environment(\.cosmosConfiguration) private var configuration
    func body(content: Content) -> some View {
        content.environment(\.cosmosConfiguration, configuration.withEnable(
            .init(isEnabled: configuration.enable.isEnabled, isVisible: isVisible, isReadOnly: configuration.enable.isReadOnly)
        ))
    }
}

private struct CosmosReadOnlyModifier: ViewModifier {
    let isReadOnly: Bool
    @Environment(\.cosmosConfiguration) private var configuration
    func body(content: Content) -> some View {
        content.environment(\.cosmosConfiguration, configuration.withEnable(
            .init(isEnabled: configuration.enable.isEnabled, isVisible: configuration.enable.isVisible, isReadOnly: isReadOnly)
        ))
    }
}

private struct CosmosLoadingModifier: ViewModifier {
    let isLoading: Bool
    @Environment(\.cosmosConfiguration) private var configuration
    func body(content: Content) -> some View {
        content.environment(\.cosmosConfiguration, configuration.withLoading(
            .init(isLoading: isLoading, minimumDisplayTime: configuration.loading.minimumDisplayTime, delay: configuration.loading.delay)
        ))
    }
}

extension View {
    /// Overrides the enabled state for descendant components.
    public func cosmosEnabled(_ isEnabled: Bool) -> some View { modifier(CosmosEnabledModifier(isEnabled: isEnabled)) }
    /// Overrides the visibility for descendant components (invisible ones are not rendered).
    public func cosmosVisible(_ isVisible: Bool) -> some View { modifier(CosmosVisibleModifier(isVisible: isVisible)) }
    /// Overrides the read-only state for descendant inputs.
    public func cosmosReadOnly(_ isReadOnly: Bool) -> some View { modifier(CosmosReadOnlyModifier(isReadOnly: isReadOnly)) }
    /// Overrides the loading state for descendant components.
    public func cosmosLoading(_ isLoading: Bool) -> some View { modifier(CosmosLoadingModifier(isLoading: isLoading)) }
}