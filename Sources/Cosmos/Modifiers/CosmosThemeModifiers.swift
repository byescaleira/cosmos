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

private struct CosmosToggleStyleModifier: ViewModifier {
    let style: CosmosToggleStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withToggleStyle(style)) }
}

private struct CosmosLabelStyleModifier: ViewModifier {
    let style: CosmosLabelStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withLabelStyle(style)) }
}

private struct CosmosProgressStyleModifier: ViewModifier {
    let style: CosmosProgressStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withProgressStyle(style)) }
}

private struct CosmosGroupBoxStyleModifier: ViewModifier {
    let style: CosmosGroupBoxStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withGroupBoxStyle(style)) }
}

private struct CosmosMenuStyleModifier: ViewModifier {
    let style: CosmosMenuStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withMenuStyle(style)) }
}

private struct CosmosDatePickerStyleModifier: ViewModifier {
    let style: CosmosDatePickerStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withDatePickerStyle(style)) }
}

private struct CosmosPickerStyleModifier: ViewModifier {
    let style: CosmosPickerStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withPickerStyle(style)) }
}

private struct CosmosListStyleModifier: ViewModifier {
    let style: CosmosListStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withListStyle(style)) }
}

private struct CosmosTabViewStyleModifier: ViewModifier {
    let style: CosmosTabViewStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withTabViewStyle(style)) }
}

private struct CosmosTextFieldStyleModifier: ViewModifier {
    let style: CosmosTextFieldStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withTextFieldStyle(style)) }
}

private struct CosmosTextEditorStyleModifier: ViewModifier {
    let style: CosmosTextEditorStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withTextEditorStyle(style)) }
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

/// Applies a token-scaled padding to a specific edge set directly (not a theme default override).
/// `.cosmosPadding(.large)` (single-arg) overrides the **default** padding selector for
/// descendants; `.cosmosPadding(.horizontal, .large)` (edge form) **applies** `large` to the
/// horizontal edges of this view, resolved through `CosmosSpacingTokens.value(for:)` — so a
/// per-edge padding stays on the 4-pt grid without raw points.
private struct CosmosPaddingEdgesModifier: ViewModifier {
    let edges: CosmosPaddingEdges
    let padding: CosmosPadding
    func body(content: Content) -> some View {
        content.padding(edges.edgeSet, CosmosSpacingTokens.value(for: padding))
    }
}

private struct CosmosCustomFontModifier: ViewModifier {
    let name: String?
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, theme.withCustomFont(name)) }
}

