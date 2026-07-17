import SwiftUI

/// A group box atom wrapping `GroupBox` with token-driven chrome, accessibility, and tracking —
/// plus a plain fallback on the platforms where `GroupBox` is unavailable.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. The visual variant
/// comes from ``CosmosTheme/groupBoxStyle`` (default `.automatic`); `.cosmos` routes through the
/// custom conforming ``CosmosGroupBoxChrome``.
///
/// **Platform guard.** `GroupBox`, `GroupBoxStyle`, and `.groupBoxStyle(_:)` are all
/// `@available(tvOS, unavailable)` / `@available(watchOS, unavailable)` (the SDK marks both
/// unavailable despite Apple docs listing tvOS 14+/watchOS 7+). The public API stays uniform on
/// all 5 platforms: on tvOS/watchOS the atom renders a plain fallback (the label as a themed
/// header above the content in a `VStack` with theme padding — no GroupBox chrome); on
/// iOS/macOS/visionOS it renders the native `GroupBox` + style. The selection between the two is
/// the compile-time platform predicate ``CosmosGroupBoxAvailability/hasNativeGroupBox``.
///
/// **Accessibility:** do NOT force `.isContainer` (would duplicate SwiftUI's grouping) — child
/// atoms carry their own labels/traits; Dynamic Type reflows through the label/content (ordinary
/// Views). **Haptics:** none — static grouping container. **Motion:** `none`; a custom style may
/// add `.cosmosTransition(.containerTransform)` at the call site (caller-driven, single
/// `withAnimation`). `GroupBoxStyle` is `@preconcurrency @MainActor`; the conforming
/// ``CosmosGroupBoxChrome`` holds no non-Sendable state and its body is a `View` (MainActor).
public struct CosmosGroupBox<Label: View, Content: View>: View {
    @ViewBuilder private let label: () -> Label
    @ViewBuilder private let content: () -> Content

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    /// Creates a group box with custom content and a custom label view.
    public init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder label: @escaping () -> Label) {
        self.label = label
        self.content = content
    }

    public var body: some View {
        if configuration.enable.isVisible {
            boxContent
                .applyCosmosAccessibility(configuration.accessibility)
                .onAppear { trackAppear() }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder private var boxContent: some View {
        #if os(tvOS) || os(watchOS)
        // tvOS/watchOS: GroupBox is unavailable — render a plain themed fallback (label header
        // above content). No GroupBox symbols are referenced here.
        VStack(alignment: .leading, spacing: CosmosSpacingTokens.small) {
            label()
                .font(theme.typography.font(for: .headline))
                .foregroundStyle(theme.colors.primary)
            content()
        }
        .padding(CosmosSpacingTokens.value(for: theme.padding))
        #else
        // iOS/macOS/visionOS: native GroupBox + style.
        GroupBox(content: content, label: label)
            .modifier(CosmosGroupBoxStyleApplier(style: theme.groupBoxStyle))
        #endif
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "groupbox_appear",
            component: "CosmosGroupBox",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}

// MARK: - Convenience inits

extension CosmosGroupBox where Label == EmptyView {
    /// Creates a group box with content only (no header label).
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.label = { EmptyView() }
        self.content = content
    }
}

extension CosmosGroupBox where Label == CosmosLocalizedText {
    /// Creates a group box from a localized String Catalog key (resolved via the configuration)
    /// header above custom content.
    public init(_ titleKey: String, @ViewBuilder content: @escaping () -> Content) {
        self.label = { CosmosLocalizedText(key: titleKey) }
        self.content = content
    }
}

extension CosmosGroupBox where Label == Text {
    /// Creates a group box from verbatim (non-localized) header text above custom content.
    public init<S: StringProtocol>(verbatim title: S, @ViewBuilder content: @escaping () -> Content) {
        self.label = { Text(verbatim: String(title)) }
        self.content = content
    }
}

// MARK: - Availability predicate + style resolution (native platforms only)

/// Pure platform predicate for the GroupBox fallback branch — testable without rendering.
public enum CosmosGroupBoxAvailability {
    /// `true` on platforms where `GroupBox` + `.groupBoxStyle(_:)` are available
    /// (iOS/macOS/visionOS); `false` on tvOS/watchOS (plain fallback). Compile-time resolved.
    public static var hasNativeGroupBox: Bool {
        #if os(tvOS) || os(watchOS)
        return false
        #else
        return true
        #endif
    }
}

#if !os(tvOS) && !os(watchOS)
/// Resolves a ``CosmosGroupBoxStyle`` to a concrete `GroupBoxStyle`: `.automatic` delegates to the
/// native `DefaultGroupBoxStyle`; `.cosmos` routes through the custom ``CosmosGroupBoxChrome``.
private struct CosmosGroupBoxStyleApplier: ViewModifier {
    let style: CosmosGroupBoxStyle
    func body(content: Content) -> some View {
        switch style {
        case .automatic: content.groupBoxStyle(.automatic)
        case .cosmos:    content.groupBoxStyle(CosmosGroupBoxChrome())
        }
    }
}

/// Custom `GroupBoxStyle` composing `configuration.label` (themed header) above
/// `configuration.content` with a token-driven surface background + padding. The pieces are
/// opaque (`Body == Never`) so they are composed only — never introspected.
public struct CosmosGroupBoxChrome: GroupBoxStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        CosmosGroupBoxChromeBody(configuration: configuration)
    }
}

private struct CosmosGroupBoxChromeBody: View {
    let configuration: GroupBoxStyle.Configuration
    @Environment(\.cosmosTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: CosmosSpacingTokens.small) {
            configuration.label
                .font(theme.typography.font(for: .headline))
                .foregroundStyle(theme.colors.primary)
            configuration.content
        }
        .padding(CosmosSpacingTokens.value(for: theme.padding))
        .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
    }
}
#endif

// MARK: - Previews

#Preview("Group box – styles") {
    VStack(spacing: 16) {
        CosmosGroupBox("preview.title") {
            CosmosText("preview.description").cosmosTextStyle(.body)
        }
        CosmosGroupBox("preview.title") {
            CosmosText("preview.description").cosmosTextStyle(.body)
        }
        .cosmosGroupBoxStyle(.cosmos)
        CosmosGroupBox {
            CosmosText("preview.description").cosmosTextStyle(.body)
        }
    }
    .padding()
}

#Preview("Group box – dark + accessibility size", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(spacing: 16) {
            CosmosGroupBox("preview.title") {
                CosmosText("preview.description").cosmosTextStyle(.body)
            }
            .cosmosGroupBoxStyle(.cosmos)
            CosmosGroupBox(verbatim: CosmosMock.sentence(), content: {
                CosmosText("preview.description").cosmosTextStyle(.body)
            })
            .cosmosGroupBoxStyle(.cosmos)
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}