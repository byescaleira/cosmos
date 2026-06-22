import Foundation

/// Lightweight logging contract owned by each component.
public struct CosmosLogConfiguration: Sendable {
    public var isEnabled: Bool
    public var category: String
    public var handler: (@Sendable (CosmosLogEvent) -> Void)?

    public init(
        isEnabled: Bool = true,
        category: String = "cosmos",
        handler: (@Sendable (CosmosLogEvent) -> Void)? = nil
    ) {
        self.isEnabled = isEnabled
        self.category = category
        self.handler = handler
    }

    public static let `default` = CosmosLogConfiguration()

    public func log(_ event: CosmosLogEvent) {
        guard isEnabled else { return }
        handler?(event)
    }
}

public struct CosmosLogEvent: Sendable {
    public let level: CosmosLogLevel
    public let message: String
    public let source: String
    public let date: Date

    public init(
        level: CosmosLogLevel,
        message: String,
        source: String,
        date: Date = Date()
    ) {
        self.level = level
        self.message = message
        self.source = source
        self.date = date
    }
}

public enum CosmosLogLevel: String, Sendable {
    case debug, info, warning, error
}