/// Overrides a single semantic color token of `theme.colors` for the subtree (mirrors the
/// per-selector `.cosmos*` pattern: read the env theme, mutate one token, re-inject). The token
/// enum is file-private so the public surface is the nine `.cosmos<Color>(_:)` funcs only.
private struct CosmosColorTokenModifier: ViewModifier {
    enum Token { case accent, primary, secondary, background, surface, success, warning, error, outline }
    let token: Token
    let color: Color
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View {
        var colors = theme.colors
        switch token {
        case .accent: colors.accent = color
        case .primary: colors.primary = color
        case .secondary: colors.secondary = color
        case .background: colors.background = color
        case .surface: colors.surface = color
        case .success: colors.success = color
        case .warning: colors.warning = color
        case .error: colors.error = color
        case .outline: colors.outline = color
        }
        return content.environment(\.cosmosTheme, theme.withColors(colors))
    }
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
    /// Overrides the default toggle style variant for descendant components.
    public func cosmosToggleStyle(_ style: CosmosToggleStyle) -> some View { modifier(CosmosToggleStyleModifier(style: style)) }
    /// Overrides the default label style variant for descendant components.
    public func cosmosLabelStyle(_ style: CosmosLabelStyle) -> some View { modifier(CosmosLabelStyleModifier(style: style)) }
    /// Overrides the default progress style variant for descendant components.
    public func cosmosProgressStyle(_ style: CosmosProgressStyle) -> some View { modifier(CosmosProgressStyleModifier(style: style)) }
    /// Overrides the default group box style variant for descendant components.
    public func cosmosGroupBoxStyle(_ style: CosmosGroupBoxStyle) -> some View { modifier(CosmosGroupBoxStyleModifier(style: style)) }
    /// Overrides the default menu style variant for descendant components.
    public func cosmosMenuStyle(_ style: CosmosMenuStyle) -> some View { modifier(CosmosMenuStyleModifier(style: style)) }
    /// Overrides the default date picker style variant for descendant components.
    public func cosmosDatePickerStyle(_ style: CosmosDatePickerStyle) -> some View { modifier(CosmosDatePickerStyleModifier(style: style)) }
    /// Overrides the default picker style variant for descendant components (each case is guarded
    /// per platform by the applier, falling back to `.automatic` where unavailable).
    public func cosmosPickerStyle(_ style: CosmosPickerStyle) -> some View { modifier(CosmosPickerStyleModifier(style: style)) }
    /// Overrides the default list style variant for descendant components (each case is guarded
    /// per platform by the applier, falling back to `.automatic` where unavailable).
    public func cosmosListStyle(_ style: CosmosListStyle) -> some View { modifier(CosmosListStyleModifier(style: style)) }
    /// Overrides the default tab-view style variant for descendant components (each case is guarded
    /// per platform by the applier, falling back to `.automatic` where unavailable).
    public func cosmosTabViewStyle(_ style: CosmosTabViewStyle) -> some View { modifier(CosmosTabViewStyleModifier(style: style)) }
    /// Overrides the default text-field style variant for descendant components.
    public func cosmosTextFieldStyle(_ style: CosmosTextFieldStyle) -> some View { modifier(CosmosTextFieldStyleModifier(style: style)) }
    /// Overrides the default text-editor style variant for descendant components (applied only
    /// where `TextEditor` exists — iOS/macOS/visionOS).
    public func cosmosTextEditorStyle(_ style: CosmosTextEditorStyle) -> some View { modifier(CosmosTextEditorStyleModifier(style: style)) }
    /// Overrides the default text style for descendant components.
    public func cosmosTextStyle(_ style: CosmosTextStyle) -> some View { modifier(CosmosTextStyleModifier(style: style)) }
    /// Overrides the default padding selector for descendant components.
    public func cosmosPadding(_ padding: CosmosPadding) -> some View { modifier(CosmosPaddingModifier(padding: padding)) }
    /// Applies a token-scaled padding to the given edges of this view (resolved through
    /// `CosmosSpacingTokens.value(for:)`), so a per-edge padding stays on the 4-pt grid without
    /// raw points. Unlike the single-arg ``cosmosPadding(_:)-5htpt`` (which overrides the default
    /// padding selector for descendants), this form applies padding directly to the modified view.
    public func cosmosPadding(_ edges: CosmosPaddingEdges, _ padding: CosmosPadding) -> some View {
        modifier(CosmosPaddingEdgesModifier(edges: edges, padding: padding))
    }
    /// Overrides the font for descendant components with a custom font's PostScript name, or `nil`
    /// to return to the system font. The font must be registered in your app; resolution uses
    /// `Font.custom(_:size:relativeTo:)` so Dynamic Type still scales.
    public func cosmosCustomFont(_ name: String?) -> some View { modifier(CosmosCustomFontModifier(name: name)) }
    /// Overrides the accent/tint color token for descendant components.
    public func cosmosAccent(_ color: Color) -> some View { modifier(CosmosColorTokenModifier(token: .accent, color: color)) }
    /// Overrides the primary foreground color token for descendant components.
    public func cosmosPrimary(_ color: Color) -> some View { modifier(CosmosColorTokenModifier(token: .primary, color: color)) }
    /// Overrides the secondary foreground color token for descendant components.
    public func cosmosSecondary(_ color: Color) -> some View { modifier(CosmosColorTokenModifier(token: .secondary, color: color)) }
    /// Overrides the root background color token for descendant components.
    public func cosmosBackground(_ color: Color) -> some View { modifier(CosmosColorTokenModifier(token: .background, color: color)) }
    /// Overrides the elevated surface color token for descendant components.
    public func cosmosSurface(_ color: Color) -> some View { modifier(CosmosColorTokenModifier(token: .surface, color: color)) }
    /// Overrides the success state color token for descendant components.
    public func cosmosSuccess(_ color: Color) -> some View { modifier(CosmosColorTokenModifier(token: .success, color: color)) }
    /// Overrides the warning state color token for descendant components.
    public func cosmosWarning(_ color: Color) -> some View { modifier(CosmosColorTokenModifier(token: .warning, color: color)) }
    /// Overrides the error/destructive state color token for descendant components.
    public func cosmosError(_ color: Color) -> some View { modifier(CosmosColorTokenModifier(token: .error, color: color)) }
    /// Overrides the outline/hairline color token for descendant components.
    public func cosmosOutline(_ color: Color) -> some View { modifier(CosmosColorTokenModifier(token: .outline, color: color)) }
    /// Overrides the motion tokens (visual) for descendant components.
    public func cosmosMotionTokens(_ tokens: CosmosMotionTokens) -> some View { modifier(CosmosMotionTokensModifier(tokens: tokens)) }
    /// Overrides the default spring style for descendant components.
    public func cosmosSpringStyle(_ style: CosmosSpringStyle) -> some View { modifier(CosmosSpringStyleModifier(style: style)) }
}