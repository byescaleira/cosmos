import Foundation

/// Redaction placeholder settings for Cosmos components.
///
/// Components use this contract to decide whether to apply SwiftUI's
/// `.redacted(reason: .placeholder)` modifier. This is useful for skeleton
/// screens and loading previews across all supported platforms.
public struct CosmosRedactionConfiguration: Sendable, Equatable {
    /// Whether components should render as placeholder redactions.
    public var isRedacted: Bool

    /// Creates a redaction configuration.
    public init(isRedacted: Bool = false) {
        self.isRedacted = isRedacted
    }

    /// The default redaction configuration (no redaction).
    public static let `default` = CosmosRedactionConfiguration()
}
