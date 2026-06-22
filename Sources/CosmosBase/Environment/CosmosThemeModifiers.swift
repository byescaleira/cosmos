import SwiftUI

// MARK: - Modifiers

private struct CosmosTextStyleModifier: ViewModifier {
    let textStyle: CosmosTextStyle
    @Environment(\.cosmosTheme) private var theme

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosTheme, theme.withTextStyle(textStyle))
    }
}

private struct CosmosButtonStyleModifier: ViewModifier {
    let buttonStyle: CosmosButtonStyle
    @Environment(\.cosmosTheme) private var theme

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosTheme, theme.withButtonStyle(buttonStyle))
    }
}

private struct CosmosIconScaleModifier: ViewModifier {
    let iconScale: CosmosIconScale
    @Environment(\.cosmosTheme) private var theme

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosTheme, theme.withIconScale(iconScale))
    }
}

private struct CosmosDividerStyleModifier: ViewModifier {
    let dividerStyle: CosmosDividerStyle
    @Environment(\.cosmosTheme) private var theme

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosTheme, theme.withDividerStyle(dividerStyle))
    }
}

private struct CosmosDividerThicknessModifier: ViewModifier {
    let thickness: CosmosPadding
    @Environment(\.cosmosTheme) private var theme

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosTheme, theme.withDividerThickness(thickness))
    }
}

private struct CosmosPaddingModifier: ViewModifier {
    let padding: CosmosPadding
    @Environment(\.cosmosTheme) private var theme

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosTheme, theme.withPadding(padding))
    }
}

private struct CosmosControlSizeModifier: ViewModifier {
    let controlSize: CosmosControlSize
    @Environment(\.cosmosTheme) private var theme

    func body(content: Content) -> some View {
        content
            .environment(\.cosmosTheme, theme.withControlSize(controlSize))
    }
}

// MARK: - View extensions

extension View {
    /// Overrides the default text style for Cosmos components in this subtree.
    public func cosmosTextStyle(_ textStyle: CosmosTextStyle) -> some View {
        modifier(CosmosTextStyleModifier(textStyle: textStyle))
    }

    /// Overrides the default button style for Cosmos components in this subtree.
    public func cosmosButtonStyle(_ buttonStyle: CosmosButtonStyle) -> some View {
        modifier(CosmosButtonStyleModifier(buttonStyle: buttonStyle))
    }

    /// Overrides the default icon scale for Cosmos components in this subtree.
    public func cosmosIconScale(_ iconScale: CosmosIconScale) -> some View {
        modifier(CosmosIconScaleModifier(iconScale: iconScale))
    }

    /// Overrides the default divider style for Cosmos components in this subtree.
    public func cosmosDividerStyle(_ dividerStyle: CosmosDividerStyle) -> some View {
        modifier(CosmosDividerStyleModifier(dividerStyle: dividerStyle))
    }

    /// Overrides the default divider thickness for Cosmos components in this subtree.
    public func cosmosDividerThickness(_ thickness: CosmosPadding) -> some View {
        modifier(CosmosDividerThicknessModifier(thickness: thickness))
    }

    /// Overrides the default padding increment for Cosmos components in this subtree.
    public func cosmosPadding(_ padding: CosmosPadding) -> some View {
        modifier(CosmosPaddingModifier(padding: padding))
    }

    /// Overrides the default control size for Cosmos components in this subtree.
    @available(iOS 15, macOS 11, tvOS 16, watchOS 9, visionOS 1, *)
    public func cosmosControlSize(_ controlSize: CosmosControlSize) -> some View {
        modifier(CosmosControlSizeModifier(controlSize: controlSize))
    }
}
