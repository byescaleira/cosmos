import SwiftUI

/// A selectable-list atom wrapping `List(selection:)` with a token-driven (per-platform-safe) style,
/// tint, accessibility, a selection haptic, and selection-change tracking.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration`` from
/// the environment and overrides per-instance via `.cosmos*` modifiers. The visual variant comes
/// from ``CosmosTheme/listStyle`` (default `.automatic`) and is resolved through the **same**
/// ``CosmosListStyleApplier`` / ``CosmosListAvailability`` matrix as ``CosmosList`` — one source of
/// truth for the `ListStyle` × platform matrix.
///
/// **Why a wrap-view, not a style conformance.** `ListStyle` is opaque / native-bridged (see
/// ``CosmosList``); Cosmos wraps a `View` that configures a native `List(selection:)` and applies a
/// built-in style via the shared applier.
///
/// **Selection fragmentation — why this is a separate atom.** The native `List(selection:)` inits
/// fragment across platforms in ways a single clean API cannot hide (see ``CosmosList`` doc). This
/// atom resolves the fragmentation by exposing **optional-single selection as the universal
/// primary** (`selection: Binding<SelectionValue?>`, `SelectionValue: Hashable & Sendable`) — the
/// only shape available on all 5 platforms (watchOS 10+ at the Cosmos 26 floor, iOS 13 /
/// macOS 10.15 / tvOS 13 / visionOS 1 elsewhere — all ≤ floor, so no runtime `if #available`).
/// **`Set`-based multi-selection inits** (`selection: Binding<Set<SelectionValue>>`) are guarded
/// `#if !os(watchOS)` — `Set` selection is `@available(watchOS, unavailable)` in the SDK, so the
/// inits (and their `List(selection: Binding<Set<…>>…)` calls) are compile-time-excluded on
/// watchOS. The **non-optional-single** surface (`Binding<SelectionValue>`) is macOS-13-only (a
/// data-bearing variant adds tvOS 18) and is **deliberately dropped** — too narrow to expose
/// cross-platform; callers who need it use a native `List(selection:)` directly.
///
/// **Generic shape — one `Selection` type unifies both shapes.** `CosmosSelectableList<Selection:
/// Hashable & Sendable>` is **inferred from the binding**: an optional-single caller passes
/// `Binding<Element?>` → `Selection == Element?`; a `Set` caller passes `Binding<Set<Element>>` →
/// `Selection == Set<Element>`. Each init pins the shape with a `where Selection == E?` /
/// `where Selection == Set<E>` constraint (mutually exclusive, so the overloads resolve
/// unambiguously from the binding). `Hashable` matches native `List`; `Sendable` is added so the
/// selection drives `.cosmosHaptic(.selection, trigger:)`. Because the optional-single and `Set`
/// inits construct structurally different native `List` types (different `Content`), the native
/// `List` is built in each init — where the per-init constraints are concrete — and type-erased to
/// `AnyView`; the **concrete** `Selection` trigger is read in `body` (`selection.wrappedValue`) so
/// the haptic and `.onChange` stay fresh each render (same pattern as ``CosmosTabView``).
///
/// **Customization limits.** Same as ``CosmosList``: no wholly custom list renderer; row/section
/// chrome is caller-driven via the ``cosmosListSectionSpacing`` / ``cosmosSwipeActions`` / etc.
/// wrappers. Row identity must be stable across reflow (`ForEach(data:id:)` with stable IDs).
///
/// **Accessibility:** the `List` is announced as a list with navigable, selectable rows; per-row
/// labels/hints/identifiers are caller-driven. Apply `.cosmosAccessibilityLabel`/`.Identifier` here
/// for the list itself. Dynamic Type reflows rows. **Haptics:** `.selection` on
/// `selection.wrappedValue` change via `.cosmosHaptic(_:trigger:)`, gated through
/// ``CosmosHapticsPolicy`` (config + Reduce Motion); no-op without hardware. **Motion:** the List's
/// native selection animation is system-driven — the atom does **not** layer
/// `.cosmosAnimation(.valueChange, value:)` on the `List` (a differing curve would desync, same rule
/// as ``CosmosPicker``/``CosmosSection``/``CosmosTabView``). Callers coordinate a programmatic
/// selection write with a single
/// `cosmosWithAnimation(.containerTransform, configuration:theme:reduceMotion:) { selection = newValue }`
/// (the gated, token-driven chokepoint — see
/// ``cosmosWithAnimation(_:configuration:theme:reduceMotion:completionCriteria:body:completion:)``).
/// **Tracking:** `.valueChange` on selection change (`componentId = trackingId ?? accessibilityId`),
/// opt-in/passive via ``CosmosTrackingConfiguration``.
public struct CosmosSelectableList<Selection: Hashable & Sendable>: View {
    /// Type-erased native `List(selection:)` built in the init (optional-single vs `Set` differ in
    /// type, and data-bearing inits build `ForEach`-rooted content).
    private let resolved: AnyView
    /// The selection binding — its wrapped value (`Selection`) is the concrete haptic + tracking
    /// trigger read in `body`. `Selection` is `Optional<E>` or `Set<E>` per the init used.
    private let selection: Binding<Selection>

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    // MARK: Optional-single selection (universal — all 5 platforms, watchOS 10+ ≤ floor)

