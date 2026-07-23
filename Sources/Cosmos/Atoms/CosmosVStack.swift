import SwiftUI

/// A vertical stack that spaces its children on the Cosmos 4-pt grid.
///
/// A drop-in `VStack` whose spacing is a ``CosmosPadding`` selector resolved through
/// ``CosmosSpacingTokens/value(for:)`` — so layouts never hardcode raw point values. State and
/// theme come from the environment; the only configuration is the layout itself (alignment +
/// spacing), so this atom follows the content-only init convention.
///
/// ```swift
/// CosmosVStack(spacing: .small, alignment: .leading) {
///     CosmosText(verbatim: "Title")
///     CosmosText(verbatim: "Description")
/// }
/// ```
public struct CosmosVStack<Content: View>: View {
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat
    @ViewBuilder private let content: () -> Content

    /// Creates a vertical stack.
    ///
    /// - Parameters:
    ///   - alignment: The guide used to align children horizontally (default `.center`).
    ///   - spacing: A Cosmos spacing selector resolved through ``CosmosSpacingTokens/value(for:)``
    ///     (default `.medium` → 12 pt). Pass `.none` to use `VStack`'s system default.
    ///   - content: The stack's children.
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CosmosPadding = .medium,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.spacing = CosmosSpacingTokens.value(for: spacing)
        self.content = content
    }

    public var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            content()
        }
    }
}

// MARK: - Previews

#Preview("VStack – spacing scale", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        HStack(alignment: .top, spacing: CosmosSpacingTokens.xxl) {
            CosmosVStack(alignment: .leading, spacing: .xs) {
                CosmosText(verbatim: "xs")
                CosmosText(verbatim: "4 pt")
            }
            CosmosVStack(alignment: .leading, spacing: .small) {
                CosmosText(verbatim: "small")
                CosmosText(verbatim: "8 pt")
            }
            CosmosVStack(alignment: .leading, spacing: .medium) {
                CosmosText(verbatim: "medium")
                CosmosText(verbatim: "12 pt")
            }
            CosmosVStack(alignment: .leading, spacing: .large) {
                CosmosText(verbatim: "large")
                CosmosText(verbatim: "16 pt")
            }
            CosmosVStack(alignment: .leading, spacing: .xl) {
                CosmosText(verbatim: "xl")
                CosmosText(verbatim: "24 pt")
            }
            CosmosVStack(alignment: .leading, spacing: .none) {
                CosmosText(verbatim: "none")
                CosmosText(verbatim: "system default")
            }
        }
        .padding()
    }
}

#Preview("VStack – alignment + default spacing", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosVStack(alignment: .leading) {
            CosmosText(verbatim: "Left-aligned title")
            CosmosText(verbatim: "Second line")
            CosmosText(verbatim: "Third line")
        }
        .padding()
    }
}

#Preview("VStack – dark + Dynamic Type", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosVStack(alignment: .leading, spacing: .small) {
            CosmosText(verbatim: "Title")
            CosmosText(verbatim: "Description goes here")
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}

#Preview("VStack – landscape", traits: .landscapeLeft) {
    CosmosPreviewContainer {
        CosmosVStack(spacing: .large) {
            CosmosIcon("tray.full.fill")
            CosmosText(verbatim: "Laid out for landscape")
        }
        .padding()
    }
}