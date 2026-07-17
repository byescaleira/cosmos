import SwiftUI

/// A tab-view atom wrapping the modern `TabContentBuilder`-based `TabView` with a token-driven
/// (per-platform-safe) style, tint, accessibility, and a selection haptic.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration`` from
/// the environment and overrides per-instance via `.cosmos*` modifiers. The visual variant comes
/// from ``CosmosTheme/tabViewStyle`` (default `.automatic`).
///
/// **Why a wrap-view, not a style conformance.** `TabViewStyle` is **opaque / native-bridged** — only
/// underscored `_makeView`/`_makeViewList`; no `makeBody`, no `Configuration` associatedtype (compare
/// `TableStyle`, which has them). A Cosmos struct cannot implement the underscored requirements
/// (their parameter types are internal to SwiftUI). Cosmos wraps a `View` that configures a native
/// `TabView` and applies a built-in style via the applier.
///
/// **Modern inits only.** Exposes the `TabContentBuilder` inits (iOS 18 / macOS 15 / tvOS 18 /
/// watchOS 11 / visionOS 2 — universal at the Cosmos 26 floor). The legacy `init(selection: Binding?,
/// @ViewBuilder content:)` and `.tabItem { }` are `@available(..., deprecated: 100000.0)` → using
/// them would violate zero-warnings; they are NOT exposed. (`.tag(_:)` is **not** deprecated — but
/// `Tab(value:)` already supplies the selection identity, so it is unneeded with `Tab`.) The legacy
/// `init(@ViewBuilder content:)` where `SelectionValue == Int` is superseded and not exposed (its
/// labeling partner `.tabItem` is deprecated).
///
/// **Per-style availability.** Each built-in `TabViewStyle` fragments across platforms (see
/// ``CosmosTabViewAvailability``). The applier guards each case with `#if os()` and falls back to
/// `.automatic` where a requested style is unavailable — never blindly forwards a user-chosen
/// style. All version bounds are ≤ the Cosmos 26 floor → `#if os()` only, no runtime
/// `if #available`. `CarouselTabViewStyle` (`.carousel`) is
/// `@available(..., deprecated: 100000.0, renamed: "VerticalTabViewStyle")` and is **never**
/// referenced — `.verticalPage` is its replacement.
///
/// **Selecting content.** Inside the `@TabContentBuilder` content closure, callers use the native
/// `Tab` / `TabSection` primitives directly (Cosmos does not wrap `Tab`). `TabRole` is passed to
/// `Tab(role:)` via ``CosmosTabRole`` — `.search` (floor, all 5) and `.prominent` (OS 27 / Cosmos 27,
/// all 5, runtime-gated to `nil` below OS 27). There is no native `.tabRole(_:)` modifier, so
/// ``CosmosTabRole/nativeRole()`` returns the `TabRole?` to pass into `Tab(role:)`.
///
/// **Generic shape.** `CosmosTabView<SelectionValue, Content>`: `SelectionValue` is constrained
/// **`Hashable & Sendable`** (matching native `TabView`'s `Hashable`, plus `Sendable` to drive
/// `.cosmosHaptic(.selection, trigger:)`). The non-selectable init pins `SelectionValue == Never`.
/// Because the selectable and non-selectable `TabView` inits construct structurally different view
/// types (a `Binding`-driven `TabView<SelectionValue, _>` vs a `TabView<Never, _>`), the native
/// `TabView` is built in each init — where the per-init constraints are concrete — and type-erased
/// to `AnyView`; env-driven modifiers and the selection haptic are applied in `body` (where the
/// trigger is read fresh each render).
///
/// **Customization limits.** No custom tab bar — `TabViewStyle` is not conformable. Tab bar
/// appearance (background, item fonts, bar height, indicator) is opaque; rely on `.tint` (applied
/// here from `theme.colors.accent`) and system Liquid Glass defaults. Per-instance chrome is
/// available via ``cosmosTabViewCustomization(_:)``, ``cosmosTabBarMinimizeBehavior(_:)``, and
/// ``cosmosTabViewBottomAccessory(_:)``.
///
/// **Accessibility:** each `Tab`/`TabSection` label auto-exposes its accessibility label; tab bar
/// items get a button trait natively; VoiceOver announces the focused tab and selection changes.
/// Apply `.cosmosAccessibilityLabel`/`.Identifier` here for the container; per-tab
/// `.accessibilityIdentifier` is caller-driven (and is the recommended tracking anchor). Dynamic
/// Type scales tab labels; page-index dots do not scale. tvOS tabs are focus-engine driven.
///
/// **Haptics:** `.selection` on `selection.wrappedValue` change via `.cosmosHaptic(_:trigger:)`,
/// gated through ``CosmosHapticsPolicy`` (config + Reduce Motion); no-op without hardware. The
/// non-selectable variant emits no haptic (no selection binding). **Motion:** `tabSwitch` is the
/// mapped kind, but the atom does **not** layer `.cosmosAnimation(.tabSwitch, value:)` on the
/// `TabView` — native tab switching (and `PageTabViewStyle` swipe) is system-driven; a differing
/// curve would desync (same rule as `CosmosPicker`/`CosmosSection`). Callers coordinate a tab
/// switch with a single `withAnimation(theme.motion.spring(for: .containerTransform).animation)
/// { selection = newValue }` around the binding write, or apply `.cosmosContentTransition(.tabSwitch)`
/// to per-tab content — never per-view `.animation(_:value:)` with differing curves. **Tracking:**
/// none at the container — tracking is per-tab via caller-set `.accessibilityIdentifier`
/// (structural-container rule, like `CosmosSection`/`CosmosList`).
public struct CosmosTabView<SelectionValue: Hashable & Sendable, Content: View>: View {
    /// Type-erased native `TabView` built in the init (selectable vs non-selectable differ in type).
    private let resolved: AnyView
    /// `nil` for the non-selectable variant; the selection haptic fires only when non-nil.
    private let selection: Binding<SelectionValue>?

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    /// Creates a selectable tab view driven by a `Hashable & Sendable` selection binding, with
    /// modern `Tab`/`TabSection` content.
    public init<C>(
        selection: Binding<SelectionValue>,
        @TabContentBuilder<SelectionValue> content: @escaping () -> C
    ) where Content == TabContentBuilder<SelectionValue>.Content<C>, C: TabContent {
        self.selection = selection
        self.resolved = AnyView(TabView(selection: selection, content: content))
    }

