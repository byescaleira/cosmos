import SwiftUI

/// Semantic color tokens used by Cosmos components.
///
/// Defaults rely on SwiftUI system color roles so the design system feels
/// native on every platform and adapts automatically to light/dark mode.
/// Custom palettes can replace any token through the environment.
public struct CosmosColorTokens: Sendable, Equatable {
    /// Primary text and icon color.
    public var primary: Color

    /// Secondary text and icon color.
    public var secondary: Color

    /// Accent color for interactive elements.
    public var accent: Color

    /// Default background color.
    public var background: Color

    /// Elevated surface color (cards, sheets).
    public var surface: Color

    /// Success state color.
    public var success: Color

    /// Warning state color.
    public var warning: Color

    /// Error state color.
    public var error: Color

    /// Creates a color token collection.
    public init(
        primary: Color = .primary,
        secondary: Color = .secondary,
        accent: Color = .accentColor,
        background: Color = defaultBackground,
        surface: Color = defaultSurface,
        success: Color = .green,
        warning: Color = .yellow,
        error: Color = .red
    ) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.background = background
        self.surface = surface
        self.success = success
        self.warning = warning
        self.error = error
    }

    /// The default color token collection.
    public static let `default` = CosmosColorTokens()

    @usableFromInline
    internal static var defaultBackground: Color {
        #if os(iOS) || os(tvOS) || os(visionOS)
        Color(uiColor: .systemBackground)
        #elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        .clear
        #endif
    }

    @usableFromInline
    internal static var defaultSurface: Color {
        #if os(iOS) || os(tvOS) || os(visionOS)
        Color(uiColor: .secondarySystemBackground)
        #elseif os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        .clear
        #endif
    }
}
