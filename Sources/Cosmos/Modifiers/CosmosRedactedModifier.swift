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
                .accessibilityLabel("Loading")
        } else {
            content
        }
    }
}

extension View {
    /// Redacts the content (placeholder + spinner) while the loading contract is active.
    public func cosmosRedacted() -> some View { modifier(CosmosRedactedModifier()) }
}