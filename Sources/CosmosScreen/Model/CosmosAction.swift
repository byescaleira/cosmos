import Foundation

/// Reference to an action that can be triggered by interactive components.
///
/// Actions are closures and cannot be encoded. The data model carries only an
/// identifier; the host app provides the actual handler through
/// `CosmosActionRegistry` when rendering.
public struct CosmosAction: Sendable, Codable, Equatable {
    /// The identifier used to look up the handler in the registry.
    public let id: String

    /// Creates an action reference.
    public init(id: String) {
        self.id = id
    }
}
