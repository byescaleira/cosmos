import Foundation

/// Visual variant selectors for ``CosmosProgress``.
///
/// `.automatic`, `.circular`, and `.linear` resolve to the built-in `ProgressViewStyle` statics
/// (all 5 platforms at the Cosmos 26 floor). `.cosmos` routes through the custom conforming
/// ``CosmosProgressChrome`` style, which renders a token-driven determinate bar from
/// `fractionCompleted` and delegates the indeterminate case to the native spinner (which
/// auto-respects Reduce Motion).
public enum CosmosProgressStyle: String, Sendable, Codable, CaseIterable {
    case automatic
    case circular
    case linear
    case cosmos
}