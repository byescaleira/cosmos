import SwiftUI

/// A divider atom wrapping the native `Divider`.
///
/// `Divider` has **no style protocol** (there is no `DividerStyle`), so this atom wraps a `View`
/// per the Cosmos wrap-view discipline (see `DECISIONS.md`). The line color is **not** tunable via
/// `.foregroundStyle`/`.background`/`.tint` — `Divider` ignores them — so Cosmos deliberately does
/// not fight that: the native separator already resolves to the platform's separator color, which
/// ``CosmosColorTokens/outline`` mirrors on iOS/macOS (`Color(.separator)`) and approximates
/// elsewhere. Recoloring or a custom thickness is caller-driven (apply `.overlay(_:in:)` or draw a
/// custom `Rectangle` from theme tokens at the call site); Cosmos does not re-wrap the divider in a
/// container, which would break the axis inferred from the enclosing `HStack`/`VStack`.
///
/// **Accessibility:** purely decorative — `.accessibilityHidden(true)` so it is never a VoiceOver
/// focus target. **Motion:** `none`; conditional show/hide is container-driven
/// (`.cosmosTransition(.sheet)` / list insert-remove at the container, one `withAnimation`).
/// **Tracking:** none — decorative/structural elements do not emit appear events (a `List` of many
/// dividers would otherwise be noisy).
public struct CosmosDivider: View {
    @Environment(\.cosmosConfiguration) private var configuration

    /// Creates a thematic separator. Axis is inferred from the enclosing `HStack`/`VStack`.
    public init() {}

    public var body: some View {
        if configuration.enable.isVisible {
            Divider()
                .accessibilityHidden(true)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Previews

#Preview("Divider – between content") {
    VStack(alignment: .leading, spacing: 12) {
        CosmosText("preview.title").cosmosFont(.headline)
        CosmosDivider()
        CosmosText("preview.description").cosmosFont(.body)
    }
    .padding()
}

#Preview("Divider – in an HStack (vertical axis)") {
    HStack(spacing: 12) {
        CosmosText("preview.name").cosmosFont(.body)
        CosmosDivider()
        CosmosText("preview.name").cosmosFont(.body)
    }
    .padding()
}

#Preview("Divider – dark + accessibility size", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(alignment: .leading, spacing: 12) {
            CosmosText("welcome.headline").cosmosFont(.headline)
            CosmosDivider()
            CosmosText("preview.description").cosmosFont(.body)
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}