import SwiftUI

/// Accessibility defaults for Cosmos components.
///
/// Components merge these global values with any local overrides passed in
/// their initializers. The local value wins when both are present.
public struct CosmosAccessibilityConfiguration: Sendable, Equatable {
    /// Default accessibility label.
    public var label: String?

    /// Default accessibility hint.
    public var hint: String?

    /// Default accessibility traits.
    public var traits: AccessibilityTraits?

    /// Whether components are hidden from accessibility by default.
    public var isHidden: Bool

    /// Default accessibility sort priority.
    public var sortPriority: Double

    /// Creates an accessibility configuration.
    public init(
        label: String? = nil,
        hint: String? = nil,
        traits: AccessibilityTraits? = nil,
        isHidden: Bool = false,
        sortPriority: Double = 0
    ) {
        self.label = label
        self.hint = hint
        self.traits = traits
        self.isHidden = isHidden
        self.sortPriority = sortPriority
    }

    /// The default accessibility configuration.
    public static let `default` = CosmosAccessibilityConfiguration()
}
