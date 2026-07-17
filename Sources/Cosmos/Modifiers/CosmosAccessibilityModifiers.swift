import SwiftUI

/// Modifiers that override individual accessibility fields in ``CosmosConfiguration``.
/// Each preserves the other fields and re-injects the mutated configuration.

private struct CosmosAccessibilityModifier: ViewModifier {
    var label: String?? = nil       // double-optional: nil = untouched, .some(nil) = cleared, .some(.some) = set
    var hint: String?? = nil
    var value: String?? = nil
    var identifier: String?? = nil
    var traits: AccessibilityTraits? = nil
    var isHidden: Bool? = nil
    var sortPriority: Double?? = nil
    var customContent: [CosmosAccessibilityCustomContent]? = nil
    var respondsToUserInteraction: Bool?? = nil

    @Environment(\.cosmosConfiguration) private var configuration

    func body(content: Content) -> some View {
        var a = configuration.accessibility
        if case .some(let v) = label { a.label = v }
        if case .some(let v) = hint { a.hint = v }
        if case .some(let v) = value { a.value = v }
        if case .some(let v) = identifier { a.identifier = v }
        if let v = traits { a.traits = v }
        if let v = isHidden { a.isHidden = v }
        if case .some(let v) = sortPriority { a.sortPriority = v }
        if let v = customContent { a.customContent = v }
        if case .some(let v) = respondsToUserInteraction { a.respondsToUserInteraction = v }
        return content.environment(\.cosmosConfiguration, configuration.withAccessibility(a))
    }
}

extension View {
    private func _accessibility(modify: (inout CosmosAccessibilityModifier) -> Void) -> some View {
        var m = CosmosAccessibilityModifier()
        modify(&m)
        return modifier(m)
    }

    public func cosmosAccessibilityLabel(_ label: String?) -> some View { _accessibility { $0.label = .some(label) } }
    public func cosmosAccessibilityHint(_ hint: String?) -> some View { _accessibility { $0.hint = .some(hint) } }
    public func cosmosAccessibilityValue(_ value: String?) -> some View { _accessibility { $0.value = .some(value) } }
    public func cosmosAccessibilityIdentifier(_ id: String?) -> some View { _accessibility { $0.identifier = .some(id) } }
    public func cosmosAccessibilityTraits(_ traits: AccessibilityTraits) -> some View { _accessibility { $0.traits = traits } }
    public func cosmosAccessibilityHidden(_ hidden: Bool) -> some View { _accessibility { $0.isHidden = hidden } }
    public func cosmosAccessibilitySortPriority(_ priority: Double) -> some View { _accessibility { $0.sortPriority = .some(priority) } }
    public func cosmosAccessibilityCustomContent(_ content: [CosmosAccessibilityCustomContent]) -> some View { _accessibility { $0.customContent = content } }
    public func cosmosAccessibilityRespondsToUserInteraction(_ responds: Bool) -> some View { _accessibility { $0.respondsToUserInteraction = .some(responds) } }
}