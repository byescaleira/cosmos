import SwiftUI

// MARK: - Modifiers

private struct CosmosAccessibilityLabelModifier: ViewModifier {
    let label: String?
    @Environment(\.cosmosConfiguration) private var configuration

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosConfiguration, configuration.withAccessibilityLabel(label))
    }
}

private struct CosmosAccessibilityHintModifier: ViewModifier {
    let hint: String?
    @Environment(\.cosmosConfiguration) private var configuration

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosConfiguration, configuration.withAccessibilityHint(hint))
    }
}

private struct CosmosAccessibilityHiddenModifier: ViewModifier {
    let isHidden: Bool
    @Environment(\.cosmosConfiguration) private var configuration

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosConfiguration, configuration.withAccessibilityHidden(isHidden))
    }
}

private struct CosmosAccessibilitySortPriorityModifier: ViewModifier {
    let sortPriority: Double
    @Environment(\.cosmosConfiguration) private var configuration

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosConfiguration, configuration.withAccessibilitySortPriority(sortPriority))
    }
}

// MARK: - View extensions

extension View {
    /// Overrides the accessibility label used by Cosmos components in this subtree.
    ///
    /// A `nil` value leaves the environment label unchanged.
    public func cosmosAccessibilityLabel(_ label: String?) -> some View {
        modifier(CosmosAccessibilityLabelModifier(label: label))
    }

    /// Overrides the accessibility hint used by Cosmos components in this subtree.
    public func cosmosAccessibilityHint(_ hint: String?) -> some View {
        modifier(CosmosAccessibilityHintModifier(hint: hint))
    }

    /// Overrides whether Cosmos components in this subtree are hidden from
    /// accessibility.
    public func cosmosAccessibilityHidden(_ isHidden: Bool) -> some View {
        modifier(CosmosAccessibilityHiddenModifier(isHidden: isHidden))
    }

    /// Overrides the accessibility sort priority used by Cosmos components in
    /// this subtree.
    public func cosmosAccessibilitySortPriority(_ sortPriority: Double) -> some View {
        modifier(CosmosAccessibilitySortPriorityModifier(sortPriority: sortPriority))
    }
}
