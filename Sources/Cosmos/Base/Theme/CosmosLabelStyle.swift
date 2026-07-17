import Foundation

/// Visual variant selectors for ``CosmosLabel``.
///
/// `.automatic`, `.titleAndIcon`, `.iconOnly`, and `.titleOnly` resolve to the built-in
/// `LabelStyle` statics (all 5 platforms at the Cosmos 26 floor). `.cosmos` routes through the
/// custom conforming ``CosmosLabelChrome`` style, which composes `configuration.title` +
/// `configuration.icon` with token-driven foreground style and typography.
public enum CosmosLabelStyle: String, Sendable, Codable, CaseIterable {
    case automatic
    case titleAndIcon
    case iconOnly
    case titleOnly
    case cosmos
}