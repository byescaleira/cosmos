---
tags: [methodology, planning, roadmap, phase4, navigation, layout]
aliases: [PHASE4 plan, core navigation atoms, CosmosScrollView, CosmosAsyncImage, CosmosForm, CosmosNavigation]
related: [cosmos-tabview, cosmos-list, cosmos-section, cosmos-picker, Home]
---

# PHASE4 — Core navigation & layout atoms (planning note)

Synthesis of the roadmap restructure ([[ROADMAP]]) that adds the navigation/layout core missing from
PHASE2. **Source of truth = `ROADMAP.md`**; this note is the navigation layer. On conflict, the root
doc wins.

## Why this phase

The 21 atoms shipped in PHASE2 cover basic controls, but real apps need the navigation/layout core:
`CosmosScrollView`, `CosmosAsyncImage`, `CosmosForm`, `CosmosNavigation` (NavigationStack +
NavigationSplitView). Scope is the **core subset only** — the rest (Grids/Lazy, Table,
Outline/Disclosure, ShareLink, ColorPicker, standalone ControlGroup, Spacer, Badge, presentation,
drawing) is deferred to PHASE5+. Per-wave blueprints are **not** written yet; they are produced at
each wave's implementation time, with every `@available` clause re-verified against the Xcode
`.swiftinterface` (the #1 historical rework source — see [[header-prominence-not-a-real-api]]).

## Waves (low-risk-first)

| Wave | Atom | Shape | Pattern tag |
|---|---|---|---|
| F | `CosmosScrollView` | wrap-View | scroll-to helpers, position/visibility tracking, `AnyLayout` axis reflow |
| G | `CosmosAsyncImage` | wrap-View | `AsyncImagePhase` → placeholder/error/retry slots, phase transitions via `.cosmosTransition(.blurReplace)` + a motion-policy-gated `Transaction`; OS-27 `asyncImageURLSession` cache surface (dual-gated). **Shipped.** |
| H | `CosmosForm` | custom-style + wrap-View | `CosmosFormStyle`/`CosmosFormChrome: FormStyle` `makeBody` + `CosmosControlGroupStyle` sibling |
| I | `CosmosNavigation` | wrap-View + AnyView-in-init | Stack vs SplitView, typed route + `path` binding, `columnVisibility`, [[cosmos-tabview]] composition |

## Standing design principles

1. **Size-class-adaptive reflow preserves view identity** — `AnyLayout` / `ViewThatFits` switched by
   `horizontalSizeClass` / `verticalSizeClass` / `dynamicTypeSize`; never `if/else` that recreates
   identity. Applies to Scroll / Form axis reflow.
2. **Stack ↔ SplitView is the documented exception** — `AnyLayout` cannot erase `NavigationStack`
   into `NavigationSplitView` (different root types; neither is a `Layout`). Default to a single
   `NavigationSplitView` root (auto-collapses to stack nav in compact — identity-preserving). When an
   explicit compact `NavigationStack` is required, select one root per size class via AnyView-in-init
   and **persist logical nav state in shared bindings** (`path`, `columnVisibility`, `selectedRoute`).
   Honest tradeoff: physical view identity (focus, per-destination scroll, in-flight animation) does
   NOT survive the root switch; logical nav state (depth, selected route, column visibility) DOES.
3. **TabView ↔ Navigation contract** — each `Tab` hosts one `CosmosNavigation`; nav state is
   tab-scoped. Inside a `.sidebarAdaptable` [[cosmos-tabview]] tab, use the single-SplitView-root form
   and let the tab style own compact/regular chrome (no double-adaptation). No nav-side tab-switch
   haptic (the tab atom already fires `.selection`).
4. **Custom-style atoms reuse the GroupBox-proven sub-pattern** — selector enum + pure availability
   table + applier + `public struct: StyleProtocol` `makeBody(configuration:)` with theme tokens and
   `applyCosmosAccessibility` re-apply. `FormStyle` / `ControlGroupStyle` ARE conformable (unlike the
   opaque `PickerStyle` / `ListStyle` / `TabViewStyle`), so custom `makeBody` is genuinely possible.

## Reused infrastructure (no new patterns)

- AnyView-in-init + haptic-gate ViewModifier — cf. [[cosmos-tabview]] (`CosmosTabHapticGate`).
- Style-enum + `CosmosPlatform` availability table + applier — cf. [[cosmos-picker]], [[cosmos-list]].
- Custom-style `makeBody` chrome — cf. `CosmosGroupBoxChrome` (`Sources/Cosmos/Atoms/CosmosGroupBox.swift`).
- Motion chokepoint: `.cosmosAnimation` / `.cosmosTransition` / `.cosmosContentTransition` gated by
  `CosmosMotionPolicy`; never raw `.animation(_:value:)` on native-driven controls.
- Haptics: `.cosmosHaptic(_:trigger:)` gated by `CosmosHapticsPolicy`.

## Open risks / verification TODOs (blueprint time)

- `NavigationSplitView` three-column + `columnVisibility` on tvOS / watchOS at `.v26`.
- watchOS `Form` under custom `CosmosFormChrome` (watchOS `Form` is `List`-like); built-in
  `FormStyle` cases per platform.
- watchOS `ScrollView` surface (`ScrollViewReader`, `scrollPosition(id:)`,
  `onScrollGeometryChange` / `onScrollVisibilityChange`) — OS-27 vs floor.
- ~~`AsyncImage` watchOS cache / phase limits.~~ **Resolved (Wave G):** `AsyncImage` +
  `AsyncImagePhase` (`.empty`/`.success`/`.failure`; **no `.loading` case**, **no `.content`
  accessor** — use `phase.image`) are floor on all 5 (iOS 15 / macOS 12 / tvOS 15 / watchOS 8). The
  OS-27 cache surface `View.asyncImageURLSession(_:)` is `@available(anyAppleOS 27.0, *)` — **no
  watchOS/tvOS/visionOS carve-out** (verified in the Xcode 27 Beta.3 `.swiftinterface`); dual-gated
  `#if swift(>=6.4)` + `if #available(iOS 27, macOS 27, watchOS 27, tvOS 27, visionOS 27, *)`, OS-26
  falls back to the system default `URLSession`. See [[cosmos-async-image]].
- `FormStyle` / `ControlGroupStyle` built-in case availability per platform.
- OS-27 surfaces in PHASE4 scope that may need the runtime `if #available` gate (mechanic introduced
  in PHASE3; see [[ROADMAP]] / `PHASE3.md`).
- ~~Haptic kind for AsyncImage retry / error.~~ **Resolved (Wave G):** `CosmosHapticsFeedback.error`
  and `.warning` both exist (`Sources/Cosmos/Base/Configuration/CosmosHapticsConfiguration.swift`).
  Wave G fires `.error` **on failure appear** (via a `failureToken` `@State`), not on the retry tap —
  semantically correct (the error occurred); the retry tap is a `CosmosButton` that fires its own
  `.impact(.light)` (no double haptic). See [[cosmos-async-image]].
- `@preconformance @MainActor` conformance for `FormStyle` / `ControlGroupStyle` under Swift 6 v6.