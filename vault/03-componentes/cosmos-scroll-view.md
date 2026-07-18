---
tags: [component, atom, wave-f, scrollview, swiftui]
aliases: [CosmosScrollView]
related: [cosmos-list, cosmos-section, apple-ios26-sample-code-patterns]
---

# CosmosScrollView

`ScrollView` wrap-view — Wave F atom (first PHASE4 wave). File:
`Sources/Cosmos/Atoms/CosmosScrollView.swift`.

## Why a wrap-view, not a style conformance

`ScrollView` has **no style protocol** (verified in the Xcode 27 `.swiftinterface`: there is no
`ScrollViewStyle` type). So — like [[cosmos-section]] (a primitive with no conformable style) and
unlike [[cosmos-list]] (which carries a `ListStyle` selector) — `CosmosScrollView` has **no**
`CosmosScrollViewStyle` enum, no `CosmosTheme` field, and no `.cosmosScrollViewStyle(_:)` modifier.
Wave F touches `CosmosTheme` not at all.

## Structural — no haptics / tracking / container motion

Matches the [[cosmos-list]] / [[cosmos-section]] discipline: the container owns none of the
cross-cutting concerns beyond `enable.isVisible` gating + accessibility. Press/selection haptics,
row-lifecycle motion (`.cosmosAnimation(.listInsert/.listRemove)`), and tracking belong on the
interactive content/rows the caller puts inside (caller-driven).

## Inits — content-only; no data init

- `init(@ViewBuilder content:)` — vertical, indicators shown.
- `init(_ axes: Axis.Set = .vertical, showsIndicators: Bool = true, @ViewBuilder content:)`.

Unlike `List`, `ScrollView` renders a single content view, not rows → there is **no** data/keyed-id
init (it would just wrap `ForEach` for marginal value). Compose `ForEach` inside the content closure.

## Programmatic scroll (scroll-to-top/bottom) — no new Sendable types

`ScrollViewProxy` is `~Sendable` in the SDK, so Cosmos does **not** wrap it in a struct or inject it
via `@Entry` (that would force a `Sendable` question and risk concurrency warnings). Instead, the
recipe layers ergonomics on the **native** `ScrollViewReader`:

- `CosmosScrollAnchor` — `enum: String, Hashable, Sendable, CaseIterable { top, bottom }` with
  `scrollID` (`"cosmos.scroll.top"` / `"cosmos.scroll.bottom"`).
- `extension ScrollViewProxy` — `scrollToTop()` / `scrollToBottom()` / `scrollTo(_:)` (no stored
  state → no `Sendable` issue).
- `View.cosmosScrollAnchor(_:)` — applies `.id(anchor.scrollID)` to tag a content edge.

```swift
ScrollViewReader { proxy in
    VStack(spacing: 0) {
        CosmosScrollView {
            Color.clear.frame(height: 1).cosmosScrollAnchor(.top)
            // …content…
        }
        CosmosButton("scroll.top", action: { proxy.scrollToTop() })
    }
}
```

The base atom does **not** wrap content in `ScrollViewReader` (only needed for `proxy.scrollTo`).
A dedicated `CosmosScrollToTopButton` molecule is deferred to the Molecules wave.

## Platform-guarded pass-throughs — the only `#if os()` wrappers

Mirrors [[cosmos-section]]'s `cosmosListSectionSpacing` discipline: wrap only what is
platform-fragmented; apply universal-floor modifiers natively (as [[cosmos-list]] does for
`.refreshable`).

| Modifier | iOS | macOS | tvOS | watchOS | visionOS | Wrapper |
|---|---|---|---|---|---|---|
| `scrollDismissesKeyboard` | 16 | 13 | 16 | 9 | **unavail** | `cosmosScrollDismissesKeyboard` — **whole wrapper `#if !os(visionOS)`** |
| `scrollEdgeEffectStyle` | **26** | **26** | **26** | **26** | **unavail** | `cosmosScrollEdgeEffectStyle` — declared on all 5; **no-op body on visionOS** |

