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

    /// System-font tokens (the default). `preset` is retained for source compatibility; the only
    /// case is ``CosmosFontPreset/default`` (system).
    public init(preset: CosmosFontPreset = .default) {
        self.customFontName = preset.fontName
    }

    /// Custom-font tokens. `customFont` is the PostScript name of a font you have registered in
    /// your app; it resolves via `Font.custom(_:size:relativeTo:)` so Dynamic Type still scales.
    public init(customFont: String) {
        self.customFontName = customFont
    }

    public static let `default` = CosmosTypographyTokens()

    /// Resolves a ``CosmosTextStyle`` to a Dynamic-Type-aware `Font`.
    public func font(for style: CosmosTextStyle) -> Font {
        guard let name = customFontName else {
            return .system(style.textStyle)
        }
        // Custom fonts MUST pass relativeTo: so they scale correctly with Dynamic Type.
        return .custom(name, size: style.pointSize, relativeTo: style.textStyle)
    }
}