import SwiftUI

/// Modifiers that override default selectors in ``CosmosTheme`` (visual defaults consumed
/// by atoms). Each reads the current theme, mutates a copy via the fluent builders, and
/// re-injects it.

private struct CosmosButtonStyleModifier: ViewModifier {
    let style: CosmosButtonStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withButtonStyle(style)) }
}

private struct CosmosControlSizeModifier: ViewModifier {
    let size: CosmosControlSize
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withControlSize(size)) }
}

private struct CosmosTextStyleModifier: ViewModifier {
    let style: CosmosTextStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withTextStyle(style)) }
}

private struct CosmosPaddingModifier: ViewModifier {
    let padding: CosmosPadding
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withPadding(padding)) }
}

private struct CosmosFontPresetModifier: ViewModifier {
    let preset: CosmosFontPreset
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withPreset(preset)) }
}

private struct CosmosMotionTokensModifier: ViewModifier {
    let tokens: CosmosMotionTokens
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withMotion(tokens)) }
}

private struct CosmosSpringStyleModifier: ViewModifier {
    let style: CosmosSpringStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withSpringStyle(style)) }
}

extension View {
    /// Overrides the default button style variant for descendant components.
    public func cosmosButtonStyle(_ style: CosmosButtonStyle) -> some View { modifier(CosmosButtonStyleModifier(style: style)) }
    /// Overrides the default control size for descendant components.
    public func cosmosControlSize(_ size: CosmosControlSize) -> some View { modifier(CosmosControlSizeModifier(size: size)) }
    /// Overrides the default text style for descendant components.
    public func cosmosTextStyle(_ style: CosmosTextStyle) -> some View { modifier(CosmosTextStyleModifier(style: style)) }
    /// Overrides the default padding selector for descendant components.
    public func cosmosPadding(_ padding: CosmosPadding) -> some View { modifier(CosmosPaddingModifier(padding: padding)) }
    /// Overrides the font preset for descendant components (registers fonts if needed).
    public func cosmosFontPreset(_ preset: CosmosFontPreset) -> some View { CosmosFont.registerIfNeeded(); return modifier(CosmosFontPresetModifier(preset: preset)) }
    /// Overrides the motion tokens (visual) for descendant components.
    public func cosmosMotionTokens(_ tokens: CosmosMotionTokens) -> some View { modifier(CosmosMotionTokensModifier(tokens: tokens)) }
    /// Overrides the default spring style for descendant components.
    public func cosmosSpringStyle(_ style: CosmosSpringStyle) -> some View { modifier(CosmosSpringStyleModifier(style: style)) }
}