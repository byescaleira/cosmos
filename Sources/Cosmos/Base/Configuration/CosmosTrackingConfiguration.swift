import Foundation

/// Analytics-friendly tracking actions.
public enum CosmosTrackAction: String, Sendable, Codable, CaseIterable {
    case tap
    case valueChange
    case focus
    case error
    case appear
    case disappear
}

/// A tracking event. **Opt-in/passive**: nothing is sent unless a consumer installs a
/// ``CosmosTrackingConfiguration/handler`` and enables it. No network, no PII — this is
/// first-party telemetry, so ATT does not apply.
public struct CosmosTrackEvent: Sendable {
    public var name: String
    public var component: String
    public var componentId: String?
    public var action: CosmosTrackAction
    public var metadata: [String: String]
    public var date: Date

    public init(
        name: String,
        component: String,
        componentId: String? = nil,
        action: CosmosTrackAction,
        metadata: [String: String] = [:],
        date: Date = Date()
    ) {
        self.name = name
        self.component = component
        self.componentId = componentId
        self.action = action
        self.metadata = metadata
        self.date = date
    }
}

/// Tracking/analytics contract.
///
/// `handler` is `@Sendable` (SE-0302). **Off by default** — `isEnabled` defaults to `false`
/// and the default handler is a no-op, so the library performs no tracking unless a consumer
/// explicitly opts in. Atoms pass `componentId = trackingId ?? accessibilityIdentifier`.
public struct CosmosTrackingConfiguration: Sendable {
    public var isEnabled: Bool
    public var handler: @Sendable (CosmosTrackEvent) -> Void

    public init(isEnabled: Bool = false, handler: @escaping @Sendable (CosmosTrackEvent) -> Void = { _ in }) {
        self.isEnabled = isEnabled
        self.handler = handler
    }

    public static let `default` = CosmosTrackingConfiguration()

    /// Emits a tracking event if enabled and a handler is effectively installed.
    public func track(_ event: CosmosTrackEvent) {
        guard isEnabled else { return }
        handler(event)
    }
}