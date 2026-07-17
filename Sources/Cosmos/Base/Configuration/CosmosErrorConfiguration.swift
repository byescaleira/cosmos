import Foundation

/// An error event delivered to ``CosmosErrorConfiguration/handler``.
///
/// Holds a string `message` and optional `code` rather than an `Error` value, because
/// `any Error` is not `Sendable` and would break the `Sendable` conformance of this struct
/// (SE-0302). Atoms describe the failure; consumers map to real errors if needed.
public struct CosmosErrorEvent: Sendable {
    public var category: String
    public var message: String
    public var code: Int?
    public var date: Date

    public init(category: String, message: String, code: Int? = nil, date: Date = Date()) {
        self.category = category
        self.message = message
        self.code = code
        self.date = date
    }
}

/// Error-reporting contract.
///
/// `handler` is `@Sendable`. Passive: no-op by default.
public struct CosmosErrorConfiguration: Sendable {
    public var isEnabled: Bool
    public var category: String
    public var handler: @Sendable (CosmosErrorEvent) -> Void

    public init(isEnabled: Bool = true, category: String = "Cosmos", handler: @escaping @Sendable (CosmosErrorEvent) -> Void = { _ in }) {
        self.isEnabled = isEnabled
        self.category = category
        self.handler = handler
    }

    public static let `default` = CosmosErrorConfiguration()

    /// Reports an error event if enabled.
    public func report(_ message: String, code: Int? = nil) {
        guard isEnabled else { return }
        handler(.init(category: category, message: message, code: code))
    }
}