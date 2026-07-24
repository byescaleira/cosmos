import SwiftUI

/// Modifiers that override default selectors in ``CosmosTheme`` (visual defaults consumed
/// by atoms). Each reads the current theme, mutates a copy via the fluent builders, and
/// re-injects it.

/// The single read-transform-reinject primitive every single-field selector override uses:
/// read the env theme, apply a pure `with*` transform, re-inject. The 18 single-field
/// `.cosmos*` selectors collapse onto this one modifier; the multi-field overrides
/// (`.cosmosFont`, `.cosmosFont(_:for:)`, the color-token switch) and the direct-`.padding`
/// edge form stay explicit below.
private struct CosmosThemeModifier: ViewModifier {
    let transform: @Sendable (CosmosTheme) -> CosmosTheme
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View { content.environment(\.cosmosTheme, transform(theme)) }
}

/// Canonical typography override (system font): sets the semantic text style plus optional
/// weight/design. Clears any higher-scope `customFontName` so weight/design actually apply — a
/// custom font would otherwise route resolution down the custom path and ignore weight/design
/// (a custom font's weight/design live in its PostScript name).
private struct CosmosFontModifier: ViewModifier {
    let style: CosmosTextStyle
    let weight: Font.Weight?
    let design: Font.Design?
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View {
        var typography = theme.typography
        typography.customFontName = nil
        typography.weight = weight
        typography.design = design
        var t = theme.withTextStyle(style)
        t = t.withTypography(typography)
        return content.environment(\.cosmosTheme, t)
    }
}

