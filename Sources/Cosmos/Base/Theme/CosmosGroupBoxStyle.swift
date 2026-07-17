import Foundation

/// Visual variant selectors for ``CosmosGroupBox``.
///
/// `GroupBox` ships only `DefaultGroupBoxStyle` (`.automatic`) — there are no `.bordered`/
/// `.plain` variants. `.cosmos` routes through the custom conforming ``CosmosGroupBoxChrome``
/// (token-driven background + padding + header typography). `GroupBox` and `.groupBoxStyle(_:)`
/// are **unavailable on tvOS/watchOS** (the SDK marks both unavailable despite Apple docs listing
/// tvOS 14+/watchOS 7+), so the chrome + applier are guarded `#if !os(tvOS) && !os(watchOS)` and
/// ``CosmosGroupBox`` renders a plain fallback there.
public enum CosmosGroupBoxStyle: String, Sendable, Codable, CaseIterable {
    case automatic
    case cosmos
}