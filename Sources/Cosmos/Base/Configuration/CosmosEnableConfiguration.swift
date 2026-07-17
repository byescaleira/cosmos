import Foundation

/// Enablement / visibility / read-only contract.
///
/// Atoms derive an "effective enabled" state from `isEnabled` (combined with loading and
/// read-only where relevant) and short-circuit rendering when `isVisible == false`.
/// All value types → `Sendable` (SE-0302).
public struct CosmosEnableConfiguration: Sendable {
    /// Whether the component accepts interaction.
    public var isEnabled: Bool
    /// Whether the component is rendered at all.
    public var isVisible: Bool
    /// Whether the component is shown but non-editable (inputs).
    public var isReadOnly: Bool

    public init(isEnabled: Bool = true, isVisible: Bool = true, isReadOnly: Bool = false) {
        self.isEnabled = isEnabled
        self.isVisible = isVisible
        self.isReadOnly = isReadOnly
    }

    public static let `default` = CosmosEnableConfiguration()
}