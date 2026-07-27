import SwiftUI

/// An icon atom wrapping `Image` with token-driven foreground style + typography, accessibility,
/// tracking, and a caller-driven symbol-effect surface.
///
/// `Image` has **no style protocol** (there is no `ImageStyle`), so this atom wraps a `View` per
/// the Cosmos wrap-view discipline. The Image-returning configuration methods (`.resizable`,
/// `.renderingMode`, `.symbolRenderingMode`, `.interpolation`, `.antialiased`, and the
/// watchOS-unavailable `.allowedDynamicRange`) return `Image` and so must be applied **inside**
/// the icon content — use the generic ``init(icon:)`` for that. The View-returning surface
/// (`.foregroundStyle`, `.font`, `.imageScale`, `.symbolVariant`, `.symbolEffect`, `.frame`,
/// `.clipShape`, …) is composed by the atom / caller as ordinary modifiers.
///
/// **Color override.** The atom applies ``CosmosColorTokens/primary`` as the default foreground
/// style. Because `.foregroundStyle` resolves to the *nearest* ancestor that sets it, a color
/// applied inside the icon content (e.g. `CosmosIcon { Image(systemName: "star").foregroundStyle(.red) }`)
/// is closer to the `Image` and wins; the theme color is only the fallback for the plain
/// convenience inits. SF Symbol size follows ``CosmosTheme/textStyle`` via `.font`.
///
/// **Accessibility:** SF Symbols may announce the raw symbol name to VoiceOver — always set an
/// explicit label via `.cosmosAccessibilityLabel(_:)` for meaningful symbols, or use the
/// decorative inits (`decorativeSystemName:` for SF Symbols, `decorative:bundle:` for asset
/// images) for purely decorative ones — both hide the image from VoiceOver. The
/// `.isImage` trait is applied natively by `Image`; the atom does not double-apply it. **Motion:**
/// `none`; `.symbolEffect` is caller-driven and auto-respects Reduce Motion (gate on
/// `configuration.motion.isEnabled` only — do not double-gate). **Haptics:** none — when used as a
/// Button/Toggle label, the controlling style owns the haptic.
///
/// - Deprecated: ``CosmosIcon`` is superseded by ``CosmosImage`` (the unified image atom) and
///   will be removed in a future Cosmos major. Migrate: `CosmosIcon(systemName:)` →
///   `CosmosImage(systemName:)`; the custom `init(icon:)` → `init(content:)`; asset `init(_:bundle:)`
///   → `CosmosImage(_:bundle:)`; decorative variants map 1:1. CosmosImage also covers typed
///   `ImageResource` and remote (URL) images.
@available(*, deprecated, message: "CosmosIcon is deprecated and will be removed in a future Cosmos major. Use CosmosImage — init(systemName:) for SF Symbols, init(_:) for ImageResource, init(url:) for remote images.")
public struct CosmosIcon<Icon: View>: View {
    @ViewBuilder private let icon: () -> Icon
    /// `true` for the decorative SF Symbol convenience (no native `Image(decorativeSystemName:)`
    /// exists); the body hides it from VoiceOver regardless of the accessibility config.
    private let isDecorativeSymbol: Bool

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    /// Creates an icon from custom icon content (apply `.resizable`/`.renderingMode`/etc. inside).
    ///
    /// - Deprecated: Use ``CosmosImage/init(content:)``.
    @available(*, deprecated, message: "CosmosIcon is deprecated and will be removed in a future Cosmos major. Use CosmosImage — init(systemName:) for SF Symbols, init(_:) for ImageResource, init(url:) for remote images.")
    public init(@ViewBuilder icon: @escaping () -> Icon) {
        self.icon = icon
        self.isDecorativeSymbol = false
    }

    /// Creates an SF Symbol icon. Set an explicit `.cosmosAccessibilityLabel` for meaningful
    /// symbols (VoiceOver may otherwise announce the raw symbol name).
    ///
    /// - Deprecated: Use ``CosmosImage/init(systemName:)``.
    @available(*, deprecated, message: "CosmosIcon is deprecated and will be removed in a future Cosmos major. Use CosmosImage — init(systemName:) for SF Symbols, init(_:) for ImageResource, init(url:) for remote images.")
    public init(systemName: String) where Icon == Image {
        self.icon = { Image(systemName: systemName) }
        self.isDecorativeSymbol = false
    }

    /// Creates a variable-color SF Symbol icon (iOS 16+). `variableValue` in `[0, 1]`.
    ///
    /// - Deprecated: Use ``CosmosImage/init(systemName:variableValue:)``.
    @available(*, deprecated, message: "CosmosIcon is deprecated and will be removed in a future Cosmos major. Use CosmosImage — init(systemName:) for SF Symbols, init(_:) for ImageResource, init(url:) for remote images.")
    public init(systemName: String, variableValue: Double) where Icon == Image {
        self.icon = { Image(systemName: systemName, variableValue: variableValue) }
        self.isDecorativeSymbol = false
    }

    /// Creates a decorative SF Symbol icon — hidden from VoiceOver (no label announced). SwiftUI
    /// has no `Image(decorativeSystemName:)`, so the atom hides it via the accessibility config.
    ///
    /// - Deprecated: Use ``CosmosImage/init(decorativeSystemName:)``.
    @available(*, deprecated, message: "CosmosIcon is deprecated and will be removed in a future Cosmos major. Use CosmosImage — init(systemName:) for SF Symbols, init(_:) for ImageResource, init(url:) for remote images.")
    public init(decorativeSystemName name: String) where Icon == Image {
        self.icon = { Image(systemName: name) }
        self.isDecorativeSymbol = true
    }

    /// Creates an icon from a bundled asset image name.
    ///
    /// - Deprecated: Use ``CosmosImage/init(_:bundle:)``.
    @available(*, deprecated, message: "CosmosIcon is deprecated and will be removed in a future Cosmos major. Use CosmosImage — init(systemName:) for SF Symbols, init(_:) for ImageResource, init(url:) for remote images.")
    public init(_ name: String, bundle: Bundle? = nil) where Icon == Image {
        self.icon = { Image(name, bundle: bundle) }
        self.isDecorativeSymbol = false
    }

    /// Creates a decorative asset image icon — natively hidden from VoiceOver (no label announced).
    ///
    /// - Deprecated: Use ``CosmosImage/init(decorative:bundle:)``.
    @available(*, deprecated, message: "CosmosIcon is deprecated and will be removed in a future Cosmos major. Use CosmosImage — init(systemName:) for SF Symbols, init(_:) for ImageResource, init(url:) for remote images.")
    public init(decorative name: String, bundle: Bundle? = nil) where Icon == Image {
        self.icon = { Image(decorative: name, bundle: bundle) }
        self.isDecorativeSymbol = false
    }

    public var body: some View {
        if configuration.enable.isVisible {
            icon()
                .foregroundStyle(theme.colors.primary)
                .font(theme.typography.font(for: theme.textStyle))
                .accessibilityHiddenIf(isDecorativeSymbol)
                .applyCosmosAccessibility(configuration.accessibility)
                .onAppear { trackAppear() }
        } else {
            EmptyView()
        }
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "icon_appear",
            component: "CosmosIcon",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}