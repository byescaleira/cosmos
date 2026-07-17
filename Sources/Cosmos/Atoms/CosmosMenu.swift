import SwiftUI

/// A menu atom wrapping `Menu` with token-driven trigger styling, accessibility, tracking, and
/// an optional primary action — plus a `CosmosButton` fallback on watchOS (where `Menu` is
/// unavailable).
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. The trigger variant
/// comes from ``CosmosTheme/menuStyle`` (default `.automatic`); `.button` resolves to
/// `ButtonMenuStyle`. The popover content list is opaque (`MenuStyleConfiguration.Content`/`.Label`
/// `Body == Never`) and is **never** decomposed — only the trigger's surrounding chrome is
/// token-driven here.
///
/// **Platform guard.** `Menu` (and `.menuStyle(_:)`) are `@available(watchOS, unavailable)`; the
/// tvOS floor is 17.0 (below the Cosmos 26 floor — available at `.v26`; comment for floor-lowering).
/// The Menu-backed body is guarded `#if !os(watchOS)`; on watchOS the atom renders a `CosmosButton`
/// fallback whose action is the primary action (or a no-op for a plain menu — app-level code may
/// choose a richer overflow surface). Platform-availability of the secondary modifiers
/// (`.menuOrder(.priority)`, `.menuActionDismissBehavior(.disabled)`) is exposed as pure
/// predicates in ``CosmosMenuAvailability``; the atom does not force them — they are caller-driven.
///
/// **Haptics:** a plain (no-primary) menu emits none on open (Apple menus do not haptic on open;
/// contained Buttons own theirs). A primary-action menu fires a `.selection` haptic on the primary
/// tap (or `.impact(.rigid)` when destructive — see ``CosmosMenuAccessibility/primaryActionFeedback(isDestructive:)``),
/// gated by ``CosmosHapticsPolicy`` via `.cosmosHaptic`. **Motion:** `press` for the primary tap —
/// the trigger press is the Cosmos-relevant motion (popover present/dismiss is native
/// system-controlled and is NOT gated from Cosmos). **Accessibility:** the trigger needs a
/// descriptive label (a Text/`Label` title suffices; set `.cosmosAccessibilityLabel` when icon-only);
/// a primary-action trigger carries `.isButton`.
public struct CosmosMenu<Label: View, Content: View>: View {
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let label: () -> Label
    private let primaryAction: (() -> Void)?

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var tapCounter = 0

    /// Creates a menu with custom content and a custom label view.
    public init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder label: @escaping () -> Label) {
        self.content = content
        self.label = label
        self.primaryAction = nil
    }

    /// Creates a menu with custom content/label whose trigger also performs a primary action
    /// (the tap fires the action; long-press/overflow opens the menu).
    public init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder label: @escaping () -> Label, primaryAction: @escaping () -> Void) {
        self.content = content
        self.label = label
        self.primaryAction = primaryAction
    }

    public var body: some View {
        if configuration.enable.isVisible {
            #if os(watchOS)
            // watchOS: Menu is unavailable — render a CosmosButton fallback (action = primary or no-op).
            CosmosButton(action: { primaryAction?() }, label: label)
                .applyCosmosAccessibility(configuration.accessibility, extraTraits: .isButton)
                .onAppear { trackAppear() }
            #else
            menuBody
            #endif
        } else {
            EmptyView()
        }
    }

    #if !os(watchOS)
    @ViewBuilder private var menuBody: some View {
        if let primaryAction {
            Menu(content: content, label: label, primaryAction: { performPrimary(primaryAction) })
                .modifier(CosmosMenuStyleApplier(style: theme.menuStyle))
                .tint(theme.colors.accent)
                .controlSize(theme.controlSize.controlSize)
                .font(theme.typography.font(for: theme.textStyle))
                .cosmosHaptic(CosmosMenuAccessibility.primaryActionFeedback(isDestructive: false), trigger: tapCounter)
                .onChange(of: tapCounter) { _, _ in emitPressMotion() }
                .applyCosmosAccessibility(configuration.accessibility, extraTraits: .isButton)
                .onAppear { trackAppear() }
        } else {
            Menu(content: content, label: label)
                .modifier(CosmosMenuStyleApplier(style: theme.menuStyle))
                .tint(theme.colors.accent)
                .controlSize(theme.controlSize.controlSize)
                .font(theme.typography.font(for: theme.textStyle))
                .applyCosmosAccessibility(configuration.accessibility)
                .onAppear { trackAppear() }
        }
    }

    private func performPrimary(_ action: () -> Void) {
        tapCounter &+= 1
        configuration.tracking.track(.init(
            name: "menu_primary_tap",
            component: "CosmosMenu",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .tap
        ))
        action()
    }

    private func emitPressMotion() {
        guard CosmosMotionPolicy.shouldEmit(
            isEnabled: configuration.motion.isEnabled,
            respectReduceMotion: configuration.motion.respectReduceMotion,
            reduceMotion: reduceMotion
        ) else { return }
        configuration.motion.handler(.motion(.press))
    }
    #endif

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "menu_appear",
            component: "CosmosMenu",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}

