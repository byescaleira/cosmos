import SwiftUI

/// Font presets backed by bundled fonts.
///
/// The `.default` preset uses the system font. Custom presets register their bundled
/// `.ttf` via ``CosmosFont`` and resolve through ``CosmosTypographyTokens/font(for:)``,
/// always passing `relativeTo:` so custom fonts scale with Dynamic Type (including
/// accessibility sizes).
public enum CosmosFontPreset: String, Sendable, Codable, CaseIterable {
    case `default`
    case dmSans
    case spaceGrotesk
    case jetBrainsMono

    /// PostScript name of the regular-weight face, or `nil` for the system preset.
    var regularName: String? {
        switch self {
        case .default: return nil
        case .dmSans: return "DMSans-Regular"
        case .spaceGrotesk: return "SpaceGrotesk-Regular"
        case .jetBrainsMono: return "JetBrainsMono-Regular"
        }
    }
}

/// Semantic typography tokens.
///
/// ``font(for:)`` resolves a ``CosmosTextStyle`` to a `Font`, preserving Dynamic Type
/// scaling for both system and custom fonts.
public struct CosmosTypographyTokens: Sendable {
    /// The active font preset.
    public var preset: CosmosFontPreset

    public init(preset: CosmosFontPreset = .default) {
        self.preset = preset
    }

    public static let `default` = CosmosTypographyTokens(preset: .default)

    /// Resolves a ``CosmosTextStyle`` to a Dynamic-Type-aware `Font`.
    public func font(for style: CosmosTextStyle) -> Font {
        guard let name = preset.regularName else {
            return .system(style.textStyle)
        }
        // Custom fonts MUST pass relativeTo: so they scale correctly with Dynamic Type.
        return .custom(name, size: style.pointSize, relativeTo: style.textStyle)
    }
}