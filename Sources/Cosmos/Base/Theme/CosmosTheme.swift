import SwiftUI

/// Immutable, token-driven theme, fully `Sendable`.
///
/// The primary theme path: a value type injected through `@Environment(\.cosmosTheme)` via
/// the `@Entry` macro. Because every member is `Sendable`, the whole struct is implicitly
/// `Sendable` and warning-free under Swift 6. Atoms read visual defaults from here and
/// override per-instance via `.cosmos*` modifiers (which re-inject a mutated copy).
///
/// For **runtime-mutable** theming (live theme switching), wrap a `CosmosTheme` in
/// ``CosmosThemeObservable`` (`@Observable @MainActor`) and inject the observable instead —
/// see that type for the Swift-6-safe injection pattern.
public struct CosmosTheme: Sendable {

    /// Design-language version pin. Apps may fix this to render an older Cosmos design
    /// language even on a newer OS. Defaults to ``CosmosVersion/current``.
    public var version: CosmosVersion

    /// Semantic color tokens.
    public var colors: CosmosColorTokens

    /// Typography tokens (font preset + Dynamic Type mapping).
    public var typography: CosmosTypographyTokens

    /// Default text style for text-bearing atoms.
    public var textStyle: CosmosTextStyle

    /// Default padding selector for container atoms.
    public var padding: CosmosPadding

    /// Default button style variant.
    public var buttonStyle: CosmosButtonStyle

    /// Default control size.
    public var controlSize: CosmosControlSize

    /// Default toggle style variant.
    public var toggleStyle: CosmosToggleStyle

    /// Default label style variant.
    public var labelStyle: CosmosLabelStyle

    /// Default progress style variant.
    public var progressStyle: CosmosProgressStyle

    /// Default group box style variant (chrome is unavailable on tvOS/watchOS; the atom renders a
    /// plain fallback there — the selector is still carried for API uniformity).
    public var groupBoxStyle: CosmosGroupBoxStyle

    /// Default menu style variant (Menu is unavailable on watchOS; the atom renders a
    /// `CosmosButton` fallback there — the selector is still carried for API uniformity).
    public var menuStyle: CosmosMenuStyle

    /// Default date picker style variant (DatePicker is type-level unavailable on tvOS; the
    /// entire atom is guarded `#if !os(tvOS)` — the selector is still carried for API uniformity).
    public var datePickerStyle: CosmosDatePickerStyle

    /// Default picker style variant for ``CosmosPicker`` (`.automatic`). `PickerStyle` is
    /// opaque/native-bridged — this enum is consumed by the applier, which guards each case per
    /// platform and falls back to `.automatic` where a requested style is unavailable.
    public var pickerStyle: CosmosPickerStyle

    /// Default list style variant for ``CosmosList`` (`.automatic`). `ListStyle` is
    /// opaque/native-bridged — this enum is consumed by the applier, which guards each case per
    /// platform and falls back to `.automatic` where a requested style is unavailable.
    public var listStyle: CosmosListStyle

    /// Default tab-view style variant for ``CosmosTabView`` (`.automatic`). `TabViewStyle` is
    /// opaque/native-bridged (only underscored `_makeView`/`_makeViewList`, no `makeBody`) — this enum
    /// is consumed by the applier, which guards each case per platform and falls back to `.automatic`
    /// where a requested style is unavailable.
    public var tabViewStyle: CosmosTabViewStyle

    /// Default text-field variant for ``CosmosTextField`` (`.automatic`).
    public var textFieldStyle: CosmosTextFieldStyle

    /// Default text-editor variant for ``CosmosTextEditor`` (`.automatic`). The selector enum is
    /// platform-agnostic; the native `TextEditorStyle` is only applied where `TextEditor` exists
    /// (iOS/macOS/visionOS) — the atom/applier guard out tvOS/watchOS.
    public var textEditorStyle: CosmosTextEditorStyle

    /// Motion visual tokens (spring presets, duration scale, transition presets, shadow).
    public var motion: CosmosMotionTokens

