import Foundation

/// Enablement, visibility, and read-only defaults for Cosmos components.
///
/// Components combine these global values with their own local overrides to
/// compute an effective state. For example, a button is only enabled when both
/// the global `isEnabled` flag and the local override are `true`.
public struct CosmosEnableConfiguration: Sendable, Equatable {
    /// Whether components are globally interactive.
    public var isEnabled: Bool

    /// Whether components are globally visible.
    public var isVisible: Bool

    /// Whether components are globally read-only.
    public var isReadOnly: Bool

    /// Creates an enablement configuration.
    public init(
        isEnabled: Bool = true,
        isVisible: Bool = true,
        isReadOnly: Bool = false
    ) {
        self.isEnabled = isEnabled
        self.isVisible = isVisible
        self.isReadOnly = isReadOnly
    }

    /// The default enablement configuration.
    public static let `default` = CosmosEnableConfiguration()
}
