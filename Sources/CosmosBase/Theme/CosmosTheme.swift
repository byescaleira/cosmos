import SwiftUI

/// Visual theme that carries all design tokens for Cosmos components.
///
/// `CosmosTheme` is intentionally a `Sendable` value type. Replace it
/// through the SwiftUI environment to drive changes down the view tree.
/// It does **not** carry component state such as `isEnabled` or `isLoading`;
/// those live in `CosmosConfiguration`.
public struct CosmosTheme: Sendable, Equatable {
    /// Color tokens.
    public var colors: CosmosColorTokens

    /// Typography tokens.
    public var typography: CosmosTypographyTokens

    /// Spacing tokens.
    public var spacing: CosmosSpacingTokens

    /// Corner radius tokens.
    public var radii: CosmosRadiusTokens

    /// Default text style selector.
    public var textStyle: CosmosTextStyle

    /// Default icon scale selector.
    public var iconScale: CosmosIconScale

    /// Default divider style selector.
    public var dividerStyle: CosmosDividerStyle

    /// Default divider thickness.
    public var dividerThickness: CosmosPadding

    /// Default button style selector.
    public var buttonStyle: CosmosButtonStyle

    /// Default button control size.
    public var controlSize: CosmosControlSize

    /// Default padding selector.
    public var padding: CosmosPadding

    /// Creates a theme with explicit tokens and selectors.
    public init(
        colors: CosmosColorTokens = .default,
        typography: CosmosTypographyTokens = .default,
        spacing: CosmosSpacingTokens = .default,
        radii: CosmosRadiusTokens = .default,
        textStyle: CosmosTextStyle = .body,
        iconScale: CosmosIconScale = .medium,
        dividerStyle: CosmosDividerStyle = .default,
        dividerThickness: CosmosPadding = .xs,
        buttonStyle: CosmosButtonStyle = .primary,
        controlSize: CosmosControlSize = .regular,
        padding: CosmosPadding = .medium
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radii = radii
        self.textStyle = textStyle
        self.iconScale = iconScale
        self.dividerStyle = dividerStyle
        self.dividerThickness = dividerThickness
        self.buttonStyle = buttonStyle
        self.controlSize = controlSize
        self.padding = padding
    }

    /// The default theme.
    public static let `default` = CosmosTheme()

    /// Fluent mutation: returns a copy with `textStyle` replaced.
    public func withTextStyle(_ style: CosmosTextStyle) -> CosmosTheme {
        var copy = self
        copy.textStyle = style
        return copy
    }

    /// Fluent mutation: returns a copy with `iconScale` replaced.
    public func withIconScale(_ scale: CosmosIconScale) -> CosmosTheme {
        var copy = self
        copy.iconScale = scale
        return copy
    }

    /// Fluent mutation: returns a copy with `dividerStyle` replaced.
    public func withDividerStyle(_ style: CosmosDividerStyle) -> CosmosTheme {
        var copy = self
        copy.dividerStyle = style
        return copy
    }

    /// Fluent mutation: returns a copy with `dividerThickness` replaced.
    public func withDividerThickness(_ thickness: CosmosPadding) -> CosmosTheme {
        var copy = self
        copy.dividerThickness = thickness
        return copy
    }

    /// Fluent mutation: returns a copy with `buttonStyle` replaced.
    public func withButtonStyle(_ style: CosmosButtonStyle) -> CosmosTheme {
        var copy = self
        copy.buttonStyle = style
        return copy
    }

    /// Fluent mutation: returns a copy with `controlSize` replaced.
    public func withControlSize(_ size: CosmosControlSize) -> CosmosTheme {
        var copy = self
        copy.controlSize = size
        return copy
    }

    /// Fluent mutation: returns a copy with `padding` replaced.
    public func withPadding(_ padding: CosmosPadding) -> CosmosTheme {
        var copy = self
        copy.padding = padding
        return copy
    }

    /// Fluent mutation: returns a copy with `colors` replaced.
    public func withColors(_ colors: CosmosColorTokens) -> CosmosTheme {
        var copy = self
        copy.colors = colors
        return copy
    }

    /// Fluent mutation: returns a copy with `typography` replaced.
    public func withTypography(_ typography: CosmosTypographyTokens) -> CosmosTheme {
        var copy = self
        copy.typography = typography
        return copy
    }

    /// Fluent mutation: returns a copy with `spacing` replaced.
    public func withSpacing(_ spacing: CosmosSpacingTokens) -> CosmosTheme {
        var copy = self
        copy.spacing = spacing
        return copy
    }

    /// Fluent mutation: returns a copy with `radii` replaced.
    public func withRadii(_ radii: CosmosRadiusTokens) -> CosmosTheme {
        var copy = self
        copy.radii = radii
        return copy
    }
}

// MARK: - Theme selectors

/// Semantic text styles.
public enum CosmosTextStyle: String, Sendable, Codable, CaseIterable {
    case largeTitle, title, title2, title3
    case headline, subheadline
    case body, callout, caption, caption2, footnote
}

/// Semantic icon scales.
public enum CosmosIconScale: String, Sendable, Codable, CaseIterable {
    case small, medium, large
}

/// Semantic divider styles.
public enum CosmosDividerStyle: String, Sendable, Codable, CaseIterable {
    case `default`, inset, bold
}

/// Semantic button styles.
public enum CosmosButtonStyle: String, Sendable, Codable, CaseIterable {
    case primary, secondary, danger, ghost
}

/// Semantic padding increments.
public enum CosmosPadding: String, Sendable, Codable, CaseIterable {
    case none, xs, small, medium, large, xl, xxl
}

/// Semantic corner radius increments.
public enum CosmosRadius: String, Sendable, Codable, CaseIterable {
    case none, small, medium, large, full
}

/// Cross-platform control size selector.
///
/// Maps to SwiftUI `ControlSize` where available. `CosmosControlSize` exists
/// so that theme files and JSON payloads can describe a control size without
/// depending on SwiftUI symbols directly.
public enum CosmosControlSize: String, Sendable, Codable, CaseIterable {
    case mini
    case small
    case regular
    case large
    case extraLarge
}

extension CosmosControlSize {
    /// The SwiftUI `ControlSize` for platforms that support it.
    @available(iOS 15, macOS 11, tvOS 16, watchOS 9, visionOS 1, *)
    public var swiftUIValue: ControlSize {
        switch self {
        case .mini: .mini
        case .small: .small
        case .regular: .regular
        case .large: .large
        case .extraLarge: .extraLarge
        }
    }
}