**Compile-critical nuance** (why the two wrappers differ):
- `ScrollDismissesKeyboardMode` **type** is `@available(visionOS, unavailable)` → on visionOS callers
  cannot even construct a value to pass → the **entire function** (signature + body) is gated
  `#if !os(visionOS)` (the [[cosmos-section]] `ListSectionSpacing` precedent — declare the overload
  only where the parameter type exists).
- `ScrollEdgeEffectStyle` **type** IS available on visionOS 26 (only the **modifier** is
  unavailable) → the wrapper is declared on all 5 platforms and no-ops on visionOS.

Native-applicable (universal floor — do **not** wrap): `.scrollPosition(id:)` / `.scrollPosition(_:)`,
`.scrollTargetBehavior` / `.scrollTargetLayout`, `.onScrollGeometryChange` /
`.onScrollVisibilityChange` / `.onScrollPhaseChange`, `.defaultScrollAnchor`, `.scrollIndicators`,
`.refreshable`, `.contentMargins`, `.scrollTransition`, `.scrollClipDisabled`,
`.scrollContentBackground`.

## Availability — verified from the Xcode 27 Beta.3 `.swiftinterface`

**All scroll APIs are floor (≤ .v26).** None are above-floor 27 → **zero** `#if swift(>=6.4)`
compile gates and **zero** runtime `if #available` gates in Wave F. The only OS-27 scroll-adjacent
APIs (`toolbarMinimizeBehavior(_:for:)`, `swipeActionsContainer()`,
`swipeActions(…onPresentationChanged:)`) belong to Wave I / row context, not this atom.

`scrollPosition(id:)` = iOS 17 / macOS 14 / tvOS 17 / watchOS 10 / visionOS (`*`). `scrollPosition(_:)` +
`ScrollPosition` = iOS 18 family (incl. watchOS 11, visionOS 2). `onScrollGeometryChange` /
`ScrollGeometry` / `onScrollVisibilityChange` / `onScrollPhaseChange` = iOS 18 family.
`scrollTargetBehavior` / `scrollTargetLayout` / `defaultScrollAnchor` / `scrollTransition` /
`contentMargins` / `safeAreaPadding` / `scrollClipDisabled` = iOS 17 family. `scrollIndicators` =
iOS 16 family. `refreshable` = iOS 15 / watchOS 8. `scrollEdgeEffectStyle` = floor-exact 26
(off-visionOS).

### ⚠️ SDK-vs-web correction

A web-research agent reported `scrollDismissesKeyboard` unavailable on tvOS/watchOS & available on
visionOS, and `scrollEdgeEffectStyle` available on visionOS 26. The `.swiftinterface` says the
**opposite**: both are available on iOS/macOS/tvOS/watchOS and `@available(visionOS, unavailable)`.
**The SDK wins** (per `CLAUDE.md`: re-verify `@available` against the Xcode `.swiftinterface` — the
#1 historical rework source). This is exactly why direct interface verification is binding.

## AnyLayout reflow — honest reading of PHASE4 principle #1

`CosmosScrollView` does **not** auto-switch its scroll axis by `horizontalSizeClass`. Switching a
`ScrollView`'s axis destroys scroll position/offset identity — the *opposite* of principle #1's
"preserve view identity" goal. The axis is caller-chosen and fixed; `AnyLayout` / `ViewThatFits`
reflow applies to the **content layout inside** the scroll view, not the scroll axis. Use stable row
identity (`ForEach(data:id:)` with stable IDs) so focus/scroll/animation survive reflow.

## Testing

`Tests/CosmosTests/CosmosWaveFAtomsTests.swift` — `CosmosScrollAnchor.allCases` + stable ids +
Hashable/Sendable; full `CosmosScrollAvailability` × `CosmosPlatform` matrix (both modifiers `false`
on visionOS, `true` elsewhere). Pure, host-agnostic (no theme-selector tests — none exist for this
wave). 193 tests passing; builds clean on all 5 platforms.