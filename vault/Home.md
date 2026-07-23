---
tags: [moc, index]
aliases: [Cosmos vault, knowledge vault]
related: []
---

# Cosmos — Knowledge Vault

Synthesis/navigation layer for the [[Cosmos]] SwiftUI design-system library. The **source of truth stays the root docs** (`PHASE2.md`, `DECISIONS.md`, `ARCHITECTURE.md`, `VERSIONING.md`, `CLAUDE.md`); this vault is a synthesis layer. On conflict, the root doc wins — update the note.

> **Usage wiki:** the consumer-facing usage guide (API + runnable examples + best practices per atom) lives on the [GitHub Wiki](https://github.com/byescaleira/cosmos/wiki). This vault is the research/decisions layer (availability tables, gotchas, rationale); the wiki is the usage layer. They complement, they don't duplicate — source of truth remains the root docs.

## Folders

- `02-decisoes/` — new ADRs / decisions
- `03-componentes/` — atoms (per-component notes: API surface, platform availability, customization limits)
- `06-concorrencia/` — design-system comparison + Swift concurrency
- `07-metodologia/` — workflows / methods
- `08-riscos/` — open risks / refuted specs

## Methodology index

- [[phase4-core-navigation-atoms]] — PHASE4 roadmap restructure: core navigation/layout atoms (Scroll / AsyncImage / Form / Navigation), standing design principles (AnyLayout reflow, Stack↔SplitView identity crux, TabView↔Navigation contract, GroupBox-proven custom-style sub-pattern), waves F–I.
- [[above-floor-gating-pattern]] — PHASE3: the three above-floor (Cosmos-27) gate shapes (shallow runtime / combined compile+runtime / resolver), pure-table-vs-runtime separation, and the recorded `TabRole`-has-no-modifier deviation. Template for future OS-27 surfaces.
- [[ios-27-swiftui-above-floor-apis]] — research: every SwiftUI symbol genuinely introduced above the Cosmos-26 floor (`@available(*OS 27, *)`): `TabRole.prominent`, `NavigationTransition.crossFade`/`AnyNavigationTransition`, `PickerStyle.tabs`, toolbar (`topBarPinnedTrailing`/`toolbarMinimizeBehavior`/`visibilityPriority`/`ToolbarOverflowMenu`), `reorderContainer`/`reorderable`, document model, item/error-binding alerts, swipe-actions-anywhere, `AsyncImage(request:)`. Plus explicit floor confirmations (scroll geometry = iOS 18, `tabViewBottomAccessory` = iOS 26, glass = iOS 26, no new FormStyle/ControlGroupStyle/symbolEffect cases).

## Component index

- [[cosmos-section]] — `CosmosSection` (Wave E): `Section` wrap-view, container-modifier platform matrix.
- [[cosmos-picker]] — `CosmosPicker` (Wave E): `Picker` wrap-view, `PickerStyle` × platform matrix (9 styles incl. `.tabs` OS-27 combined gate), `Sendable` selection + `Label`-shadowing gotcha.
- [[cosmos-list]] — `CosmosList` (Wave E): `List` wrap-view, `ListStyle` × platform matrix (9 styles), no-selection primary, `#Preview`-struct-declaration gotcha.
- [[cosmos-selectable-list]] — `CosmosSelectableList` (PHASE3): selectable `List` wrap-view; one `Selection` generic unifies optional-single (all 5) + `Set` (`#if !os(watchOS)`); AnyView-in-init; `AnyHashable`-not-`Sendable` gotcha.
- [[cosmos-tabview]] — `CosmosTabView` (Wave E): `TabView` wrap-view, `TabViewStyle` × platform matrix (6 styles), modern `TabContentBuilder` inits only, AnyView-in-init for selectable/non-selectable unification; `CosmosTabRole` (`.prominent` OS-27 resolver) + `bottomAccessory(isEnabled:)` iOS-26.1 gate added in PHASE3.
- [[cosmos-scroll-view]] — `CosmosScrollView` (Wave F / first PHASE4): `ScrollView` wrap-view, no style selector (no `ScrollViewStyle`); programmatic scroll via native `ScrollViewReader` + `CosmosScrollAnchor` + `ScrollViewProxy` helpers; two visionOS-unavailable pass-throughs (`scrollDismissesKeyboard` whole-wrapper-gated, `scrollEdgeEffectStyle` no-op); all scroll APIs verified floor (≤ .v26); AnyLayout reflow applies to content, not axis.
- [[cosmos-async-image]] — `CosmosAsyncImage` (Wave G): `AsyncImage` wrap-view, no style selector (no `AsyncImageStyle`); `AsyncImagePhase` → placeholder/error/retry slots; phase transitions via `.cosmosTransition(.blurReplace)` + a motion-policy-gated `Transaction`; retry via `.id(retryToken)`; `.error` haptic on failure appear (button impact on retry — no double haptic); OS-27 cache surface (`CosmosImageCache` + `@Entry cosmosAsyncImageURLSession` + `asyncImageURLSession` dual-gated, no platform carve-out); flicker timer deferred.
- [[button-shapes-ios26-liquid-glass]] — research: Apple's Liquid Glass default button shape is **capsule** (WWDC25-323/284/356); `.glass`/`.glassProminent` default to `.buttonBorderShape(.capsule)`; `RoundedRectangle(cornerRadius:)` only for grouped/card/macOS-small-density; iOS 27 carries capsule forward (no new styles).
- [[cosmos-toast]] — `cosmosToast` (Wave H): presentation modifier mirroring `.sheet`/`.alert` binding API (`isPresented` + `item` + `onDismiss`). **No native `.toast` exists in iOS 26/27** — composes overlay + `.regularMaterial` surface + `.cosmosTransition(.slide/.sheet)` gated by `CosmosMotionPolicy`. Haptic on appear (policy-gated), tracking appear/dismiss, reduce-transparency → solid `surface`, optional `dismissAfter` auto-dismiss (cancellable `Task`, no `DispatchQueue`). Reuses existing motion presets — no new token.

## Design-system comparison index

- [[apple-ios26-sample-code-patterns]] — research: catalog of Apple's official iOS 26 / Liquid Glass sample code (Landmarks, Applying Liquid Glass to custom views, SampleTrips, Trails App Intents) with exact SwiftUI APIs each demonstrates; synthesis of conventions (capsule default glass button shape, GlassEffectContainer grouping, matchedTransitionSource+navigationTransition(.zoom) for sheets, backgroundExtensionEffect, one withAnimation per morph).

## Risks index

- [[header-prominence-not-a-real-api]] — PHASE2 §2.13 lists `.headerProminence(_:)`; it does **not** exist in the Xcode 27 SwiftUI SDK (refuted spec).