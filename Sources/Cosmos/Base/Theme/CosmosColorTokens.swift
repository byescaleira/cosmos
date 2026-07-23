import SwiftUI

/// Semantic, adaptive color tokens.
///
/// Defaults are platform-conditional. **No UIKit symbols are authored**: on iOS/tvOS,
/// `Color(.label)` / `Color(.systemBackground)` resolve UIKit-backed dynamic colors without
/// importing UIKit; on macOS the AppKit equivalents are used via `Color(nsColor:)`; on
/// watchOS/visionOS, SwiftUI's adaptive `Color.primary`/`.secondary` and materials fill in.
///
/// High-contrast variants are surfaced through an asset catalog at the app layer. Atoms do
/// not yet adapt at runtime via `@Environment(\.colorSchemeContrast)` / `ShapeStyle.resolve(in:)`
/// — that increased-contrast gate is a tracked gap (see the vault risks index), not a current
/// behavior.
public struct CosmosColorTokens: Sendable {
    /// Primary foreground content (high-emphasis text/icons).
    public var primary: Color
    /// Secondary foreground content (medium-emphasis).
    public var secondary: Color
    /// Accent / tint color for controls.
    public var accent: Color
    /// Root background behind all content.
    public var background: Color
    /// Elevated surface (cards, sheets).
    public var surface: Color
    /// Success state.
    public var success: Color
    /// Warning state.
    public var warning: Color
    /// Error / destructive state.
    public var error: Color
    /// Hairlines, borders, dividers.
    public var outline: Color

    public init(
        primary: Color,
        secondary: Color,
        accent: Color,
        background: Color,
        surface: Color,
        success: Color,
        warning: Color,
        error: Color,
        outline: Color
    ) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.background = background
        self.surface = surface
        self.success = success
        self.warning = warning
        self.error = error
        self.outline = outline
    }

    public static let `default` = CosmosColorTokens(
        primary: .cosmosForegroundPrimary,
        secondary: .cosmosForegroundSecondary,
        accent: .cosmosAccent,
        background: .cosmosBackground,
        surface: .cosmosSurface,
        success: .cosmosSuccess,
        warning: .cosmosWarning,
        error: .cosmosError,
        outline: .cosmosOutline
    )
}

// MARK: - Platform-conditional defaults (no UIKit symbols authored)

extension Color {
    static var cosmosForegroundPrimary: Color {
        #if os(iOS) || os(tvOS)
        return Color(.label)
        #elseif os(macOS)
        return Color(nsColor: .labelColor)
        #else
        return .primary
        #endif
    }

    static var cosmosForegroundSecondary: Color {
        #if os(iOS) || os(tvOS)
        return Color(.secondaryLabel)
        #elseif os(macOS)
        return Color(nsColor: .secondaryLabelColor)
        #else
        return .secondary
        #endif
    }

    static var cosmosAccent: Color {
        #if os(iOS) || os(tvOS)
        return Color(.systemBlue)
        #elseif os(macOS)
        return Color(nsColor: .systemBlue)
        #else
        return .blue
        #endif
    }

    static var cosmosBackground: Color {
        #if os(iOS)
        return Color(.systemBackground)
        #elseif os(macOS)
        return Color(nsColor: .textBackgroundColor)
        #else
        // tvOS/watchOS/visionOS: no `systemBackground` symbol; dark-first platforms default to black.
        return Color.black
        #endif
    }

    static var cosmosSurface: Color {
        #if os(iOS)
        return Color(.secondarySystemBackground)
        #elseif os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #else
        // tvOS/watchOS/visionOS: a subtle translucent surface substitute.
        return Color.gray.opacity(0.2)
        #endif
    }

    static var cosmosSuccess: Color {
        #if os(iOS) || os(tvOS)
        return Color(.systemGreen)
        #elseif os(macOS)
        return Color(nsColor: .systemGreen)
        #else
        return .green
        #endif
    }

    static var cosmosWarning: Color {
        #if os(iOS) || os(tvOS)
        return Color(.systemOrange)
        #elseif os(macOS)
        return Color(nsColor: .systemOrange)
        #else
        return .orange
        #endif
    }

    static var cosmosError: Color {
        #if os(iOS) || os(tvOS)
        return Color(.systemRed)
        #elseif os(macOS)
        return Color(nsColor: .systemRed)
        #else
        return .red
        #endif
    }

    static var cosmosOutline: Color {
        #if os(iOS) || os(tvOS)
        return Color(.separator)
        #elseif os(macOS)
        return Color(nsColor: .separatorColor)
        #else
        return Color.gray.opacity(0.4)
        #endif
    }
}