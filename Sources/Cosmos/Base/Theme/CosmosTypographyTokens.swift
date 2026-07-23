import SwiftUI

/// Font selection for Cosmos typography.
///
/// Cosmos ships **no bundled fonts** — by default it uses the system font, which honors Dynamic
/// Type (including accessibility sizes) with no extra work. To use a custom font, register it in
/// your app — add the `.ttf` to your target and list it in `Info.plist` under `UIAppFonts` on
/// iOS / tvOS / watchOS / visionOS, or call `CTFontManagerRegisterFontsForURL` directly — then pass
/// its PostScript name to ``CosmosTypographyTokens/init(customFont:)`` or
/// ``CosmosTheme/withCustomFont(_:)``. Resolution always goes through
/// `Font.custom(_:size:relativeTo:)`, so a custom font scales with Dynamic Type exactly like the
/// system font.
///
/// `CosmosFontPreset.default` is the system preset; there are no brand presets — the library is
/// font-agnostic by design (bring your own).
public enum CosmosFontPreset: String, Sendable, Codable, CaseIterable {
    /// The system font preset (the only preset).
    case `default`

    /// The custom-font PostScript name for this preset, or `nil` for the system font.
    public var fontName: String? {
        switch self {
        case .default: return nil
        }
    }
}

/// Semantic typography tokens.
///
/// ``font(for:)`` resolves a ``CosmosTextStyle`` to a `Font`, preserving Dynamic Type scaling for
/// both the system font and a custom font (`Font.custom(_:size:relativeTo:)`).
public struct CosmosTypographyTokens: Sendable {
    /// PostScript name of the custom font, or `nil` to use the system font.
    public var customFontName: String?

    /// Optional weight applied to the **system** font path (``Font.system(_:weight:design:)``).
    /// Ignored when a custom font is set — a custom font's weight is encoded in its PostScript
    /// name. `nil` falls back to SwiftUI's default (`.regular`).
    public var weight: Font.Weight?

    /// Optional design applied to the **system** font path (``Font.system(_:weight:design:)``).
    /// Ignored when a custom font is set. `nil` falls back to SwiftUI's default (`.default`).
    public var design: Font.Design?

    /// System-font tokens (the default). `preset` is retained for source compatibility; the only
    /// case is ``CosmosFontPreset/default`` (system).
    public init(preset: CosmosFontPreset = .default, weight: Font.Weight? = nil, design: Font.Design? = nil) {
        self.customFontName = preset.fontName
        self.weight = weight
        self.design = design
    }

    /// Custom-font tokens. `customFont` is the PostScript name of a font you have registered in
    /// your app; it resolves via `Font.custom(_:size:relativeTo:)` so Dynamic Type still scales.
    /// `weight`/`design` are accepted for completeness but are ignored on the custom-font path.
    public init(customFont: String, weight: Font.Weight? = nil, design: Font.Design? = nil) {
        self.customFontName = customFont
        self.weight = weight
        self.design = design
    }

    public static let `default` = CosmosTypographyTokens()

    /// Resolves a ``CosmosTextStyle`` to a Dynamic-Type-aware `Font`.
    public func font(for style: CosmosTextStyle) -> Font {
        if let name = customFontName {
            // Custom fonts MUST pass relativeTo: so they scale correctly with Dynamic Type.
            // weight/design are encoded in the font file's PostScript name and are ignored here.
            return .custom(name, size: style.pointSize, relativeTo: style.textStyle)
        }
        // The TextStyle-based `Font.system(_ style:design:)` keeps Dynamic-Type scaling; weight is
        // applied via the `.weight(_:)` modifier (the combined `system(_:weight:design:)` overload
        // is not available on this SDK — only the `size:`-based one, which would lose Dynamic Type).
        // `nil` overrides fall back to `.default` / `.regular` → identical to `.system(style.textStyle)`.
        return .system(style.textStyle, design: design ?? .default).weight(weight ?? .regular)
    }
}