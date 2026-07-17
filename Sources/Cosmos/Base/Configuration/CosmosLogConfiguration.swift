import Foundation

/// Log severity levels.
public enum CosmosLogLevel: String, Sendable, Codable, CaseIterable {
    case debug
    case info
    case warning
    case error
}

/// A log event delivered to ``CosmosLogConfiguration/handler``.
public struct CosmosLogEvent: Sendable {
    public var category: String
    public var level: CosmosLogLevel
    public var message: String
    public var date: Date

    public init(category: String, level: CosmosLogLevel, message: String, date: Date = Date()) {
        self.category = category
        self.level = level
        self.message = message
        self.date = date
    }
}

/// Logging contract.
///
/// `handler` is `@Sendable` (SE-0302): it may be invoked across actor boundaries, so it must
/// capture only by-value `Sendable` state. When `isEnabled == false`, atoms skip logging.
public struct CosmosLogConfiguration: Sendable {
    public var isEnabled: Bool
    public var category: String
    public var handler: @Sendable (CosmosLogEvent) -> Void

    public init(isEnabled: Bool = true, category: String = "Cosmos", handler: @escaping @Sendable (CosmosLogEvent) -> Void = { _ in }) {
        self.isEnabled = isEnabled
        self.category = category
        self.handler = handler
    }

    public static let `default` = CosmosLogConfiguration()

    /// Emits a log event if enabled.
    public func log(_ level: CosmosLogLevel, _ message: String) {
        guard isEnabled else { return }
        handler(.init(category: category, level: level, message: message))
    }
}