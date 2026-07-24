import SwiftUI

/// A scroll-view atom wrapping `ScrollView` — a structural container with platform-safe
/// keyboard-dismiss and scroll-edge-effect pass-throughs, plus a programmatic-scroll recipe.
///
/// State and theme are **global**; this atom reads ``CosmosConfiguration`` and ``CosmosTheme``
/// from the environment. There is **no** `CosmosScrollViewStyle` selector — `ScrollView` has no
/// style protocol (verified in the Xcode 27 `.swiftinterface`: no `ScrollViewStyle` type), so this
/// atom wraps a `View` per the Cosmos wrap-view discipline (see `DECISIONS.md`), like
/// ``CosmosSection`` (a primitive with no conformable style).
///
/// **Platform guard.** None at the type level — `ScrollView` is available on all 5 platforms at
/// the Cosmos 26 floor. The two container-driven modifiers that fragment across platforms
/// (`.scrollDismissesKeyboard` and `.scrollEdgeEffectStyle`, both `@available(visionOS,
/// unavailable)`) are exposed as the ``cosmosScrollDismissesKeyboard`` /
/// ``cosmosScrollEdgeEffectStyle`` wrappers below — the first is declared only off-visionOS (its
/// `ScrollDismissesKeyboardMode` *type* is itself visionOS-unavailable, so callers there cannot
/// construct a value to pass); the second no-ops on visionOS (its type is available, the modifier
/// is not). Universal-floor scroll modifiers (`.scrollPosition`, `.scrollTargetBehavior`,
/// `.onScrollGeometryChange`, `.onScrollVisibilityChange`, `.defaultScrollAnchor`,
/// `.scrollIndicators`, `.refreshable`, `.contentMargins`, `.scrollTransition`,
/// `.scrollClipDisabled`, `.scrollContentBackground`) are available on all 5 platforms at the
/// floor and are applied natively — Cosmos does not re-wrap universally-available modifiers (the
/// same discipline ``CosmosList`` applies to `.refreshable`).
///
/// **Customization limits.** `ScrollView` renders a single content view, not rows — so (unlike
/// ``CosmosList``) there is **no** data/keyed-id init: compose `ForEach` inside the content
/// closure when you need repeated rows. The scroll axis is intrinsic structural identity, set at
/// init; `showsIndicators` likewise.
///
/// **Axis reflow (PHASE4 principle #1 — honest reading).** This atom does **not** auto-switch its
/// scroll axis by `horizontalSizeClass`. Switching a `ScrollView`'s axis destroys scroll
/// position/offset identity — the *opposite* of principle #1's "preserve view identity" goal. The
/// axis is caller-chosen and fixed; `AnyLayout` / `ViewThatFits` reflow applies to the **content
/// layout inside** the scroll view (the caller's `HStack`/`VStack`/`ViewThatFits`), not the scroll
/// axis. Use stable row identity (`ForEach(data:id:)` with stable IDs; avoid identity-recreating
/// `if/else`) so focus/scroll/animation survive reflow.
///
/// **Accessibility.** `ScrollView` is announced as a scrollable container; per-content labels/hints/
/// identifiers are caller-driven on the content. Apply `.cosmosAccessibilityLabel`/`.Hint`/
/// `.Identifier` here for the scroll surface itself. Dynamic Type reflows content.
///
/// **Haptics.** None — the container owns no haptic; `.sensoryFeedback` for row interactions
/// belongs on the content/controls inside.
/// **Motion.** None at the container — `listInsert`/`listRemove` and `.cosmosAnimation` for row
/// lifecycle belong on the `ForEach`/content inside (caller-driven). Programmatic `scrollTo` uses
/// SwiftUI's own animation; do not layer a differing curve on the same property (desync — CLAUDE.md).
/// **Tracking.** None — `ScrollView` is a structural container (like ``CosmosList`` /
/// ``CosmosSection`` / ``CosmosDivider``); tracking belongs on the interactive content inside.
///
/// **Programmatic scroll.** Use the native `ScrollViewReader { proxy in … }` with the
/// ``CosmosScrollAnchor`` sentinels and the ``ScrollViewProxy`` extension below:
/// ```swift
/// ScrollViewReader { proxy in
///     CosmosScrollView {
///         Color.clear.frame(height: 1).cosmosScrollAnchor(.top)
///         // …content…
///         Color.clear.frame(height: 1).cosmosScrollAnchor(.bottom)
///     }
///     CosmosButton("scroll.top", action: { proxy.scrollToTop() })
/// }
/// ```
/// A dedicated `CosmosScrollToTopButton` molecule is deferred to the Molecules wave; compose a
/// ``CosmosButton`` + the proxy for now. The base atom does **not** wrap content in
/// `ScrollViewReader` (it is only needed for `proxy.scrollTo`, which not every caller uses).
public struct CosmosScrollView<Content: View>: View {
    private let axes: Axis.Set
    private let showsIndicators: Bool
    @ViewBuilder private let content: () -> Content

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    /// Creates a vertical scroll view with visible indicators.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.axes = .vertical
        self.showsIndicators = true
        self.content = content
    }

    /// Creates a scroll view with the given axes and indicator visibility.
    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content
    }

    public var body: some View {
        if configuration.enable.isVisible {
            ScrollView(axes, showsIndicators: showsIndicators, content: content)
                .applyCosmosAccessibility(configuration.accessibility)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Programmatic scroll anchors + proxy ergonomics

/// Named scroll-target sentinels for the programmatic-scroll recipe. Provides stable, Cosmos-owned
/// ids so callers do not hand-roll string ids for the common top/bottom scroll-to cases. Tag a
/// content edge with ``View/cosmosScrollAnchor(_:)`` and drive it via the ``ScrollViewProxy``
/// extension (`scrollToTop()` / `scrollToBottom()` / `scrollTo(_:)`).
public enum CosmosScrollAnchor: String, Hashable, Sendable, CaseIterable {
    case top
    case bottom

    /// The stable `id` applied by ``View/cosmosScrollAnchor(_:)`` and targeted by the proxy helpers.
    public var scrollID: String { "cosmos.scroll.\(rawValue)" }
}

extension ScrollViewProxy {
    /// Scrolls the enclosing scroll view to the content tagged with ``CosmosScrollAnchor/top``.
    public func scrollToTop() {
        scrollTo(CosmosScrollAnchor.top.scrollID, anchor: .top)
    }

    /// Scrolls the enclosing scroll view to the content tagged with ``CosmosScrollAnchor/bottom``.
    public func scrollToBottom() {
        scrollTo(CosmosScrollAnchor.bottom.scrollID, anchor: .bottom)
    }

    /// Scrolls the enclosing scroll view to the content tagged with `anchor`.
    public func scrollTo(_ anchor: CosmosScrollAnchor) {
        scrollTo(anchor.scrollID, anchor: anchor == .top ? .top : .bottom)
    }
}

extension View {
    /// Tags this view with a ``CosmosScrollAnchor`` sentinel id so a ``ScrollViewProxy`` can
    /// scroll to it via `scrollToTop()` / `scrollToBottom()` / `scrollTo(_:)`. Place an invisible
    /// anchor view (e.g. `Color.clear.frame(height: 1).cosmosScrollAnchor(.top)`) at the content
    /// edge you want to target.
    public func cosmosScrollAnchor(_ anchor: CosmosScrollAnchor) -> some View {
        id(anchor.scrollID)
    }
}

// MARK: - Platform-guarded pass-through modifiers

extension View {
    /// Dismisses the keyboard on scroll. `.scrollDismissesKeyboard` is
    /// `@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)` and `@available(visionOS, unavailable)`
    /// (verified in the Xcode 27 `.swiftinterface`); its `ScrollDismissesKeyboardMode` *type* is
    /// likewise visionOS-unavailable, so this wrapper is declared only off-visionOS — callers on
    /// visionOS cannot construct a mode to pass and get a compile error if they try, which is the
    /// correct signal (the platform has no software keyboard to dismiss here). This mirrors the
    /// ``cosmosListSectionSpacing(_:)-1wp9b`` discipline where the parameter type is unavailable.
    #if !os(visionOS)
    @ViewBuilder
    public func cosmosScrollDismissesKeyboard(_ mode: ScrollDismissesKeyboardMode) -> some View {
        scrollDismissesKeyboard(mode)
    }
    #endif

    /// Configures the scroll-edge effect style (`.soft` / `.hard`). `.scrollEdgeEffectStyle` is
    /// `@available(iOS 26, macOS 26, tvOS 26, watchOS 26, *)` and `@available(visionOS,
    /// unavailable)` (verified in the Xcode 27 `.swiftinterface`) — floor-exact on the four
    /// non-visionOS platforms. Unlike ``cosmosScrollDismissesKeyboard``, the `ScrollEdgeEffectStyle`
    /// *type* IS available on visionOS, so the wrapper is declared on all 5 platforms and no-ops on
    /// visionOS (the effect is simply not applied there). `edges` defaults to `.all`.
    @ViewBuilder
    public func cosmosScrollEdgeEffectStyle(_ style: ScrollEdgeEffectStyle?, for edges: Edge.Set = .all) -> some View {
        #if !os(visionOS)
        scrollEdgeEffectStyle(style, for: edges)
        #else
        self
        #endif
    }
}

// MARK: - Per-platform availability table (pure, platform-agnostic, testable)

/// Pure per-platform availability table for the two platform-fragmented scroll modifiers at the
/// Cosmos 26 floor, derived from the Xcode 27 `.swiftinterface` `@available` clauses:
/// - `scrollDismissesKeyboard` (`ScrollDismissesKeyboardMode`): iOS 16 / macOS 13 / tvOS 16 /
///   watchOS 9; **unavailable visionOS** (both the modifier and its mode type).
/// - `scrollEdgeEffectStyle` (`ScrollEdgeEffectStyle`): iOS 26 / macOS 26 / tvOS 26 / watchOS 26
///   (floor-exact); **unavailable visionOS** (the modifier — the type itself is visionOS-available,
///   so the wrapper no-ops there rather than being undeclared).
///
/// The table reports whether the modifier's **effect** is achievable on a platform. Both are
/// `false` on visionOS; `true` on the other four. The runtime/compile gates live in the wrappers
/// above (the table is host-agnostic and cannot know the compile target).
public enum CosmosScrollAvailability {
    /// `true` on iOS/macOS/tvOS/watchOS; `false` on visionOS (modifier + mode type unavailable).
    public static func scrollDismissesKeyboardAvailable(on platform: CosmosPlatform) -> Bool {
        platform != .visionos
    }

    /// `true` on iOS/macOS/tvOS/watchOS (floor-exact 26); `false` on visionOS (modifier unavailable;
    /// the wrapper no-ops there).
    public static func scrollEdgeEffectStyleAvailable(on platform: CosmosPlatform) -> Bool {
        platform != .visionos
    }
}

// MARK: - Previews

#Preview("ScrollView – vertical content") {
    CosmosScrollView {
        VStack(spacing: 16) {
            ForEach(0..<12, id: \.self) { i in
                CosmosText("preview.row.\(i)")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
            }
        }
        .padding()
    }
}

#Preview("ScrollView – horizontal axis") {
    CosmosScrollView(.horizontal) {
        HStack(spacing: 16) {
            ForEach(0..<10, id: \.self) { i in
                CosmosText("preview.row.\(i)")
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
            }
        }
        .padding()
    }
}

