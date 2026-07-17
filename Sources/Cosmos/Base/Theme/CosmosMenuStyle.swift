import Foundation

/// Visual variant selectors for ``CosmosMenu``.
///
/// `.automatic` resolves to `DefaultMenuStyle`; `.button` resolves to `ButtonMenuStyle` (iOS 16+,
/// available on all Cosmos-26 platforms except watchOS where `Menu` itself is unavailable). The
/// trigger's surrounding chrome is customized at the atom level (`.buttonStyle`/`.tint`/
/// `.controlSize`/`.font`); the popover content list is opaque (`MenuStyleConfiguration.Content`
/// /`.Label` `Body == Never`) and is never decomposed. `Menu` is **unavailable on watchOS**, so
/// the Menu-backed body is guarded `#if !os(watchOS)` and ``CosmosMenu`` renders a `CosmosButton`
/// fallback there.
public enum CosmosMenuStyle: String, Sendable, Codable, CaseIterable {
    case automatic
    case button
}