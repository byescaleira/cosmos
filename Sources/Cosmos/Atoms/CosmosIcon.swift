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
/// `decorative:` init (which natively hides the image) for purely decorative ones. The
/// `.isImage` trait is applied natively by `Image`; the atom does not double-apply it. **Motion:**
/// `none`; `.symbolEffect` is caller-driven and auto-respects Reduce Motion (gate on
/// `configuration.motion.isEnabled` only — do not double-gate). **Haptics:** none — when used as a
/// Button/Toggle label, the controlling style owns the haptic.
public struct CosmosIcon<Icon: View>: View {
    @ViewBuilder private let icon: () -> Icon

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    /// Creates an icon from custom icon content (apply `.resizable`/`.renderingMode`/etc. inside).
    public init(@ViewBuilder icon: @escaping () -> Icon) {
        self.icon = icon
    }

    public var body: some View {
        if configuration.enable.isVisible {
            icon()
                .foregroundStyle(theme.colors.primary)
                .font(theme.typography.font(for: theme.textStyle))
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

// MARK: - Convenience inits (Icon == Image)

extension CosmosIcon where Icon == Image {
    /// Creates an SF Symbol icon. Set an explicit `.cosmosAccessibilityLabel` for meaningful
    /// symbols (VoiceOver may otherwise announce the raw symbol name).
    public init(systemName: String) {
        self.icon = { Image(systemName: systemName) }
    }

    /// Creates a variable-color SF Symbol icon (iOS 16+). `variableValue` in `[0, 1]`.
    public init(systemName: String, variableValue: Double) {
        self.icon = { Image(systemName: systemName, variableValue: variableValue) }
    }

    /// Creates an icon from a bundled asset image name.
    public init(_ name: String, bundle: Bundle? = nil) {
        self.icon = { Image(name, bundle: bundle) }
    }

    /// Creates a decorative asset image icon — natively hidden from VoiceOver (no label announced).
    public init(decorative name: String, bundle: Bundle? = nil) {
        self.icon = { Image(decorative: name, bundle: bundle) }
    }
}

// MARK: - Previews

#Preview("Icon – SF Symbols + text styles") {
    VStack(spacing: 12) {
        CosmosIcon(systemName: "star.fill").cosmosTextStyle(.largeTitle)
        CosmosIcon(systemName: "gearshape").cosmosTextStyle(.title)
        CosmosIcon(systemName: "bell.badge.fill").cosmosTextStyle(.headline)
        CosmosIcon(systemName: "battery.25", variableValue: 0.25).cosmosTextStyle(.title)
    }
    .padding()
}

#Preview("Icon – color override inside content") {
    VStack(spacing: 12) {
        // Default theme color.
        CosmosIcon(systemName: "heart.fill")
        // Override wins (foregroundStyle inside the content is closer to the Image).
        CosmosIcon { Image(systemName: "heart.fill").foregroundStyle(.red) }
        // Resizable asset-style + symbol rendering mode, configured inside the content.
        CosmosIcon { Image(systemName: "person.crop.circle.fill").resizable().symbolRenderingMode(.hierarchical) }
            .frame(width: 48, height: 48)
    }
    .padding()
}

#Preview("Icon – dark + accessibility size + label", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(spacing: 12) {
            CosmosIcon(systemName: "wand.and.stars")
                .cosmosTextStyle(.title)
                .cosmosAccessibilityLabel("Magic")
            CosmosIcon(systemName: "sparkles").cosmosTextStyle(.headline)
            CosmosIcon { Image(systemName: "trophy.fill").foregroundStyle(.yellow) }
                .cosmosTextStyle(.largeTitle)
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}