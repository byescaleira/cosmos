import SwiftUI

/// Applies a loading-driven redaction: when `configuration.loading.isLoading` is true, the
/// content is redacted to a placeholder and a `ProgressView` is overlaid. Atoms use this to
/// render skeleton/loading states without per-component logic.
private struct CosmosRedactedModifier: ViewModifier {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if configuration.loading.isLoading {
            content
                .redacted(reason: .placeholder)
                .overlay {
                    ProgressView()
                }
                // Route the VoiceOver label through the localization pipeline (the "Loading" key
                // exists in Localizable.xcstrings with en "Loading…" / pt-BR "Carregando…") so
                // non-English users hear the localized form; fall back to the literal if unresolved.
                .accessibilityLabel(configuration.localization.string(for: "Loading") ?? "Loading")
        } else {
            content
        }
    }
}

extension View {
    /// Redacts the content (placeholder + spinner) while the loading contract is active.
    public func cosmosRedacted() -> some View { modifier(CosmosRedactedModifier()) }
}