    /// Creates a non-selectable tab view (e.g. a paged view) with modern `Tab`/`TabSection` content
    /// whose `Tab` values are `Never`.
    public init<C>(
        @TabContentBuilder<Never> content: @escaping () -> C
    ) where SelectionValue == Never, Content == TabContentBuilder<Never>.Content<C>, C: TabContent {
        self.selection = nil
        self.resolved = AnyView(TabView(content: content))
    }

    public var body: some View {
        if configuration.enable.isVisible {
            resolved
                .modifier(CosmosTabViewStyleApplier(style: theme.tabViewStyle))
                .tint(theme.colors.accent)
                .applyCosmosAccessibility(configuration.accessibility)
                .modifier(CosmosTabHapticGate(selection: selection))
        } else {
            EmptyView()
        }
    }
}

// MARK: - Selection haptic (applied in body so the trigger stays fresh each render)

/// Applies `.cosmosHaptic(.selection, trigger:)` only when a selection binding is present
/// (selectable variant). The non-selectable variant passes `nil` and gets a pass-through.
private struct CosmosTabHapticGate<SelectionValue: Equatable & Sendable>: ViewModifier {
    let selection: Binding<SelectionValue>?
    func body(content: Content) -> some View {
        if let selection {
            content.cosmosHaptic(.selection, trigger: selection.wrappedValue)
        } else {
            content
        }
    }
}

// MARK: - Per-platform availability table (pure, platform-agnostic, testable)

