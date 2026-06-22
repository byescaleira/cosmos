import Foundation

/// Runtime registry that maps action identifiers to handlers.
///
/// `CosmosActionRegistry` is injected into `CosmosScreenRenderer`. It keeps the
/// screen model serializable (only identifiers) while allowing the host app
/// to provide real closures at runtime.
public struct CosmosActionRegistry: Sendable {
    private let handlers: [String: @Sendable () throws -> Void]

    /// Creates a registry with a dictionary of action handlers.
    public init(handlers: [String: @Sendable () throws -> Void] = [:]) {
        self.handlers = handlers
    }

    /// Executes the handler for the given identifier, if one exists.
    public func handle(_ id: String) throws {
        try handlers[id]?()
    }
}