/// Custom-font typography override (the replacement for the deprecated
/// ``cosmosCustomFont(_:)``): sets a registered PostScript name at the given semantic style, and
/// resolves via `Font.custom(_:size:relativeTo:)` so Dynamic Type still scales.
private struct CosmosCustomFontNameModifier: ViewModifier {
    let name: String?
    let style: CosmosTextStyle
    @Environment(\.cosmosTheme) private var theme
    func body(content: Content) -> some View {
        var typography = theme.typography
        typography.customFontName = name
        var t = theme.withTextStyle(style)
        t = t.withTypography(typography)
        return content.environment(\.cosmosTheme, t)
    }
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

extension View {
    /// Overrides the default button style variant for descendant components.
    public func cosmosButtonStyle(_ style: CosmosButtonStyle) -> some View { modifier(CosmosThemeModifier { $0.withButtonStyle(style) }) }
    /// Overrides the default control size for descendant components.
    public func cosmosControlSize(_ size: CosmosControlSize) -> some View { modifier(CosmosThemeModifier { $0.withControlSize(size) }) }
    /// Overrides the default toggle style variant for descendant components.
    public func cosmosToggleStyle(_ style: CosmosToggleStyle) -> some View { modifier(CosmosThemeModifier { $0.withToggleStyle(style) }) }
    /// Overrides the default label style variant for descendant components.
    public func cosmosLabelStyle(_ style: CosmosLabelStyle) -> some View { modifier(CosmosThemeModifier { $0.withLabelStyle(style) }) }
    /// Overrides the default progress style variant for descendant components.
    public func cosmosProgressStyle(_ style: CosmosProgressStyle) -> some View { modifier(CosmosThemeModifier { $0.withProgressStyle(style) }) }
    /// Overrides the default group box style variant for descendant components.
    public func cosmosGroupBoxStyle(_ style: CosmosGroupBoxStyle) -> some View { modifier(CosmosThemeModifier { $0.withGroupBoxStyle(style) }) }
    /// Overrides the default menu style variant for descendant components.
    public func cosmosMenuStyle(_ style: CosmosMenuStyle) -> some View { modifier(CosmosThemeModifier { $0.withMenuStyle(style) }) }
    /// Overrides the default date picker style variant for descendant components.
    public func cosmosDatePickerStyle(_ style: CosmosDatePickerStyle) -> some View { modifier(CosmosThemeModifier { $0.withDatePickerStyle(style) }) }
    /// Overrides the default picker style variant for descendant components (each case is guarded
    /// per platform by the applier, falling back to `.automatic` where unavailable).
    public func cosmosPickerStyle(_ style: CosmosPickerStyle) -> some View { modifier(CosmosThemeModifier { $0.withPickerStyle(style) }) }
    /// Overrides the default list style variant for descendant components (each case is guarded
    /// per platform by the applier, falling back to `.automatic` where unavailable).
    public func cosmosListStyle(_ style: CosmosListStyle) -> some View { modifier(CosmosThemeModifier { $0.withListStyle(style) }) }
    /// Overrides the default tab-view style variant for descendant components (each case is guarded
    /// per platform by the applier, falling back to `.automatic` where unavailable).
    public func cosmosTabViewStyle(_ style: CosmosTabViewStyle) -> some View { modifier(CosmosThemeModifier { $0.withTabViewStyle(style) }) }
    /// Overrides the default text-field style variant for descendant components.
    public func cosmosTextFieldStyle(_ style: CosmosTextFieldStyle) -> some View { modifier(CosmosThemeModifier { $0.withTextFieldStyle(style) }) }
    /// Overrides the default text-editor style variant for descendant components (applied only
    /// where `TextEditor` exists — iOS/macOS/visionOS).
    public func cosmosTextEditorStyle(_ style: CosmosTextEditorStyle) -> some View { modifier(CosmosThemeModifier { $0.withTextEditorStyle(style) }) }
    /// Overrides the default text style for descendant components.
    @available(*, deprecated, message: "Use .cosmosFont(_:weight:design:) instead")
    public func cosmosTextStyle(_ style: CosmosTextStyle) -> some View { modifier(CosmosThemeModifier { $0.withTextStyle(style) }) }
    /// Overrides the default padding selector for descendant components.
    public func cosmosPadding(_ padding: CosmosPadding) -> some View { modifier(CosmosThemeModifier { $0.withPadding(padding) }) }
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
    @available(*, deprecated, message: "Use .cosmosFont(_:for:) to set a custom font")
    public func cosmosCustomFont(_ name: String?) -> some View { modifier(CosmosThemeModifier { $0.withCustomFont(name) }) }
    /// Canonical typography override (system font): a semantic ``CosmosTextStyle`` plus optional
    /// weight and design, mirroring SwiftUI's `Font.system(_:weight:design:)`. Clears any
    /// higher-scope custom font so weight/design take effect. Replaces ``cosmosTextStyle(_:)``.
    public func cosmosFont(_ style: CosmosTextStyle, weight: Font.Weight? = nil, design: Font.Design? = nil) -> some View {
        modifier(CosmosFontModifier(style: style, weight: weight, design: design))
    }
    /// Custom-font typography override: a registered PostScript name at the given semantic style,
    /// resolved via `Font.custom(_:size:relativeTo:)` so Dynamic Type still scales. `nil` returns
    /// to the system font. Replaces ``cosmosCustomFont(_:)``.
    public func cosmosFont(_ customFont: String?, for style: CosmosTextStyle = .body) -> some View {
        modifier(CosmosCustomFontNameModifier(name: customFont, style: style))
    }
    /// Overrides the accent/tint color token for descendant components.
    public func cosmosAccent(_ color: Color) -> some View { modifier(CosmosColorTokenModifier(token: .accent, color: color)) }
    /// SwiftUI-idiomatic alias of ``cosmosAccent(_:)``: overrides the accent/tint color token for
    /// descendant components (mirrors SwiftUI's `.tint(_:)`).
    public func cosmosTint(_ color: Color) -> some View { modifier(CosmosColorTokenModifier(token: .accent, color: color)) }
    /// Overrides the primary foreground color token for descendant components.
    public func cosmosPrimary(_ color: Color) -> some View { modifier(CosmosColorTokenModifier(token: .primary, color: color)) }
    /// SwiftUI-idiomatic alias of ``cosmosPrimary(_:)``: overrides the primary foreground color
    /// token for descendant components (mirrors SwiftUI's `.foregroundStyle(_:)`).
    public func cosmosForegroundStyle(_ color: Color) -> some View { modifier(CosmosColorTokenModifier(token: .primary, color: color)) }
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
    public func cosmosMotionTokens(_ tokens: CosmosMotionTokens) -> some View { modifier(CosmosThemeModifier { $0.withMotion(tokens) }) }
    /// Overrides the default spring style for descendant components.
    public func cosmosSpringStyle(_ style: CosmosSpringStyle) -> some View { modifier(CosmosThemeModifier { $0.withSpringStyle(style) }) }
    /// Overrides the maximum width a regular-width-class toast clamps to (the compact width class
    /// uses `.infinity`). Replaces the prior hard-coded `420` magic number.
    public func cosmosToastMaxWidth(_ width: CGFloat) -> some View { modifier(CosmosThemeModifier { $0.withToastMaxWidth(width) }) }
}