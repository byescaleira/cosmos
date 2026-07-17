import Foundation

/// Visual variant selectors for ``CosmosToggle``.
///
/// `.switch` and `.automatic` resolve to the native `SwitchToggleStyle` (all 5 platforms at the
/// Cosmos 26 floor; `.switch` became available on tvOS at 18). `.button` resolves to
/// `ButtonToggleStyle`, which is **unavailable on tvOS** — ``CosmosToggle`` guards it with
/// `#if !os(tvOS)` and falls back to the switch style on tvOS. The deprecated
/// `SwitchToggleStyle(tint:)` initializer is never used; the accent tint is applied via the
/// `.tint(_:)` modifier instead.
public enum CosmosToggleStyle: String, Sendable, Codable, CaseIterable {
    case automatic
    case `switch`
    case button
}