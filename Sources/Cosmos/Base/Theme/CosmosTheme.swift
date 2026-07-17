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
    public func withMotion(_ motion: CosmosMotionTokens) -> CosmosTheme { var c = self; c.motion = motion; return c }
    public func withSpringStyle(_ style: CosmosSpringStyle) -> CosmosTheme { var c = self; c.motion.defaultSpringStyle = style; return c }
}