    public init(
        version: CosmosVersion = .current,
        colors: CosmosColorTokens = .default,
        typography: CosmosTypographyTokens = .default,
        textStyle: CosmosTextStyle = .body,
        padding: CosmosPadding = .medium,
        buttonStyle: CosmosButtonStyle = .primary,
        controlSize: CosmosControlSize = .medium,
        toggleStyle: CosmosToggleStyle = .automatic,
        labelStyle: CosmosLabelStyle = .automatic,
        progressStyle: CosmosProgressStyle = .automatic,
        groupBoxStyle: CosmosGroupBoxStyle = .automatic,
        menuStyle: CosmosMenuStyle = .automatic,
        datePickerStyle: CosmosDatePickerStyle = .automatic,
        pickerStyle: CosmosPickerStyle = .automatic,
        listStyle: CosmosListStyle = .automatic,
        tabViewStyle: CosmosTabViewStyle = .automatic,
        textFieldStyle: CosmosTextFieldStyle = .automatic,
        textEditorStyle: CosmosTextEditorStyle = .automatic,
        motion: CosmosMotionTokens = .default
    ) {
        self.version = version
        self.colors = colors
        self.typography = typography
        self.textStyle = textStyle
        self.padding = padding
        self.buttonStyle = buttonStyle
        self.controlSize = controlSize
        self.toggleStyle = toggleStyle
        self.labelStyle = labelStyle
        self.progressStyle = progressStyle
        self.groupBoxStyle = groupBoxStyle
        self.menuStyle = menuStyle
        self.datePickerStyle = datePickerStyle
        self.pickerStyle = pickerStyle
        self.listStyle = listStyle
        self.tabViewStyle = tabViewStyle
        self.textFieldStyle = textFieldStyle
        self.textEditorStyle = textEditorStyle
        self.motion = motion
    }

    public static let `default` = CosmosTheme()

    // MARK: - Fluent builders (return a mutated copy)

    public func withVersion(_ version: CosmosVersion) -> CosmosTheme { var c = self; c.version = version; return c }
    public func withColors(_ colors: CosmosColorTokens) -> CosmosTheme { var c = self; c.colors = colors; return c }
    public func withTypography(_ typography: CosmosTypographyTokens) -> CosmosTheme { var c = self; c.typography = typography; return c }
    public func withPreset(_ preset: CosmosFontPreset) -> CosmosTheme { var c = self; c.typography.preset = preset; return c }
    public func withTextStyle(_ textStyle: CosmosTextStyle) -> CosmosTheme { var c = self; c.textStyle = textStyle; return c }
    public func withPadding(_ padding: CosmosPadding) -> CosmosTheme { var c = self; c.padding = padding; return c }
    public func withButtonStyle(_ buttonStyle: CosmosButtonStyle) -> CosmosTheme { var c = self; c.buttonStyle = buttonStyle; return c }
    public func withControlSize(_ controlSize: CosmosControlSize) -> CosmosTheme { var c = self; c.controlSize = controlSize; return c }
    public func withToggleStyle(_ toggleStyle: CosmosToggleStyle) -> CosmosTheme { var c = self; c.toggleStyle = toggleStyle; return c }
    public func withLabelStyle(_ labelStyle: CosmosLabelStyle) -> CosmosTheme { var c = self; c.labelStyle = labelStyle; return c }
    public func withProgressStyle(_ progressStyle: CosmosProgressStyle) -> CosmosTheme { var c = self; c.progressStyle = progressStyle; return c }
    public func withGroupBoxStyle(_ groupBoxStyle: CosmosGroupBoxStyle) -> CosmosTheme { var c = self; c.groupBoxStyle = groupBoxStyle; return c }
    public func withMenuStyle(_ menuStyle: CosmosMenuStyle) -> CosmosTheme { var c = self; c.menuStyle = menuStyle; return c }
    public func withDatePickerStyle(_ datePickerStyle: CosmosDatePickerStyle) -> CosmosTheme { var c = self; c.datePickerStyle = datePickerStyle; return c }
    public func withPickerStyle(_ pickerStyle: CosmosPickerStyle) -> CosmosTheme { var c = self; c.pickerStyle = pickerStyle; return c }
    public func withListStyle(_ listStyle: CosmosListStyle) -> CosmosTheme { var c = self; c.listStyle = listStyle; return c }
    public func withTabViewStyle(_ tabViewStyle: CosmosTabViewStyle) -> CosmosTheme { var c = self; c.tabViewStyle = tabViewStyle; return c }
    public func withTextFieldStyle(_ textFieldStyle: CosmosTextFieldStyle) -> CosmosTheme { var c = self; c.textFieldStyle = textFieldStyle; return c }
    public func withTextEditorStyle(_ textEditorStyle: CosmosTextEditorStyle) -> CosmosTheme { var c = self; c.textEditorStyle = textEditorStyle; return c }
    public func withMotion(_ motion: CosmosMotionTokens) -> CosmosTheme { var c = self; c.motion = motion; return c }
    public func withSpringStyle(_ style: CosmosSpringStyle) -> CosmosTheme { var c = self; c.motion.defaultSpringStyle = style; return c }
}