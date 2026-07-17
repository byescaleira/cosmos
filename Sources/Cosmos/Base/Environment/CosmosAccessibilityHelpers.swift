import SwiftUI

/// Internal helpers that apply SwiftUI accessibility modifiers only when an override is
/// present, so an unset value never silences VoiceOver's native fallback. Atoms use these
/// after resolving values from ``CosmosAccessibilityConfiguration``.

extension View {
    @ViewBuilder func accessibilityLabelOrNil(_ label: String?) -> some View {
        if let label { accessibilityLabel(label) } else { self }
    }

    @ViewBuilder func accessibilityHintOrNil(_ hint: String?) -> some View {
        if let hint { accessibilityHint(hint) } else { self }
    }

    @ViewBuilder func accessibilityValueOrNil(_ value: String?) -> some View {
        if let value { accessibilityValue(value) } else { self }
    }

    @ViewBuilder func accessibilityIdentifierOrNil(_ id: String?) -> some View {
        if let id { accessibilityIdentifier(id) } else { self }
    }

    @ViewBuilder func accessibilitySortPriorityOrNil(_ priority: Double?) -> some View {
        if let priority { accessibilitySortPriority(priority) } else { self }
    }

    @ViewBuilder func accessibilityHiddenIf(_ hidden: Bool) -> some View {
        if hidden { accessibilityHidden(true) } else { self }
    }

    @ViewBuilder func accessibilityTraitsIfPresent(_ traits: AccessibilityTraits) -> some View {
        if traits.isEmpty { self } else { accessibilityAddTraits(traits) }
    }

    /// Folds custom content entries into the element, skipping when empty.
    @ViewBuilder func accessibilityCustomContentIfPresent(_ content: [CosmosAccessibilityCustomContent]) -> some View {
        if content.isEmpty {
            self
        } else {
            AnyView(content.reduce(into: AnyView(self)) { acc, item in
                acc = AnyView(acc.accessibilityCustomContent(Text(item.label), Text(item.value ?? "")))
            })
        }
    }
}