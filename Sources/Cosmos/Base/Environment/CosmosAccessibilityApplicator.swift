import SwiftUI

/// Shared internal accessibility-application utilities used by atoms to fold a resolved
/// ``CosmosAccessibilityConfiguration`` into SwiftUI accessibility modifiers, touching only
/// fields that are set.

struct CosmosRespondsModifier: ViewModifier {
    let responds: Bool?
    func body(content: Content) -> some View {
        if let responds { content.accessibilityRespondsToUserInteraction(responds) } else { content }
    }
}

extension View {
    /// Applies the resolved accessibility configuration, merging `extraTraits` and only
    /// touching fields that are set.
    @ViewBuilder
    func applyCosmosAccessibility(
        _ a: CosmosAccessibilityConfiguration,
        extraTraits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabelOrNil(a.label)
            .accessibilityHintOrNil(a.hint)
            .accessibilityValueOrNil(a.value)
            .accessibilityIdentifierOrNil(a.identifier)
            .accessibilitySortPriorityOrNil(a.sortPriority)
            .accessibilityHiddenIf(a.isHidden)
            .accessibilityTraitsIfPresent(a.traits.union(extraTraits))
            .accessibilityCustomContentIfPresent(a.customContent)
            .modifier(CosmosRespondsModifier(responds: a.respondsToUserInteraction))
    }
}