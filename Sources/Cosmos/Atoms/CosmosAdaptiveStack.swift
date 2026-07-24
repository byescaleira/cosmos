import SwiftUI

/// A container that reflows between `HStack` and `VStack` by size class and Dynamic Type,
/// **preserving view identity** (focus, scroll position, animation state) across rotations.
///
/// Switching `AnyLayout` keeps the same subview identity — unlike `if/else` between
/// `HStack`/`VStack`, which recreates children and resets their state. Use this for the
/// portrait↔landscape reflow Apple is adopting across its apps.
///
/// Layout choice: horizontal (HStack) in regular width and non-accessibility Dynamic Type;
/// vertical (VStack) otherwise (compact width or accessibility sizes).
public struct CosmosAdaptiveStack<Content: View>: View {
    private let horizontalSpacing: CGFloat?
    private let verticalSpacing: CGFloat?
    private let horizontalAlignment: VerticalAlignment
    private let verticalAlignment: HorizontalAlignment
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ViewBuilder private let content: () -> Content

    public init(
        horizontalSpacing: CGFloat? = nil,
        verticalSpacing: CGFloat? = nil,
        horizontalAlignment: VerticalAlignment = .center,
        verticalAlignment: HorizontalAlignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.content = content
    }

    private var shouldStackHorizontally: Bool {
        horizontalSizeClass == .regular && !dynamicTypeSize.isAccessibilitySize
    }

    public var body: some View {
        let layout: AnyLayout = shouldStackHorizontally
            ? AnyLayout(HStackLayout(alignment: horizontalAlignment, spacing: horizontalSpacing))
            : AnyLayout(VStackLayout(alignment: verticalAlignment, spacing: verticalSpacing))
        layout { content() }
    }
}

extension View {
    /// Convenience to wrap content in a ``CosmosAdaptiveStack`` that reflows by size class.
    public func cosmosAdaptiveStack(
        horizontalSpacing: CGFloat? = nil,
        verticalSpacing: CGFloat? = nil,
        horizontalAlignment: VerticalAlignment = .center,
        verticalAlignment: HorizontalAlignment = .center
    ) -> some View {
        CosmosAdaptiveStack(
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment
        ) { self }
    }
}

// MARK: - Previews

#Preview("AdaptiveStack – portrait (regular → HStack)", traits: .sizeThatFitsLayout) {
    CosmosAdaptiveStack {
        CosmosLabel("preview.title", systemImage: "star")
        CosmosLabel("preview.description", systemImage: "circle")
        CosmosButton("welcome.continue") {}
    }
    .padding()
}

#Preview("AdaptiveStack – landscape reflow", traits: .landscapeLeft) {
    CosmosPreviewContainer {
        CosmosAdaptiveStack {
            CosmosLabel("preview.title", systemImage: "star")
            CosmosLabel("preview.description", systemImage: "circle")
            CosmosButton("welcome.continue") {}
        }
        .padding()
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}

#Preview("AdaptiveStack – dark + RTL landscape", traits: .landscapeLeft) {
    CosmosPreviewContainer {
        CosmosAdaptiveStack {
            CosmosLabel("preview.title", systemImage: "star")
            CosmosButton("welcome.continue") {}
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(layoutDirection: .rightToLeft)
    }
}