/// Pure per-platform availability table for ``CosmosTabViewStyle`` at the Cosmos 26 floor.
///
/// Derived from the Xcode 27 `.swiftinterface` `@available` clauses:
/// - `.automatic` (`DefaultTabViewStyle`): all 5 platforms.
/// - `.page` (`PageTabViewStyle`): iOS/tvOS/watchOS/visionOS; **not macOS**.
/// - `.sidebarAdaptable` (`SidebarAdaptableTabViewStyle`): iOS/macOS/tvOS/visionOS; **not watchOS**.
/// - `.tabBarOnly` (`TabBarOnlyTabViewStyle`): iOS/macOS/tvOS/visionOS; **not watchOS**.
/// - `.verticalPage` (`VerticalPageTabViewStyle`): **watchOS only** (watchOS 10).
/// - `.grouped` (`GroupedTabViewStyle`): **macOS only** (macOS 15).
public enum CosmosTabViewAvailability {
    public static func isAvailable(_ style: CosmosTabViewStyle, on platform: CosmosPlatform) -> Bool {
        switch platform {
        case .ios, .visionos:
            switch style {
            case .automatic, .page, .sidebarAdaptable, .tabBarOnly:
                return true
            case .verticalPage, .grouped:
                return false
            }
        case .macos:
            switch style {
            case .automatic, .sidebarAdaptable, .tabBarOnly, .grouped:
                return true
            case .page, .verticalPage:
                return false
            }
        case .tvos:
            switch style {
            case .automatic, .page, .sidebarAdaptable, .tabBarOnly:
                return true
            case .verticalPage, .grouped:
                return false
            }
        case .watchos:
            switch style {
            case .automatic, .page, .verticalPage:
                return true
            case .sidebarAdaptable, .tabBarOnly, .grouped:
                return false
            }
        }
    }

    /// Resolves a requested style to itself when available on `platform`, else `.automatic`.
    public static func resolve(_ style: CosmosTabViewStyle, on platform: CosmosPlatform) -> CosmosTabViewStyle {
        isAvailable(style, on: platform) ? style : .automatic
    }
}

// MARK: - Style resolution

/// Resolves a ``CosmosTabViewStyle`` to a concrete `TabViewStyle`, guarding each case with `#if os()`
/// for its per-platform availability and falling back to `.automatic` where the requested style is
/// unavailable on the current platform (never blanket-applies).
private struct CosmosTabViewStyleApplier: ViewModifier {
    let style: CosmosTabViewStyle
    func body(content: Content) -> some View {
        switch style {
        case .automatic:
            content.tabViewStyle(.automatic)
        case .page:
            // iOS/tvOS/watchOS/visionOS; not macOS.
            #if os(macOS)
            content.tabViewStyle(.automatic)
            #else
            content.tabViewStyle(.page)
            #endif
        case .sidebarAdaptable:
            // iOS/macOS/tvOS/visionOS; not watchOS.
            #if os(watchOS)
            content.tabViewStyle(.automatic)
            #else
            content.tabViewStyle(.sidebarAdaptable)
            #endif
        case .tabBarOnly:
            // iOS/macOS/tvOS/visionOS; not watchOS.
            #if os(watchOS)
            content.tabViewStyle(.automatic)
            #else
            content.tabViewStyle(.tabBarOnly)
            #endif
        case .verticalPage:
            // watchOS only.
            #if os(watchOS)
            content.tabViewStyle(.verticalPage)
            #else
            content.tabViewStyle(.automatic)
            #endif
        case .grouped:
            // macOS only.
            #if os(macOS)
            content.tabViewStyle(.grouped)
            #else
            content.tabViewStyle(.automatic)
            #endif
        }
    }
}

// MARK: - Per-instance chrome (platform-guarded pass-through)

extension View {
    /// User reordering/visibility customization. Available iOS 18/macOS 15/visionOS 2; **unavailable
    /// tvOS/watchOS** — omitted there (the `TabViewCustomization` type is itself unavailable, so the
    /// whole modifier is `#if`-guarded, not just the body). (All ≤ the Cosmos 26 floor — no runtime
    /// gate.)
    #if !os(tvOS) && !os(watchOS)
    public func cosmosTabViewCustomization(_ customization: Binding<TabViewCustomization>?) -> some View {
        self.tabViewCustomization(customization)
    }
    #endif

    /// Tab-bar minimize behavior. Available on all 5 platforms at iOS 26 (the Cosmos 26 floor) —
    /// no guard, no runtime gate. Only `.automatic` is portable; the scroll-trigger cases
    /// (`.onScrollDown`/`.onScrollUp`/`.never`) are iOS-only and rejected by the type system on
    /// other platforms.
    public func cosmosTabBarMinimizeBehavior(_ behavior: TabBarMinimizeBehavior) -> some View {
        self.tabBarMinimizeBehavior(behavior)
    }

    /// A bottom accessory view pinned to the tab bar. Available **iOS 26 only** — no-op on other
    /// platforms. The `isEnabled:`-bearing overload (``cosmosTabViewBottomAccessory(isEnabled:content:)``)
    /// is iOS 26.1, above the floor, and degrades to this form below 26.1.
    @ViewBuilder
    public func cosmosTabViewBottomAccessory<C: View>(@ViewBuilder content: @escaping () -> C) -> some View {
        #if os(iOS)
        self.tabViewBottomAccessory(content: content)
        #else
        self
        #endif
    }

