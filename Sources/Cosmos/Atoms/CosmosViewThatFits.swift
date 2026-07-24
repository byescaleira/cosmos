import SwiftUI

/// A container that picks the first child layout that fits the offered size, **preserving view
/// identity** across the choice — unlike `if/else` between alternatives, which recreates
/// children and resets their state.
///
/// Wraps SwiftUI's `ViewThatFits` (iOS 16+, available on all 5 platforms at the Cosmos 26 floor)
/// so a `Cosmos`-prefixed atom exists in the design system for the size-driven reflow pattern
/// (e.g. a toast whose icon moves above its message when the width is constrained, or a button
/// row that drops a secondary label under accessibility Dynamic Type). Content only — state/theme
/// flow through the environment and `.cosmos*` modifiers, like every other atom.
///
/// Provide alternatives in priority order; the first that fits is shown. Pass `in:` to constrain
/// which axes count as "fitting" (default both).
public struct CosmosViewThatFits<Content: View>: View {
    private let axes: Axis.Set
    @ViewBuilder private let content: () -> Content

    /// Creates a fit-to-size container constrained to `axes` (default `[.horizontal, .vertical]`).
    public init(in axes: Axis.Set = [.horizontal, .vertical], @ViewBuilder content: @escaping () -> Content) {
        self.axes = axes
        self.content = content
    }

    public var body: some View {
        ViewThatFits(in: axes) {
            content()
        }
    }
}

// MARK: - Previews

#Preview("ViewThatFits – wide → row, narrow → stack", traits: .sizeThatFitsLayout) {
    CosmosViewThatFits {
        HStack(spacing: CosmosSpacingTokens.medium) {
            CosmosLabel("preview.title", systemImage: "star")
            CosmosButton("welcome.continue") {}
        }
        VStack(spacing: CosmosSpacingTokens.small) {
            CosmosLabel("preview.title", systemImage: "star")
            CosmosButton("welcome.continue") {}
        }
    }
    .padding()
}

#Preview("ViewThatFits – constrained width forces the stack", traits: .fixedLayout(width: 160, height: 240)) {
    CosmosViewThatFits {
        HStack(spacing: CosmosSpacingTokens.medium) {
            CosmosLabel("preview.title", systemImage: "star")
            CosmosButton("welcome.continue") {}
        }
        VStack(spacing: CosmosSpacingTokens.small) {
            CosmosLabel("preview.title", systemImage: "star")
            CosmosButton("welcome.continue") {}
        }
    }
    .padding()
}