#Preview("ScrollView – programmatic scroll-to-top") {
    ScrollViewReader { proxy in
        VStack(spacing: 0) {
            CosmosScrollView {
                // Top anchor — an invisible sentinel tagged for proxy.scrollToTop().
                Color.clear.frame(height: 1).cosmosScrollAnchor(.top)
                VStack(spacing: 16) {
                    ForEach(0..<30, id: \.self) { i in
                        CosmosText("preview.row.\(i)")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
                    }
                }
                .padding()
            }
            CosmosButton("preview.title", action: { proxy.scrollToTop() })
                .padding()
        }
    }
}

#Preview("ScrollView – disabled + loading", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosScrollView {
            CosmosText("preview.row.one")
            CosmosText("preview.row.two")
        }
        .cosmosEnabled(false)
        .cosmosLoading(true)
        .frame(height: 160)
    }
}

#Preview("ScrollView – dark + accessibility size", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosScrollView {
            VStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { i in
                    CosmosText(verbatim: CosmosMock.sentence(wordCount: 3))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
                }
            }
            .padding()
        }
        .frame(height: 220)
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}

#Preview("ScrollView – RTL", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(0..<8, id: \.self) { i in
                    CosmosText("preview.row.\(i)").padding()
                }
            }
            .padding()
        }
        .frame(height: 120)
        .cosmosPreviewVariant(.rtl)
    }
}

#Preview("ScrollView – landscape reflow", traits: .landscapeLeft) {
    CosmosPreviewContainer {
        CosmosScrollView {
            VStack(spacing: 12) {
                ForEach(0..<8, id: \.self) { i in
                    CosmosText("preview.row.\(i)").padding()
                }
            }
            .padding()
        }
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}