    /// Creates a selectable list with custom content and optional single-value selection.
    public init<E: Hashable & Sendable, C: View>(
        selection: Binding<Selection>,
        @ViewBuilder content: @escaping () -> C
    ) where Selection == E? {
        self.selection = selection
        self.resolved = AnyView(List(selection: selection, content: content))
    }

    /// Creates a selectable list from a collection of `Identifiable` data, with optional
    /// single-value selection and a per-row content view.
    public init<Data, RowContent>(
        selection: Binding<Selection>,
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where Selection == Data.Element.ID?, Data: RandomAccessCollection, Data.Element: Identifiable, RowContent: View {
        self.selection = selection
        self.resolved = AnyView(List(data, selection: selection) { rowContent($0) })
    }

    /// Creates a selectable list from a collection of data keyed by `id`, with optional
    /// single-value selection and a per-row content view.
    public init<Data, ID, RowContent>(
        selection: Binding<Selection>,
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where Selection == ID?, Data: RandomAccessCollection, ID: Hashable & Sendable, RowContent: View {
        self.selection = selection
        self.resolved = AnyView(List(data, id: id, selection: selection) { rowContent($0) })
    }

    // MARK: Set-based multi-selection (watchOS-unavailable — compile-time `#if !os(watchOS)`)

    #if !os(watchOS)
    /// Creates a multi-selectable list with custom content and `Set`-based selection.
    ///
    /// `Set`-based selection is `@available(watchOS, unavailable)` — this init is compile-time
    /// excluded on watchOS. Use the optional-single inits there.
    public init<E: Hashable & Sendable, C: View>(
        selection: Binding<Selection>,
        @ViewBuilder content: @escaping () -> C
    ) where Selection == Set<E> {
        self.selection = selection
        self.resolved = AnyView(List(selection: selection, content: content))
    }

    /// Creates a multi-selectable list from a collection of `Identifiable` data, with `Set`-based
    /// selection and a per-row content view. watchOS-unavailable.
    public init<Data, RowContent>(
        selection: Binding<Selection>,
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where Selection == Set<Data.Element.ID>, Data: RandomAccessCollection, Data.Element: Identifiable, RowContent: View {
        self.selection = selection
        self.resolved = AnyView(List(data, selection: selection) { rowContent($0) })
    }

    /// Creates a multi-selectable list from a collection of data keyed by `id`, with `Set`-based
    /// selection and a per-row content view. watchOS-unavailable.
    public init<Data, ID, RowContent>(
        selection: Binding<Selection>,
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where Selection == Set<ID>, Data: RandomAccessCollection, ID: Hashable & Sendable, RowContent: View {
        self.selection = selection
        self.resolved = AnyView(List(data, id: id, selection: selection) { rowContent($0) })
    }
    #endif

    public var body: some View {
        if configuration.enable.isVisible {
            // Concrete `Selection` trigger — fresh each render — feeds both the haptic and the
            // tracking `.onChange`. `Selection: Hashable & Sendable` satisfies `.cosmosHaptic`.
            let trigger = selection.wrappedValue
            resolved
                .modifier(CosmosListStyleApplier(style: theme.listStyle))
                .tint(theme.colors.accent)
                .applyCosmosAccessibility(configuration.accessibility)
                .cosmosHaptic(.selection, trigger: trigger)
                .onChange(of: trigger) { _, _ in trackSelectionChange() }
        } else {
            EmptyView()
        }
    }

    private func trackSelectionChange() {
        configuration.tracking.track(.init(
            name: "selectable_list_change",
            component: "CosmosSelectableList",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .valueChange
        ))
    }
}

// MARK: - Selection-init availability table (pure, platform-agnostic, testable)

/// Pure per-platform availability table for ``CosmosSelectableList``'s selection inits at the
/// Cosmos 26 floor, derived from the Xcode 27 `.swiftinterface` `@available` clauses:
/// - **Optional-single** (`Binding<SelectionValue?>`): all 5 platforms (watchOS 10+, iOS 13 /
///   macOS 10.15 / tvOS 13 / visionOS 1 — all ≤ floor).
/// - **`Set`** (`Binding<Set<SelectionValue>>`): iOS / macOS / tvOS / visionOS; **unavailable
///   watchOS** (`@available(watchOS, unavailable)` → compile-time `#if !os(watchOS)`).
/// - **Non-optional-single** (`Binding<SelectionValue>`): macOS 13 only (data-bearing adds tvOS 18)
///   — **not exposed** by this atom (too narrow).
public enum CosmosSelectableListAvailability {
    /// `true` on all 5 platforms (optional-single selection is the universal primary).
    public static func optionalSingleAvailable(on platform: CosmosPlatform) -> Bool {
        true
    }

    /// `true` on iOS / macOS / tvOS / visionOS; `false` on watchOS (`Set` selection is unavailable).
    public static func setAvailable(on platform: CosmosPlatform) -> Bool {
        switch platform {
        case .ios, .macos, .tvos, .visionos:
            return true
        case .watchos:
            return false
        }
    }
}

// MARK: - Previews

private struct CosmosSelectableListPreviewRow: Identifiable, Hashable {
    let id = UUID()
    let title: String
}

#Preview("SelectableList – optional single (content)") {
    @Previewable @State var selected: CosmosSelectableListPreviewRow.ID?
    let rows = (0..<5).map { CosmosSelectableListPreviewRow(title: "Item \($0)") }
    CosmosSelectableList(selection: $selected) {
        ForEach(rows) { row in
            HStack {
                CosmosText(row.title)
                Spacer()
                Image(systemName: selected == row.id ? "checkmark.circle.fill" : "circle")
            }
            .tag(row.id)
        }
    }
    .cosmosListStyle(.insetGrouped)
}

#Preview("SelectableList – optional single (Identifiable data)") {
    @Previewable @State var selected: CosmosSelectableListPreviewRow.ID?
    let rows = (0..<5).map { CosmosSelectableListPreviewRow(title: "Item \($0)") }
    CosmosSelectableList(selection: $selected, rows) { row in
        HStack {
            CosmosText(row.title)
            Spacer()
            Image(systemName: selected == row.id ? "checkmark.circle.fill" : "circle")
        }
    }
    .cosmosListStyle(.insetGrouped)
}

#if !os(watchOS)
#Preview("SelectableList – Set multi-selection") {
    @Previewable @State var selected: Set<CosmosSelectableListPreviewRow.ID> = []
    let rows = (0..<5).map { CosmosSelectableListPreviewRow(title: "Item \($0)") }
    CosmosSelectableList(selection: $selected, rows) { row in
        HStack {
            CosmosText(row.title)
            Spacer()
            Image(systemName: selected.contains(row.id) ? "checkmark.square.fill" : "square")
        }
    }
    .cosmosListStyle(.insetGrouped)
}
#endif

#Preview("SelectableList – dark + accessibility size", traits: .sizeThatFitsLayout) {
    @Previewable @State var selected: CosmosSelectableListPreviewRow.ID?
    let rows = (0..<4).map { CosmosSelectableListPreviewRow(title: "Item \($0)") }
    CosmosPreviewContainer {
        CosmosSelectableList(selection: $selected, rows) { row in
            HStack {
                CosmosText(row.title)
                Spacer()
                Image(systemName: selected == row.id ? "checkmark.circle.fill" : "circle")
            }
        }
        .cosmosListStyle(.insetGrouped)
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}

#Preview("SelectableList – landscape reflow", traits: .landscapeLeft) {
    @Previewable @State var selected: CosmosSelectableListPreviewRow.ID?
    let rows = (0..<6).map { CosmosSelectableListPreviewRow(title: "Item \($0)") }
    CosmosPreviewContainer {
        CosmosSelectableList(selection: $selected, rows) { row in
            HStack {
                CosmosText(row.title)
                Spacer()
                Image(systemName: selected == row.id ? "checkmark.circle.fill" : "circle")
            }
        }
        .cosmosListStyle(.insetGrouped)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}