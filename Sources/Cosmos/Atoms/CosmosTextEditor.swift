import SwiftUI

/// A text-editor atom wrapping `TextEditor` with token-driven style, tint, typography,
/// accessibility, and tracking.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. The visual variant
/// comes from ``CosmosTheme/textEditorStyle`` (default `.automatic`).
///
/// **Platform guard.** `TextEditor` — and `TextEditorStyle`/`.textEditorStyle(_:)` — are
/// `@available(iOS 17.0, macOS 14.0, visionOS 1.0, *)` and **unavailable on tvOS and watchOS**.
/// The entire atom, its inits, and the style applier are guarded `#if !os(tvOS) && !os(watchOS)`.
/// There is no in-place tvOS/watchOS fallback (app-level code chooses a `TextField` with
/// `axis: .vertical` there). The selector enum ``CosmosTextEditorStyle`` + the availability table
/// ``CosmosTextEditorAvailability`` are platform-agnostic (carried for API uniformity) so they
/// remain testable on any host.
///
/// **Per-style availability.** `.automatic`/`.plain` exist on iOS/macOS/visionOS; `.roundedBorder`
/// (`RoundedBorderTextEditorStyle`) is **visionOS-only** (unavailable on iOS/macOS) — the applier
/// guards it and falls back to `.automatic` where unavailable. `TextEditorStyleConfiguration` is
/// an **empty** opaque struct, so a custom conforming style cannot read text/selection inside
/// `makeBody`; Cosmos forwards the native built-ins only (no custom `CosmosTextEditorChrome`).
///
/// **Accessibility:** the native editor auto-exposes editable-text traits and the current text as
/// value; set `.cosmosAccessibilityLabel` for a descriptive label (TextEditor has no title).
/// Dynamic Type via `.font(theme.typography.font(for:))`.
///
/// **Haptics:** none — typing emits no native haptic and Cosmos adds none. **Motion:** `none` —
/// no Cosmos motion kind is applied (text edits are not motion-worthy; binding `valueChange` to
/// the text binding would fire per keystroke).
#if !os(tvOS) && !os(watchOS)
public struct CosmosTextEditor: View {
    private let text: Binding<String>

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    /// Creates a text editor bound to `text`.
    public init(text: Binding<String>) {
        self.text = text
    }

    public var body: some View {
        if configuration.enable.isVisible {
            TextEditor(text: text)
                .modifier(CosmosTextEditorStyleApplier(style: theme.textEditorStyle))
                .tint(theme.colors.accent)
                .font(theme.typography.font(for: theme.textStyle))
                .foregroundStyle(theme.colors.primary)
                .applyCosmosAccessibility(configuration.accessibility)
                .onAppear { trackAppear() }
        } else {
            EmptyView()
        }
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "texteditor_appear",
            component: "CosmosTextEditor",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}
#endif // !os(tvOS) && !os(watchOS) — atom above; availability table + applier below.

// MARK: - Per-platform availability table (pure, platform-agnostic, testable)

/// Pure per-platform availability table for ``CosmosTextEditorStyle`` at the Cosmos 26 floor.
/// `TextEditorStyle` itself is unavailable on tvOS/watchOS (every style `false` there). Within the
/// native platforms, `.roundedBorder` (`RoundedBorderTextEditorStyle`) is **visionOS-only**.
///
/// Derived from the Xcode 27 `.swiftinterface`:
/// - `.automatic` (`AutomaticTextEditorStyle`): iOS 17/macOS 14/visionOS 1.
/// - `.plain` (`PlainTextEditorStyle`): iOS 17/macOS 14/visionOS 1.
/// - `.roundedBorder` (`RoundedBorderTextEditorStyle`): **visionOS 1 only**.
public enum CosmosTextEditorAvailability {
    public static func isAvailable(_ style: CosmosTextEditorStyle, on platform: CosmosPlatform) -> Bool {
        switch platform {
        case .tvos, .watchos:
            return false
        case .ios, .macos:
            switch style {
            case .automatic, .plain: return true
            case .roundedBorder: return false
            }
        case .visionos:
            switch style {
            case .automatic, .plain, .roundedBorder: return true
            }
        }
    }

    /// Resolves a requested style to itself when available on `platform`, else `.automatic`.
    public static func resolve(_ style: CosmosTextEditorStyle, on platform: CosmosPlatform) -> CosmosTextEditorStyle {
        isAvailable(style, on: platform) ? style : .automatic
    }
}

// MARK: - Style resolution (native platforms only)

#if !os(tvOS) && !os(watchOS)
/// Resolves a ``CosmosTextEditorStyle`` to a concrete native `TextEditorStyle`, guarding
/// `.roundedBorder` (visionOS-only) and falling back to `.automatic` where unavailable.
private struct CosmosTextEditorStyleApplier: ViewModifier {
    let style: CosmosTextEditorStyle
    func body(content: Content) -> some View {
        switch style {
        case .automatic:
            content.textEditorStyle(.automatic)
        case .plain:
            content.textEditorStyle(.plain)
        case .roundedBorder:
            #if os(visionOS)
            content.textEditorStyle(.roundedBorder)
            #else
            // .roundedBorder (RoundedBorderTextEditorStyle) is visionOS-only — fall back to .automatic.
            content.textEditorStyle(.automatic)
            #endif
        }
    }
}
#endif

// MARK: - Previews (TextEditor is unavailable on tvOS/watchOS — guard the preview blocks)

#if !os(tvOS) && !os(watchOS)
#Preview("Text editor – styles") {
    @Previewable @State var text = ""
    VStack(spacing: 16) {
        CosmosTextEditor(text: $text).cosmosTextEditorStyle(.automatic)
        CosmosTextEditor(text: $text).cosmosTextEditorStyle(.plain)
        CosmosTextEditor(text: $text).cosmosTextEditorStyle(.roundedBorder)
    }
    .padding()
    .frame(minHeight: 220)
}

#Preview("Text editor – dark + accessibility size", traits: .sizeThatFitsLayout) {
    @Previewable @State var text = CosmosMock.sentence(wordCount: 12)
    CosmosPreviewContainer {
        CosmosTextEditor(text: $text).cosmosTextEditorStyle(.plain)
            .frame(minHeight: 180)
            .padding()
            .cosmosPreviewVariant(.dark)
            .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}
#endif // !os(tvOS) && !os(watchOS)