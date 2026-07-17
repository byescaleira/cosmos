---
tags: [component, atom, wave-e, list, swiftui]
aliases: [CosmosList]
related: [cosmos-section, cosmos-picker]
---

# CosmosList

`List` wrap-view — Wave E atom ([[PHASE2]] §2.15). File: `Sources/Cosmos/Atoms/CosmosList.swift`.

## Why a wrap-view, not a style conformance

`ListStyle` is **opaque / native-bridged**: only underscored `_makeView`/`_makeViewList`; no `makeBody`, no `Configuration` associatedtype. A Cosmos struct cannot conform. So — like [[cosmos-picker]] and [[cosmos-date-picker]] — Cosmos wraps a `View` that configures a native `List` and applies a built-in style via `CosmosListStyleApplier`.

`CosmosListStyle` is a **9-case enum** consumed by the applier, which guards each case per platform with `#if os()` and falls back to `.automatic` where the requested style is unavailable — never blindly forwards a user-chosen style.

## Generic shape

`CosmosList<Content: View>`. **No selection** in this atom (`SelectionValue == Never`). Four universal inits:

- `init(@ViewBuilder content:)` — arbitrary content (sections + rows).
- `init(_ data:, rowContent:)` — `Identifiable` collection → `ForEach`.
- `init(_ data:, id:, rowContent:)` — collection keyed by `Hashable` id → `ForEach`.
- `init(_ data: Range<Int>, rowContent:)` — constant range.

### Gotcha: `ForEach(data, rowContent:)` shorthand does not parse

Passing a closure variable by label — `ForEach(data, rowContent:)` — fails (`expected expression in list of expressions`). Must use the trailing-closure form `ForEach(data) { rowContent($0) }` (and `ForEach(data, id: id) { rowContent($0) }` for the keyed variant).

### Gotcha: `#Preview` body cannot contain a `struct` declaration

A `struct Row: Identifiable` declared *inside* a `#Preview { }` closure fails: "closure containing a declaration cannot be used with result builder 'PreviewMacroBodyBuilder'". Move row/preview-helper types to **file scope** (private).

## Selection — deliberately deferred

The selection-bearing `List(selection:)` inits fragment across platforms in ways a single clean API cannot hide:

- `Set`-based selection is **watchOS-unavailable**.
- Non-optional single-value selection is **macOS 13-only** (and a data-bearing variant adds tvOS 18).
- Only the optional single-value selection is broadly available (watchOS 10+).

So this atom ships the **no-selection primary** surface only. A cross-platform selectable variant needs platform branching and is deferred to a follow-up `CosmosSelectableList`; callers needing selection today use a native `List(selection:)` directly.

## ListStyle × platform matrix (verified Xcode 27 Beta 3)

Derived from `@available(...)` clauses in the iOS/macOS `.swiftinterface`. All version bounds ≤ the Cosmos 26 floor → **no runtime `if #available`**; only `#if os()` compile guards.

| Style | iOS | macOS | tvOS | watchOS | visionOS |
|---|---|---|---|---|---|
| `.automatic` (Default) | ✓ | ✓ | ✓ | ✓ | ✓ |
| `.plain` (Plain) | ✓ | ✓ | ✓ | ✓ | ✓ |
| `.grouped` (Grouped) | ✓ | ✗ | ✓ | ✗ | ✓ |
| `.inset` (Inset) | ✓ | ✓ | ✗ | ✗ | ✓ |
| `.insetGrouped` (InsetGrouped) | ✓ | ✗ | ✗ | ✗ | ✓ (via `*`) |
| `.sidebar` (Sidebar) | ✓ | ✓ | ✗ | ✗ | ✓ |
| `.bordered` (Bordered) | ✗ | ✓ | ✗ | ✗ | ✗ |
| `.elliptical` (Elliptical) | ✗ | ✗ | ✗ | ✓ | ✗ |
| `.carousel` (Carousel) | ✗ | ✗ | ✗ | ✓ | ✗ |

**Xcode 27 correction:** `InsetGroupedListStyle` IS visionOS-available (via the `*` wildcard). The older "visionOS-unavailable" claim is outdated. `AccessoryBarListStyle` does **not** exist in the Xcode 27 SDK and is not exposed.

## Row container modifiers (caller-driven, platform-guarded)

- `.cosmosSwipeActions(edge:allowsFullSwipe:content:)` — wraps `.swipeActions`; **tvOS-unavailable → no-op on tvOS** (`#if os(tvOS)`). The Xcode 27 `onPresentationChanged` overload is OS 27 (above floor) — not wrapped.
- Row/section chrome lives on [[cosmos-section]] (`cosmosListSectionSpacing`/`cosmosListSectionSeparator`(+Tint)/`cosmosListRowSeparator`(+Tint)/`cosmosSectionActions`/`cosmosListSectionMargins`), applicable to any `View`.
- `.refreshable` is universal — apply the native modifier directly.

Row identity must be stable across reflow (`ForEach(data:id:)` with stable IDs; avoid identity-recreating `if/else`) so focus/scroll/animation survive rotation.

## Cross-cutting

- **Haptics:** none — the `List` container owns no haptic. Selection/reorder-drop/swipe-commit haptics belong on the rows/controls inside (and require a selection binding this atom doesn't expose).
- **Motion:** `listInsert`/`listRemove` for row lifecycle are **caller-driven** via `.cosmosAnimation(.listInsert/.listRemove, value:)` on the `ForEach` driving row lifecycle (plus `.cosmosTransition`/`.cosmosContentTransition` on row content). The List container itself has no inherent motion.
- **Tracking:** none — `List` is a structural container (like [[cosmos-section]]); tracking belongs on the interactive rows/controls inside.
- **Accessibility:** the List is announced as a list with navigable rows; per-row labels/hints/identifiers are caller-driven on row content. Apply `.cosmosAccessibilityLabel`/`.Hint`/`.Identifier` here for the list itself. Dynamic Type reflows rows.

## Tests

`CosmosWaveEAtomsTests`: full style×platform availability matrix (per style), `resolve` fallback, theme default/`withListStyle` fluent builder / non-mutation. Plus `listStyleAllCases`.