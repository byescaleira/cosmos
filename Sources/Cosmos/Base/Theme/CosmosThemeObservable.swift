import SwiftUI

/// Runtime-mutable, observable theme for live theme switching.
///
/// The **primary** theme path is the immutable `Sendable` struct ``CosmosTheme`` injected
/// via `@Environment(\.cosmosTheme)` (an `@Entry` value). This type is the opt-in
/// **runtime-mutable** path for apps that switch themes live.
///
/// **Concurrency (SE-0395, Apple Sendable docs):** `@MainActor` makes the class implicitly
/// `Sendable` and permits mutable stored properties — the main actor serializes all access.
/// `@Observable` is bring-your-own-synchronization (no thread affinity); marking the type
/// `@MainActor` is the synchronization that keeps it Swift-6-safe.
///
/// **Injection:** use the Observable environment pattern, **not** `@Entry`. `@Entry` would
/// require a nonisolated `defaultValue` and a `@MainActor`-isolated default triggers
/// "Main actor-isolated default value in a nonisolated context" (SE-0412). Instead inject
/// the instance and read it by type:
///
/// ```swift
/// @Environment(CosmosThemeObservable.self) private var themeObservable
/// // inject: SomeView().environment(CosmosThemeObservable())
/// ```
@MainActor
@Observable
public final class CosmosThemeObservable {
    /// The current theme. Mutating this on the main actor re-renders observing views.
    public var theme: CosmosTheme

    public init(theme: CosmosTheme = .default) {
        self.theme = theme
    }

    public static let `default` = CosmosThemeObservable()
}