// MARK: - Convenience inits

extension CosmosMenu where Label == CosmosLocalizedText {
    /// Creates a menu from a localized String Catalog key header above custom content.
    public init(_ titleKey: String, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.label = { CosmosLocalizedText(key: titleKey) }
        self.primaryAction = nil
    }
}

extension CosmosMenu where Label == Text {
    /// Creates a menu from verbatim (non-localized) header text above custom content.
    public init<S: StringProtocol>(verbatim title: S, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.label = { Text(verbatim: String(title)) }
        self.primaryAction = nil
    }
}

extension CosmosMenu where Label == SwiftUI.Label<CosmosLocalizedText, Image> {
    /// Creates a menu from a localized String Catalog key + SF Symbol header above custom content.
    public init(_ titleKey: String, systemImage: String, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.label = { Label { CosmosLocalizedText(key: titleKey) } icon: { Image(systemName: systemImage) } }
        self.primaryAction = nil
    }
}

// MARK: - Style resolution + pure helpers (native platforms only)

/// Pure accessibility/availability helpers for menu rendering (testable without rendering views).
public enum CosmosMenuAccessibility {
    /// The haptic feedback for a primary-action tap: `.selection` by default, `.impact(.rigid)` when
    /// the action is destructive. Routed through `.cosmosHaptic` (gated by ``CosmosHapticsPolicy``).
    public static func primaryActionFeedback(isDestructive: Bool) -> CosmosHapticsFeedback {
        isDestructive ? .impact(weight: .rigid, intensity: nil) : .selection
    }
}

/// Pure platform-availability predicates for ``CosmosMenu``'s secondary modifiers. Compile-time
/// resolved against the Cosmos 26 floor.
public enum CosmosMenuAvailability {
    /// `true` where `.menuActionDismissBehavior(.disabled)` is available (iOS 16.4+/tvOS 17+/
    /// visionOS 1+); `false` on macOS/watchOS. At the Cosmos 26 floor the iOS/tvOS/visionOS gates
    /// are met, so this is a platform (not version) predicate.
    public static var supportsDismissBehaviorDisabled: Bool {
        #if os(macOS) || os(watchOS)
        return false
        #else
        return true
        #endif
    }

    /// `true` where `.menuOrder(.priority)` is available (iOS/visionOS); `false` on
    /// macOS/tvOS/watchOS.
    public static var supportsMenuOrderPriority: Bool {
        #if os(iOS) || os(visionOS)
        return true
        #else
        return false
        #endif
    }
}

#if !os(watchOS)
/// Resolves a ``CosmosMenuStyle`` to a concrete `MenuStyle`: `.automatic` → `DefaultMenuStyle`,
/// `.button` → `ButtonMenuStyle` (iOS 16+, available at the Cosmos 26 floor on all non-watchOS
/// platforms). The trigger's button chrome is customized at the atom level (`.tint`/`.controlSize`/
/// `.font` and, paired with `.button`, a caller `.buttonStyle`).
private struct CosmosMenuStyleApplier: ViewModifier {
    let style: CosmosMenuStyle
    func body(content: Content) -> some View {
        switch style {
        case .automatic: content.menuStyle(.automatic)
        case .button:    content.menuStyle(.button)
        }
    }
}
#endif

// MARK: - Previews

#Preview("Menu – styles") {
    VStack(spacing: 12) {
        CosmosMenu("preview.title") {
            Button {} label: { Label("preview.name", systemImage: "star") }
            Button {} label: { Label("preview.description", systemImage: "gear") }
        }
        CosmosMenu("preview.title") {
            Button {} label: { Label("preview.name", systemImage: "star") }
        }
        .cosmosMenuStyle(.button)
        CosmosMenu("preview.title", systemImage: "ellipsis.circle") {
            Button {} label: { Label("preview.name", systemImage: "star") }
        }
    }
    .padding()
}

#Preview("Menu – primary action") {
    VStack(spacing: 12) {
        CosmosMenu(content: {
            Button {} label: { Label("preview.name", systemImage: "star") }
        }, label: { Label("preview.title", systemImage: "plus") }, primaryAction: {})
            .cosmosMenuStyle(.button)
    }
    .padding()
}

#Preview("Menu – dark + accessibility size", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(spacing: 12) {
            CosmosMenu("preview.title") {
                Button {} label: { Label("preview.name", systemImage: "star") }
            }
            .cosmosMenuStyle(.button)
            CosmosMenu(verbatim: CosmosMock.sentence(), content: {
                Button {} label: { Label("preview.name", systemImage: "gear") }
            })
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}