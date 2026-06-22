import SwiftUI

// MARK: - Modifiers

private struct CosmosEnabledModifier: ViewModifier {
    let isEnabled: Bool
    @Environment(\.cosmosConfiguration) private var configuration

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosConfiguration, configuration.withEnabled(isEnabled))
    }
}

private struct CosmosVisibleModifier: ViewModifier {
    let isVisible: Bool
    @Environment(\.cosmosConfiguration) private var configuration

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosConfiguration, configuration.withVisible(isVisible))
    }
}

private struct CosmosReadOnlyModifier: ViewModifier {
    let isReadOnly: Bool
    @Environment(\.cosmosConfiguration) private var configuration

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosConfiguration, configuration.withReadOnly(isReadOnly))
    }
}

private struct CosmosLoadingModifier: ViewModifier {
    let isLoading: Bool
    @Environment(\.cosmosConfiguration) private var configuration

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosConfiguration, configuration.withLoading(isLoading))
    }
}

private struct CosmosRedactedModifier: ViewModifier {
    let isRedacted: Bool
    @Environment(\.cosmosConfiguration) private var configuration

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosConfiguration, configuration.withRedacted(isRedacted))
    }
}

// MARK: - View extensions

extension View {
    /// Overrides whether Cosmos components in this subtree are enabled.
    ///
    /// The modifier reads the current `cosmosConfiguration` from the environment,
    /// replaces the enabled flag, and re-injects the value so child components
    /// see the merged configuration.
    public func cosmosEnabled(_ isEnabled: Bool) -> some View {
        modifier(CosmosEnabledModifier(isEnabled: isEnabled))
    }

    /// Overrides whether Cosmos components in this subtree are visible.
    public func cosmosVisible(_ isVisible: Bool) -> some View {
        modifier(CosmosVisibleModifier(isVisible: isVisible))
    }

    /// Overrides whether Cosmos components in this subtree are read-only.
    public func cosmosReadOnly(_ isReadOnly: Bool) -> some View {
        modifier(CosmosReadOnlyModifier(isReadOnly: isReadOnly))
    }

    /// Overrides whether Cosmos components in this subtree are loading.
    public func cosmosLoading(_ isLoading: Bool) -> some View {
        modifier(CosmosLoadingModifier(isLoading: isLoading))
    }

    /// Overrides whether Cosmos components in this subtree render placeholder
    /// redactions.
    @available(iOS 14, macOS 11, tvOS 14, watchOS 7, visionOS 1, *)
    public func cosmosRedacted(_ isRedacted: Bool) -> some View {
        modifier(CosmosRedactedModifier(isRedacted: isRedacted))
    }
}
