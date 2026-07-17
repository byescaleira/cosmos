import SwiftUI

/// Cosmos environment values.
///
/// All three are `Sendable` value types with nonisolated default initializers, so they are
/// safe as `@Entry` defaults — no "Main actor-isolated default value in a nonisolated context"
/// conflict (SE-0401, SE-0412). `@Entry` is the recommended environment pattern in the v26
/// SDKs, replacing manual `EnvironmentKey` boilerplate.
///
/// For the **runtime-mutable** theme path, inject ``CosmosThemeObservable`` via
/// `.environment(_:)` and read it with `@Environment(CosmosThemeObservable.self)` — do **not**
/// route it through `@Entry`.
extension EnvironmentValues {
    /// The 9 cross-cutting behavior contracts.
    @Entry public var cosmosConfiguration: CosmosConfiguration = .default
    /// Visual tokens, default selectors, and design-language version.
    @Entry public var cosmosTheme: CosmosTheme = .default
    /// Analytics id; atoms fall back to `accessibilityIdentifier` when this is nil.
    @Entry public var cosmosTrackingId: String? = nil
}