import SwiftUI

/// A horizontal stack that spaces its children on the Cosmos 4-pt grid.
///
/// A drop-in `HStack` whose spacing is a ``CosmosPadding`` selector resolved through
/// ``CosmosSpacingTokens/value(for:)`` — so layouts never hardcode raw point values. State and
/// theme come from the environment; the only configuration is the layout itself (alignment +
/// spacing), so this atom follows the content-only init convention.
///
/// ```swift
/// CosmosHStack(spacing: .large) {
///     CosmosIcon("checkmark.circle.fill")
///     CosmosText(verbatim: "Saved")
/// }
/// ```
public struct CosmosHStack<Content: View>: View {
    private let alignment: VerticalAlignment
    private let spacing: CGFloat
    @ViewBuilder private let content: () -> Content

    /// Creates a horizontal stack.
    ///
    /// - Parameters:
    ///   - alignment: The guide used to align children vertically (default `.center`).
    ///   - spacing: A Cosmos spacing selector resolved through ``CosmosSpacingTokens/value(for:)``
    ///     (default `.medium` → 12 pt). Pass `.none` to use `HStack`'s system default.
    ///   - content: The stack's children.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CosmosPadding = .medium,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.spacing = CosmosSpacingTokens.value(for: spacing)
        self.content = content
    }

    public var body: some View {
        HStack(alignment: alignment, spacing: spacing) {
            content()
        }
    }
}

// MARK: - Previews

#Preview("HStack – spacing scale", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(alignment: .leading, spacing: CosmosSpacingTokens.large) {
            CosmosHStack(spacing: .xs) {
                CosmosText(verbatim: "xs")
                CosmosText(verbatim: "•")
                CosmosText(verbatim: "4 pt")
            }
            CosmosHStack(spacing: .small) {
                CosmosText(verbatim: "small")
                CosmosText(verbatim: "•")
                CosmosText(verbatim: "8 pt")
            }
            CosmosHStack(spacing: .medium) {
                CosmosText(verbatim: "medium")
                CosmosText(verbatim: "•")
                CosmosText(verbatim: "12 pt")
            }
            CosmosHStack(spacing: .large) {
                CosmosText(verbatim: "large")
                CosmosText(verbatim: "•")
                CosmosText(verbatim: "16 pt")
            }
            CosmosHStack(spacing: .xl) {
                CosmosText(verbatim: "xl")
                CosmosText(verbatim: "•")
                CosmosText(verbatim: "24 pt")
            }
            CosmosHStack(spacing: .none) {
                CosmosText(verbatim: "none")
                CosmosText(verbatim: "•")
                CosmosText(verbatim: "system default")
            }
        }
        .padding()
    }
}

#Preview("HStack – alignment + default spacing", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosHStack(alignment: .top) {
            CosmosText(verbatim: "Top-aligned")
            CosmosText(verbatim: "second line\nthird line")
            CosmosText(verbatim: "tall\ncolumn")
        }
        .padding()
    }
}

#Preview("HStack – dark + Dynamic Type", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosHStack(spacing: .large) {
            CosmosIcon("star.fill")
            CosmosText(verbatim: "Saved to your library")
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}

#Preview("HStack – RTL", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosHStack(spacing: .medium) {
            CosmosIcon("arrow.forward")
            CosmosText(verbatim: "Next")
        }
        .padding()
        .cosmosPreviewVariant(.rtl)
    }
}

#Preview("HStack – landscape reflow", traits: .landscapeLeft) {
    CosmosPreviewContainer {
        CosmosHStack(spacing: .medium) {
            CosmosIcon("arrow.forward")
            CosmosText(verbatim: "Next")
            CosmosButton("welcome.continue") {}
        }
        .padding()
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}