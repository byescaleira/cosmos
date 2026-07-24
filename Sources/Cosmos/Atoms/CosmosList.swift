import SwiftUI

/// A list atom wrapping `List` with a token-driven (per-platform-safe) style, accessibility, and a
/// per-platform style-availability matrix.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration`` from
/// the environment and overrides per-instance via `.cosmos*` modifiers. The visual variant comes
/// from ``CosmosTheme/listStyle`` (default `.automatic`).
///
/// **Why a wrap-view, not a style conformance.** `ListStyle` is **opaque / native-bridged** — only
/// underscored `_makeView`/`_makeViewList`; no `makeBody`, no `Configuration` associatedtype. A
/// Cosmos struct cannot conform. Cosmos wraps a `View` that configures a native `List` and applies
/// a built-in style via the applier.
///
/// **Per-style availability.** Each built-in `ListStyle` fragments across platforms (see
/// ``CosmosListAvailability``). The applier guards each case with `#if os()` and falls back to
/// `.automatic` where a requested style is unavailable — never blindly forwards a user-chosen
/// style. All version bounds are ≤ the Cosmos 26 floor, so the guards are compile-time `#if os()`
/// only. `AccessoryBarListStyle` does not exist in the Xcode 27 SDK and is not exposed.
///
/// **Platform guard.** None at the type level — `List` is available on all 5 platforms.
///
/// **Selection — deliberately deferred.** This atom exposes the **no-selection** primary
/// (`SelectionValue == Never`) surface: the universal `content`/data inits. The selection-bearing
/// inits are **not** exposed because they fragment across platforms in ways a single clean API
/// cannot hide: `Set`-based selection is watchOS-**unavailable**, the non-optional single-value
/// selection is macOS-13-**only** (and a data-bearing variant adds tvOS 18), and only the optional
/// single-value selection is broadly available (watchOS 10+). A cross-platform selectable variant
/// needs platform branching and is deferred to a follow-up `CosmosSelectableList`; callers needing
/// selection today use a native `List(selection:)` directly.
///
/// **Customization limits.** No customization-via-protocol path — cannot synthesize a wholly
/// custom list renderer. Row/section chrome (`.listRowSeparator`/`.listSectionSeparator`/tints,
/// `.listSectionSpacing`, `.listSectionMargins`, `.sectionActions`) is caller-driven on rows via
/// the ``cosmosListSectionSpacing`` / ``cosmosListSectionSeparator`` / ``cosmosListRowSeparator``
/// / ``cosmosSectionActions`` / ``cosmosListSectionMargins`` wrappers (defined on ``CosmosSection``,
/// applicable to any `View`), plus ``cosmosSwipeActions`` below. `.refreshable` is universal — apply
/// the native modifier directly. Row identity must be stable across reflow (`ForEach(data:id:)`
/// with stable IDs; avoid identity-recreating `if/else`) so focus/scroll/animation survive.
///
/// **Accessibility:** the `List` is announced as a list with navigable rows; per-row labels/hints/
/// identifiers are caller-driven on the row content. Apply `.cosmosAccessibilityLabel`/`.Hint`/
/// `.Identifier` here for the list itself. Dynamic Type reflows rows.
///
/// **Haptics:** none — the `List` container owns no haptic; `.sensoryFeedback(.selection,
/// trigger:)` on selection and `.impact(.light)` on reorder-drop/swipe-commit belong on the rows/
/// controls inside (and require a selection binding, which this no-selection atom does not expose).
/// **Motion:** `listInsert`/`listRemove` for row lifecycle are caller-driven via
/// `.cosmosAnimation(.listInsert/.listRemove, value:)` on the `ForEach` driving row lifecycle (plus
/// `.cosmosTransition`/`.cosmosContentTransition` on row content); the List container itself has no
/// inherent motion. **Tracking:** none — `List` is a structural container (like ``CosmosSection`` /
/// ``CosmosDivider``); tracking belongs on the interactive rows/controls inside.
public struct CosmosList<Content: View>: View {
    @ViewBuilder private let content: () -> Content

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    /// Creates a list with custom content (no selection).
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    /// Creates a list from a collection of `Identifiable` data, with a per-row content view.
    public init<Data, RowContent>(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where Content == ForEach<Data, Data.Element.ID, RowContent>, Data: RandomAccessCollection, RowContent: View, Data.Element: Identifiable {
        self.content = { ForEach(data) { rowContent($0) } }
    }

    /// Creates a list from a collection of data keyed by `id`, with a per-row content view.
    public init<Data, ID, RowContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where Content == ForEach<Data, ID, RowContent>, Data: RandomAccessCollection, ID: Hashable, RowContent: View {
        self.content = { ForEach(data, id: id) { rowContent($0) } }
    }

    /// Creates a list over a constant `Range<Int>`, with a per-row content view.
    public init<RowContent>(
        _ data: Range<Int>,
        @ViewBuilder rowContent: @escaping (Int) -> RowContent
    ) where Content == ForEach<Range<Int>, Int, RowContent>, RowContent: View {
        self.content = { ForEach(data, id: \.self, content: rowContent) }
    }

    public var body: some View {
        if configuration.enable.isVisible {
            List(content: content)
                .modifier(CosmosListStyleApplier(style: theme.listStyle))
                .applyCosmosAccessibility(configuration.accessibility)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Per-platform availability table (pure, platform-agnostic, testable)

/// Pure per-platform availability table for ``CosmosListStyle`` at the Cosmos 26 floor.
///
/// Derived from the Xcode 27 `.swiftinterface` `@available` clauses:
/// - `.automatic`/`.plain`: all 5 platforms.
/// - `.grouped`: iOS/tvOS/visionOS; **not macOS, not watchOS**.
/// - `.inset`: iOS/macOS/visionOS; **not tvOS, not watchOS**.
/// - `.insetGrouped`: iOS/visionOS (via `*`); **not macOS, not tvOS, not watchOS** (Xcode 27
///   correction — it IS visionOS-available).
/// - `.sidebar`: iOS/macOS/visionOS; **not tvOS, not watchOS**.
/// - `.bordered`: **macOS only**.
/// - `.elliptical`/`.carousel`: **watchOS only**.
public enum CosmosListAvailability {
    public static func isAvailable(_ style: CosmosListStyle, on platform: CosmosPlatform) -> Bool {
        switch platform {
        case .ios, .visionos:
            switch style {
            case .automatic, .plain, .grouped, .inset, .insetGrouped, .sidebar:
                return true
            case .bordered, .elliptical, .carousel:
                return false
            }
        case .macos:
            switch style {
            case .automatic, .plain, .inset, .sidebar, .bordered:
                return true
            case .grouped, .insetGrouped, .elliptical, .carousel:
                return false
            }
        case .tvos:
            switch style {
            case .automatic, .plain, .grouped:
                return true
            case .inset, .insetGrouped, .sidebar, .bordered, .elliptical, .carousel:
                return false
            }
        case .watchos:
            switch style {
            case .automatic, .plain, .elliptical, .carousel:
                return true
            case .grouped, .inset, .insetGrouped, .sidebar, .bordered:
                return false
            }
        }
    }

    /// Resolves a requested style to itself when available on `platform`, else `.automatic`.
    public static func resolve(_ style: CosmosListStyle, on platform: CosmosPlatform) -> CosmosListStyle {
        isAvailable(style, on: platform) ? style : .automatic
    }
}

// MARK: - Style resolution

/// Resolves a ``CosmosListStyle`` to a concrete `ListStyle`, guarding each case with `#if os()` for
/// its per-platform availability and falling back to `.automatic` where the requested style is
/// unavailable on the current platform (never blanket-applies).
///
/// `internal` (not `private`) so the selectable sibling ``CosmosSelectableList`` reuses the same
/// per-platform style resolution — one source of truth for the `ListStyle` × platform matrix.
struct CosmosListStyleApplier: ViewModifier {
    let style: CosmosListStyle
    func body(content: Content) -> some View {
        switch style {
        case .automatic:
            content.listStyle(.automatic)
        case .plain:
            content.listStyle(.plain)
        case .grouped:
            // iOS/tvOS/visionOS; not macOS, not watchOS.
            #if os(macOS) || os(watchOS)
            content.listStyle(.automatic)
            #else
            content.listStyle(.grouped)
            #endif
        case .inset:
            // iOS/macOS/visionOS; not tvOS, not watchOS.
            #if os(tvOS) || os(watchOS)
            content.listStyle(.automatic)
            #else
            content.listStyle(.inset)
            #endif
        case .insetGrouped:
            // iOS/visionOS only.
            #if os(iOS) || os(visionOS)
            content.listStyle(.insetGrouped)
            #else
            content.listStyle(.automatic)
            #endif
        case .sidebar:
            // iOS/macOS/visionOS; not tvOS, not watchOS.
            #if os(tvOS) || os(watchOS)
            content.listStyle(.automatic)
            #else
            content.listStyle(.sidebar)
            #endif
        case .bordered:
            // macOS only.
            #if os(macOS)
            content.listStyle(.bordered)
            #else
            content.listStyle(.automatic)
            #endif
        case .elliptical:
            // watchOS only.
            #if os(watchOS)
            content.listStyle(.elliptical)
            #else
            content.listStyle(.automatic)
            #endif
        case .carousel:
            // watchOS only.
            #if os(watchOS)
            content.listStyle(.carousel)
            #else
            content.listStyle(.automatic)
            #endif
        }
    }
}

// MARK: - Row container modifier (platform-guarded pass-through)

extension View {
    /// Swipe actions on a list row. Available iOS 15+ / macOS 12+ / watchOS 8+ / visionOS;
    /// **unavailable tvOS** — no-op on tvOS. (The Xcode 27 `onPresentationChanged` overload is OS 27,
    /// above the Cosmos 26 floor — not wrapped here.)
    @ViewBuilder
    public func cosmosSwipeActions<C: View>(
        edge: HorizontalEdge = .trailing,
        allowsFullSwipe: Bool = true,
        @ViewBuilder content: @escaping () -> C
    ) -> some View {
        #if os(tvOS)
        self
        #else
        self.swipeActions(edge: edge, allowsFullSwipe: allowsFullSwipe, content: content)
        #endif
    }
}

// MARK: - Previews

private struct CosmosListPreviewRow: Identifiable {
    let id = UUID()
    let title: String
}

#Preview("List – content + styles") {
    CosmosList {
        CosmosText("preview.row.one")
        CosmosText("preview.row.two")
        CosmosText("preview.row.three")
    }
    .cosmosListStyle(.plain)
}

#Preview("List – Identifiable data") {
    let rows = (0..<5).map { CosmosListPreviewRow(title: "Item \($0)") }
    CosmosList(rows) { row in
        CosmosText(row.title)
    }
}

#Preview("List – grouped + swipe actions") {
    CosmosList {
        CosmosSection("preview.title") {
            CosmosText("preview.row.one")
            CosmosText("preview.row.two")
                .cosmosSwipeActions { CosmosButton(action: {}) { CosmosText("preview.delete") } }
        }
    }
    .cosmosListStyle(.grouped)
}

#Preview("List – dark + accessibility size", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosList {
            ForEach(0..<4, id: \.self) { i in
                CosmosText("preview.row.\(i)")
            }
        }
        .cosmosListStyle(.insetGrouped)
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}

#Preview("List – landscape reflow", traits: .landscapeLeft) {
    CosmosPreviewContainer {
        CosmosList {
            ForEach(0..<6, id: \.self) { i in
                CosmosText("preview.row.\(i)")
            }
        }
        .cosmosListStyle(.insetGrouped)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}