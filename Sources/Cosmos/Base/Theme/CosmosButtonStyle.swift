import Foundation

/// Visual variant selectors for ``CosmosButton``.
///
/// `glass` resolves to the native Liquid Glass button styles on iOS 26 (`.glassProminent`),
/// which are **not** customizable through `ButtonStyle` — so ``CosmosButton`` applies them
/// directly instead of routing through ``CosmosButtonChrome``. All other variants render
/// through ``CosmosButtonChrome`` for full token-driven control.
public enum CosmosButtonStyle: String, Sendable, Codable, CaseIterable {
    case primary
    case secondary
    case danger
    case ghost
    case glass
}