    /// A bottom accessory view pinned to the tab bar, with an explicit enabled flag. Available
    /// **iOS 26.1** (above the Cosmos 26 floor) — the shallowest runtime `if #available` gate in
    /// the library, and the mechanical warm-up for PHASE3 §2.3's combined guard. Below iOS 26.1 it
    /// degrades to the iOS 26.0 ``cosmosTabViewBottomAccessory(content:)`` form (forwarding
    /// `content` without the enabled flag); no-op on other platforms. "Available since Cosmos 26.1".
    @ViewBuilder
    public func cosmosTabViewBottomAccessory<C: View>(
        isEnabled: Bool,
        @ViewBuilder content: @escaping () -> C
    ) -> some View {
        #if os(iOS)
        if #available(iOS 26.1, *) {
            self.tabViewBottomAccessory(isEnabled: isEnabled, content: content)
        } else {
            self.tabViewBottomAccessory(content: content)
        }
        #else
        self
        #endif
    }
}

// MARK: - bottomAccessory(isEnabled:) availability (pure, host-agnostic)

/// Pure availability for the `.cosmosTabViewBottomAccessory(isEnabled:)` overload. The native
/// `isEnabled:`-bearing `tabViewBottomAccessory` is `@available(iOS 26.1, *)` and unavailable on
/// macOS/tvOS/watchOS/visionOS — so the Cosmos overload is meaningful (renders the enabled flag)
/// only on iOS; elsewhere the modifier is a no-op pass-through.
public enum CosmosTabViewBottomAccessoryEnabledAvailability {
    /// `true` only on iOS (the `isEnabled:` overload is iOS 26.1).
    public static func isAvailable(on platform: CosmosPlatform) -> Bool {
        platform == .ios
    }
}

// MARK: - Previews

#Preview("TabView – selectable") {
    @Previewable @State var selected = 0
    CosmosTabView(selection: $selected) {
        Tab("preview.tab.one", systemImage: "1.circle", value: 0) { CosmosText("preview.tab.one") }
        Tab("preview.tab.two", systemImage: "2.circle", value: 1) { CosmosText("preview.tab.two") }
    }
}

#Preview("TabView – paged (non-selectable)") {
    CosmosTabView {
        Tab("preview.tab.one", systemImage: "1.circle") { CosmosText("preview.tab.one") }
        Tab("preview.tab.two", systemImage: "2.circle") { CosmosText("preview.tab.two") }
    }
    .cosmosTabViewStyle(.page)
}

#if !os(tvOS) && !os(watchOS)
#Preview("TabView – sidebarAdaptable + customization", traits: .sizeThatFitsLayout) {
    @Previewable @State var customization = TabViewCustomization()
    @Previewable @State var selected = 0
    CosmosTabView(selection: $selected) {
        Tab("preview.tab.one", systemImage: "star", value: 0) { CosmosText("preview.tab.one") }
        Tab("preview.tab.two", systemImage: "gear", value: 1) { CosmosText("preview.tab.two") }
    }
    .cosmosTabViewStyle(.sidebarAdaptable)
    .cosmosTabViewCustomization($customization)
}
#endif

#Preview("TabView – dark + accessibility size", traits: .sizeThatFitsLayout) {
    @Previewable @State var selected = 0
    CosmosPreviewContainer {
        CosmosTabView(selection: $selected) {
            Tab("preview.tab.one", systemImage: "1.circle", value: 0) { CosmosText("preview.tab.one") }
            Tab("preview.tab.two", systemImage: "2.circle", value: 1) { CosmosText("preview.tab.two") }
        }
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}

#if os(iOS)
#Preview("TabView – bottom accessory (isEnabled)", traits: .sizeThatFitsLayout) {
    @Previewable @State var selected = 0
    CosmosTabView(selection: $selected) {
        Tab("preview.tab.one", systemImage: "1.circle", value: 0) { CosmosText("preview.tab.one") }
        Tab("preview.tab.two", systemImage: "2.circle", value: 1) { CosmosText("preview.tab.two") }
    }
    .cosmosTabViewBottomAccessory(isEnabled: true) {
        HStack { Text("preview.title"); Spacer(); CosmosProgress() }
            .padding(.horizontal)
    }
}
#endif