import Foundation

/// Error handling contract owned by each component.
public struct CosmosErrorConfiguration: Sendable {
    public var handler: (@Sendable (CosmosErrorEvent) -> Void)?

    public init(handler: (@Sendable (CosmosErrorEvent) -> Void)? = nil) {
        self.handler = handler
    }

    public static let `default` = CosmosErrorConfiguration()

    public func report(
        _ error: Error,
        source: String,
        metadata: [String: String] = [:]
    ) {
        handler?(
            CosmosErrorEvent(
                error: error,
                source: source,
                metadata: metadata,
                date: Date()
            )
        )
    }
}

public struct CosmosErrorEvent: Sendable {
    public let error: Error
    public let source: String
    public let metadata: [String: String]
    public let date: Date

    public init(
        error: Error,
        source: String,
        metadata: [String: String],
        date: Date
    ) {
        self.error = error
        self.source = source
        self.metadata = metadata
        self.date = date
    }
}
