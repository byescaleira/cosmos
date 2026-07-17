# Cosmos Phase 3 — Wave E Refinements Spec

> Source of record: the four explicitly-deferred Wave E items recorded in `ROADMAP.md` → "Later →
> Deferred from Wave E (recorded decisions, not lost work)". This document is implementation-ready:
> an engineer builds each item from its section below, in the order given in §1, applying the PHASE2
> §5 cross-cutting checklist per item, and resolving the §6 TODOs during implementation.
>
> **Baseline.** Cosmos 26 (OS 26 / Liquid Glass), deployment target `.v26` on all 5 platforms,
> Xcode 27.0.0 Beta 3 toolchain. Every `@available` clause below is quoted from the Xcode 27 Beta 3
> `SwiftUI.swiftinterface` (iOS interface carries the full cross-platform clauses).

---

## 1. Overview & Implementation Order

Phase 3 closes out the four Wave E deferrals. Risk is driven by two new axes this phase introduces:

- **Floor crossing.** Two items are *above* the Cosmos 26 floor (OS 27 / iOS 26.1). Until now every
  style applier in the library was compile-time `#if os()` only. Phase 3 introduces the **first
  runtime `if #available` gate inside a style applier** (`.tabs`) and the **first "available since
  Cosmos 27" public surface** (`.tabs`, `TabRole.prominent`). This is a pattern shift: the appliers
  become version-aware, not just platform-aware.
- **Selection fragmentation.** `CosmosSelectableList` is the first atom that exposes a selection
  binding whose inits fragment across platforms (Set watchOS-unavailable; non-optional single
  macOS-only). It reuses the AnyView-in-init trick proven on `CosmosTabView`.

### Build order (low-risk first: within-floor extension → within-floor new atom → above-floor)

1. **`CosmosSlider` iOS 26 cluster** (§2.2) — extend an existing, already-`#if !os(tvOS)`-guarded
   atom; all cluster APIs are within-floor init parameters; no new guard pattern. Lowest risk.
2. **`.cosmosTabViewBottomAccessory(isEnabled:)`** (§2.4) — one overload added to an existing
   `#if os(iOS)` modifier; a single shallow `if #available(iOS 26.1, *)` gate. Smallest above-floor
   step, validates the runtime-gate mechanics before the harder §2.3.
3. **`CosmosSelectableList`** (§2.1) — new atom; reuses the List style applier + the AnyView-in-init
   + haptic-gate patterns; within-floor. Medium risk (new public surface, selection branching).
4. **OS-27 surfaces: `TabsPickerStyle` (`.tabs`) + `TabRole.prominent`** (§2.3) — the first
   combined compile + runtime guard in a style applier + the first Cosmos-27 surface. Highest risk;
   done last so the runtime-gate mechanics are already proven on §2.4.

**Rationale.** §2.2 and §2.4 are surgical and prove no new mechanism (§2.4 proves the *shallow*
runtime gate). §2.1 proves the selection-atom shape on within-floor APIs. §2.3 then layers the
combined compile + runtime guard and the Cosmos-27 versioning story on top of settled mechanics.

---

## 2. Per-Item Spec

### 2.1 CosmosSelectableList (within floor; new atom)

- **Pattern:** wrap-view (`ListStyle` is opaque / native-bridged — only `_makeView`/`_makeViewList`,
  no `makeBody`; same reason as `CosmosList`). **Reuses** `CosmosListStyle` /
  `CosmosListAvailability` / `CosmosListStyleApplier` from `CosmosList` — factor the applier to an
  internal type both atoms reference, OR have `CosmosSelectableList` call the existing applier
  directly (it is `private` today; promote to `file`/`internal` if shared). The
  `CosmosListAvailability` table + `resolve` fallback apply unchanged.
- **Selection fragmentation (verified, Xcode 27 Beta 3 `List` interface):**

  | Selection shape | iOS | macOS | tvOS | watchOS | visionOS |
  |---|---|---|---|---|---|
  | `Set` multi — `Binding<Set<SelectionValue>>?` | 13 | 10.15 | 13 | **✗ unavailable** | 1 (`*`) |
  | Optional single — `Binding<SelectionValue?>?` | 13 | 10.15 | 13 | **10** | 1 (`*`) |
  | Non-optional single — `Binding<SelectionValue>` | **✗** | **13 only** | **✗** (data-bearing Identifiable adds **18**) | **✗** | **✗** |

  `SelectionValue: Hashable` (native struct constraint). The optional-single content-only init is
  `init(selection: Binding<SelectionValue?>?, content:)` (`@available(watchOS 10.0, *)`).

- **API design:** expose **optional-single selection as the universal primary**
  (`selection: Binding<SelectionValue?>`, `SelectionValue: Hashable & Sendable` — `Sendable` added
  to drive `.cosmosHaptic(.selection, trigger:)`, as on `CosmosTabView`/`CosmosPicker`). This is
  the one shape portable to all 5 platforms (watchOS 10+ ≤ floor). Add **`Set`-based multi-selection
  inits** (`selection: Binding<Set<SelectionValue>>`) guarded `#if !os(watchOS)` (the `Set` init
  and its type are watchOS-unavailable → whole-function guard, like
  `cosmosTabViewCustomization`). **Drop** the non-optional-single surface (macOS-only, unavailable
  on iOS/tvOS/watchOS/visionOS) to keep the API clean — document the drop and the native
  `List(selection:)` escape hatch, mirroring `CosmosList`'s "deferred selection" doc voice.
- **Inits to expose:**
  - `init(selection: Binding<SelectionValue?>, @ViewBuilder content:)` — universal primary.
  - `init<Data, RowContent>(_ data:, selection: Binding<SelectionValue?>, @ViewBuilder rowContent:)`
    (Identifiable) and `(_ data:, id:, selection:, rowContent:)` — data-bearing optional-single
    (watchOS 10+).
  - `#if !os(watchOS)` Set cluster: `init(selection: Binding<Set<SelectionValue>>, @ViewBuilder
    content:)` + data-bearing `Set` inits (Identifiable + id).
- **Generic shape / AnyView-in-init:** selection-bearing `List` inits construct generic view types
  distinct from the no-selection `List` (and the `Set` vs optional-single inits differ too). Apply
  the **same AnyView-in-init trick as `CosmosTabView`**: build the native `List(selection:content:)`
  in each init (where the per-init constraints are concrete), type-erase to `AnyView`, and apply the
  env-driven style applier + accessibility + selection haptic in `body` (where the trigger is read
  fresh each render). Modifiers read `@Environment` lazily at render, so building in the init is
  safe.
- **Haptics:** `.selection` on `selection.wrappedValue` change via `.cosmosHaptic(_:trigger:)`,
  gated through `CosmosHapticsPolicy` (config + Reduce Motion). Use a
  `CosmosSelectionHapticGate<SelectionValue: Equatable & Sendable>: ViewModifier` (mirror
  `CosmosTabHapticGate`) applied in `body` — pass-through when the binding is nil (not applicable
  here since the primary is non-optional, but the `Set` branch triggers on the `Set` value).
- **Motion:** `valueChange` applied to **dependent surrounding content**, NOT to the List (native
  selection animation is system-driven; a differing curve desyncs — same rule as `CosmosPicker` /
  `CosmosTabView`). Callers coordinate with a single
  `withAnimation(theme.motion.spring(for: .valueChange).animation) { selection = newValue }`.
- **Tracking:** `CosmosTrackingConfiguration.track(.valueChange)` on selection change; the List
  container is otherwise structural (like `CosmosList`).
- **Accessibility:** selectable rows get `.accessibilityAddTraits(.isButton)` (+ `.isSelected` when
  bound) at the row level (caller-driven). Apply `.cosmosAccessibilityLabel`/`.Hint`/`.Identifier`
  for the list itself. Row identity must be stable across reflow (`ForEach(data:id:)` with stable
  IDs) so selection/focus/scroll survive.
- **Key modifiers to wire:** `.listStyle(_:)` (via the shared applier + `theme.listStyle`),
  `.cosmosListStyle(_:)` (per-instance override, reuse the existing modifier),
  `.cosmosHaptic(.selection, trigger:)` (gated), `.cosmosAnimation(.valueChange, value:)` on
  dependent content, `.accessibilityAddTraits(.isButton/.isSelected)` on rows.
- **Open risks / TODOs:** confirm the shared applier visibility refactor doesn't break
  `CosmosList`; verify the `Set` inits compile out cleanly on watchOS (whole-function guard — the
  `Binding<Set<SelectionValue>>` type itself is fine on watchOS, only the `List` `Set` *init* is
  unavailable, so the guard is on the init body referencing `List(selection: Binding<Set<...>>...)`;
  re-confirm whether the `Set` *init* or the *type* is the unavailable symbol — if the init only,
  a body-only guard inside `#if !os(watchOS)` suffices); verify optional-single `Binding<SelectionValue?>`
  vs the native `Binding<SelectionValue?>?` (Cosmos exposes non-optional binding of optional value —
  map to the native `?`-bearing init by passing the binding directly).

### 2.2 iOS 26 CosmosSlider cluster (within floor; extend CosmosSlider)

- **Scope:** add **init** surface (every cluster item is an init parameter, not a modifier) for the
  native iOS 26 `Slider` cluster:
  `init<V>(value:, in:, neutralValue: V? = nil, enabledBounds: ClosedRange<V>? = nil, label:,
  currentValueLabel:, minimumValueLabel:, maximumValueLabel:, onEditingChanged:)` and the
  `ticks: @SliderTickBuilder<V>` / `tick: (V) -> SliderTick<V>?` variants.
- **Verified availability:** `@available(iOS 26.0, macOS 26.0, watchOS 26.0, visionOS 26.0, *)` +
  `@available(tvOS, unavailable)` — **within-floor on all four Slider platforms** (iOS/macOS/watchOS/
  visionOS 26). No runtime gate; the existing `#if !os(tvOS)` atom guard covers tvOS.
- **Parameter shapes (corrected from earlier drafts):**
  - `neutralValue: V? = nil` — optional value of the slider's `BinaryFloatingPoint` type.
  - `enabledBounds: ClosedRange<V>? = nil` — **a plain optional `ClosedRange<V>?`, NOT a `Binding`,
    NOT `Float`-only.** An enabled subrange the thumb can travel (visually de-emphasizes the rest).
  - `currentValueLabel: () -> some View` — a new `@ContentBuilder` closure, distinct from the legacy
    `label:`; renders the current value.
  - `ticks: () -> some SliderTickContent<V>` via `@SliderTickBuilder<V>`; the step variant takes
    `tick: (V) -> SliderTick<V>?`. Supporting types `SliderTick<V>` / `SliderTickContent<V>` /
    `SliderTickBuilder<V>` / `SliderTickContentForEach` all carry the same `@available` clause.
  - **There is NO `.ticks(_:)` modifier and NO `TickConfiguration` / `SliderTickConfiguration`
    type** — do not invent them.
- **Design — stay `Double`-pinned:** the current `CosmosSlider` is `Double`-pinned (`Binding<Double>`,
  `ClosedRange<Double>`, `Double.Stride`). The cluster inits are generic
  `<V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint>`; forward with **`V = Double`** (Double
  conforms), so **no generic rewrite** of the existing atom is needed. `enabledBounds` becomes
  `ClosedRange<Double>?`, `neutralValue` `Double?`. Add new inits that thread the four new params
  through to the native cluster init, defaulting `nil`/`EmptyView()` to preserve the existing API.
- **Guard:** `#if !os(tvOS)` (whole atom already guarded). Keep the cluster in a clearly-marked
  `.v26` init cluster (comment the iOS/macOS/watchOS/visionOS 26 origins for floor-lowering).
- **Pure math to add (CosmosSliderMath):** `enabledBounds` clamping — intersect the value range
  with the enabled subrange so the reported/stepped value respects the enabled bounds — and
  tick-snap (align a value to the nearest `SliderTick` value). Pure functions, testable without
  rendering, reusing the existing `CosmosSliderMath.stepped` pattern.
- **Motion:** `neutralValue` crossing → `valueChange` coordinated with `.cosmosContentTransition`
  on the tint; **do NOT wrap the binding in `withAnimation` per drag frame** (existing rule —
  `withAnimation` fights the gesture). Thumb tracking is motion-as-sole-signal (`.preserve`,
  WCAG 2.3.3 exempt).
- **Haptics:** unchanged from the existing atom (`.selection` on step-snap when `step > 0`); the
  cluster adds no new haptic trigger.
- **Accessibility:** `enabledBounds` narrows the adjustable range — set `.accessibilityValue` and
  `.accessibilityHint` to reflect the enabled subrange when it differs from the full bounds. Ticks
  are announced by the native control.
- **Open risks / TODOs:** verify `enabledBounds` interaction with `step` (does the stepped value
  clamp to enabled bounds — codify in `CosmosSliderMath`); verify `currentValueLabel` reflows under
  Dynamic Type; verify watchOS small-screen rendering of ticks; confirm forwarding `V = Double`
  resolves the `@SliderTickBuilder<V>` builder without a generic atom.

### 2.3 OS-27 surfaces: TabsPickerStyle (`.tabs`) + TabRole.prominent (above floor)

- **`TabRole` has only two cases (verified):** `.search` (floor `@available(iOS 18.0, macOS 15.0,
  tvOS 18.0, watchOS 11.0, visionOS 2.0, *)`) and `.prominent`
  (`@available(anyAppleOS 27.0, *)`). **There is NO `TabRole.regular`.** "No role" on a `Tab` is
  expressed by omitting the `role:` parameter (nil).
- **`CosmosTabRole` enum:** `.none` (default — no role, `role: nil`), `.search` (within floor), and
  `.prominent` (gated). `Sendable`, `CaseIterable`, `Codable`. Expose a `cosmosTabRole(_:)`
  modifier that applies the role to each `Tab` inside the `@TabContentBuilder` closure; `.prominent`
  is gated `if #available(iOS 27, macOS 27, tvOS 27, watchOS 27, visionOS 27, *)` (the per-platform
  spelling of `anyAppleOS 27`) and falls back to `.none` below 27. This centralizes the gate callers
  currently write themselves.
- **`TabsPickerStyle` (`.tabs`) — verified:** `@available(iOS 27.0, macOS 27.0, tvOS 27.0,
  visionOS 27.0, *)` + `@available(watchOS, unavailable)`. OS 27 on iOS/macOS/tvOS/visionOS;
  **watchOS compile-time unavailable.** Add a `.tabs` case to `CosmosPickerStyle` and to
  `CosmosPickerAvailability` (available iOS/macOS/tvOS/visionOS at 27; never watchOS).
- **The applier needs a COMBINED compile + runtime guard** — the first of its kind in the library:

  ```swift
  case .tabs:
      #if !os(watchOS)
      if #available(iOS 27, macOS 27, tvOS 27, visionOS 27, *) {
          content.pickerStyle(.tabs)
      } else {
          content.pickerStyle(.automatic)
      }
      #else
      content.pickerStyle(.automatic)
      #endif
  ```

  `#if !os(watchOS)` because the `TabsPickerStyle` *type* is watchOS-unavailable (body-only guard
  insufficient — same lesson as `TabViewCustomization`); the inner `if #available` handles the
  above-floor OS-27 bound on the other four platforms. **Document this pattern prominently** and add
  a row to the VERSIONING.md centralized-gates list.
- **Versioning:** "available since Cosmos 27" == `@available(iOS 27, *)`. This is the **first
  "available since Cosmos 27" public surface**; document the forward-versioning step in
  `VERSIONING.md` + `CHANGELOG.md`. `CosmosPickerAvailability.isAvailable(.tabs, on:)` returns
  `false` at the Cosmos-26 view of the table on every platform (it is *available since* 27, not at
  26) — the table models the *floor* availability; the runtime gate handles 27+. (Decide and
  document whether `isAvailable` models "available at the baseline" (false for `.tabs`) or
  "available on this platform at all" (true for iOS/macOS/tvOS/visionOS) — recommend the former for
  consistency with the existing within-floor table semantics, with a separate
  `isAvailableSince27`-style predicate if needed.)
- **Accessibility / haptics / motion:** unchanged from `CosmosPicker` (`.tabs` is a picker style;
  the atom's `.selection` haptic + `valueChange`-on-dependent-content rules apply). `TabRole.prominent`
  is purely visual prominence; no haptic/motion impact.
- **Open risks / TODOs:** confirm the exact `if #available` multi-platform spelling compiles on all
  5 platforms (the `anyAppleOS 27` shorthand is interface-only; source must spell per-platform);
  verify `.tabs` rendering on iOS/macOS/tvOS/visionOS 27 in `#Preview` (needs a 27 simulator);
  decide `isAvailable` semantics for above-floor styles (see above); verify `cosmosTabRole(.prominent)`
  falls back gracefully below 27 (no crash, no warning).

### 2.4 .cosmosTabViewBottomAccessory(isEnabled:) (iOS 26.1; above floor)

- **Scope:** add the `isEnabled:` overload alongside the existing
  `.cosmosTabViewBottomAccessory(content:)` (iOS 26.0, already shipped in `CosmosTabView.swift`).
  The `isEnabled:` overload is iOS 26.1.
- **Guard:** `#if os(iOS)` (existing outer guard) **+** inside it a shallow runtime
  `if #available(iOS 26.1, *)` gate. Below 26.1, fall back to the non-`isEnabled` form (forward
  `content` without the enabled flag) or no-op — recommend forwarding to the existing 26.0 overload
  so behavior degrades gracefully. This is the **shallowest runtime gate** in the library and the
  mechanical warm-up for §2.3's combined guard.

  ```swift
  #if os(iOS)
  public func cosmosTabViewBottomAccessory<C: View>(
      isEnabled: Bool,
      @ViewBuilder content: @escaping () -> C
  ) -> some View {
      if #available(iOS 26.1, *) {
          self.tabViewBottomAccessory(isEnabled: isEnabled, content: content)
      } else {
          self.tabViewBottomAccessory(content: content)   // degrade to 26.0 form
      }
  }
  #endif
  ```

- **Versioning:** label "available since Cosmos 26.1" (a minor within Cosmos 26); document in
  `VERSIONING.md` + `CHANGELOG.md`.
- **Open risks / TODOs:** confirm the `isEnabled:` overload's exact signature in the Xcode 27
  interface (re-quote); verify the degrade path compiles on iOS 26.0 (the 26.0 overload is
  within-floor, no gate needed for the fallback branch).

---

## 3. Motion-Intent Matrix (additions to PHASE2 §3)

| Item | CosmosMotionKind | Rationale | Reduce-motion handling |
|---|---|---|---|
| CosmosSelectableList | valueChange (selection) | Selection binding mutation | Applied to **dependent surrounding content**, NOT the List (native selection animation system-driven; differing curve desyncs). Single `withAnimation(theme.motion.spring(for: .valueChange))` on the selection write |
| CosmosSlider cluster | valueChange (neutralValue crossing) | Tint crossfade when the value crosses `neutralValue` | `.cosmosContentTransition` on the tint; do NOT wrap the binding per drag frame (gesture-tracked — `.preserve`, WCAG 2.3.3 exempt) |
| TabsPickerStyle (.tabs) | valueChange | Picker selection (same as CosmosPicker) | Same as `CosmosPicker` — apply to dependent content only |
| TabRole.prominent | none | Visual prominence only | n/a |
| bottomAccessory(isEnabled:) | none | Static accessory chrome | n/a |

---

## 4. Platform-Guard Reference (additions to VERSIONING.md §4)

| Item | `#if os()` guard | Fallback on missing | Runtime `if #available` gates |
|---|---|---|---|
| CosmosSelectableList | `#if !os(watchOS)` for the `Set` selection inits (watchOS-unavailable) | Optional-single selection is the universal primary (watchOS 10+ ≤ floor); `Set` inits omitted on watchOS | none within floor |
| CosmosSlider cluster | `#if !os(tvOS)` (existing atom guard) | n/a (tvOS: whole atom absent) | none — cluster is within-floor iOS/macOS/watchOS/visionOS 26 |
| TabsPickerStyle (.tabs) | `#if !os(watchOS)` (type watchOS-unavailable) | `.automatic` below 27 and on watchOS | **`if #available(iOS 27, macOS 27, tvOS 27, visionOS 27, *)`** inside `#if !os(watchOS)` — **first runtime gate in a style applier** |
| TabRole.prominent | none (type available all 5 at floor; `.prominent` case is `anyAppleOS 27`) | `.none` (no role) below 27 | **`if #available(iOS 27, macOS 27, tvOS 27, watchOS 27, visionOS 27, *)`** |
| bottomAccessory(isEnabled:) | `#if os(iOS)` (existing) | Degrade to the 26.0 `content:`-only overload below 26.1 | **`if #available(iOS 26.1, *)`** |

**Centralized `if #available` note (update).** Phase 3 adds the first above-floor runtime gates to
the centralized list: `TabsPickerStyle`/`.tabs` (OS 27, watchOS compile-unavailable); `TabRole.prominent`
(`anyAppleOS 27`); `.cosmosTabViewBottomAccessory(isEnabled:)` (iOS 26.1). These are the first
"available since Cosmos 27" (and Cosmos 26.1) surfaces; the `.v26` deployment target is unchanged.

---

## 5. Cross-Cutting Integration Checklist

Reuse **PHASE2 §5 verbatim** (all 11 items: accessibility, haptics, localization, tracking, motion,
enable, loading, log, error, layout-adaptive, multiplatform). The only Phase-3 additions:

- **Multiplatform (item 11) now includes runtime `if #available` gates** alongside the compile-time
  `#if os()` guards — verify both layers per platform. The §2.3 combined guard is the canonical
  example.
- **Versioning labeling:** each above-floor API is labeled "available since Cosmos N.M"
  (`@available(iOS N, *)`); document in `VERSIONING.md` + `CHANGELOG.md`.

---

## 6. Open Risks & Verification TODOs

**CosmosSelectableList.**
- Confirm whether the watchOS `Set` unavailability is the *init* or the *type* — if the
  `List(selection: Binding<Set<...>>...)` *init* is the unavailable symbol (likely), a body-only
  `#if !os(watchOS)` guard inside the init suffices; if the *type* `Binding<Set<SelectionValue>>` is
  fine on watchOS, the whole-function guard is only needed around the `List(...)` call. Re-quote the
  interface to pin this.
- Verify the shared `CosmosListStyleApplier` visibility refactor doesn't break `CosmosList`.
- Verify `Binding<SelectionValue?>` (Cosmos, non-optional binding of optional value) maps cleanly to
  the native `init(selection: Binding<SelectionValue?>?, content:)` (native takes an optional
  binding — pass directly).
- Row identity stability across reflow (stable IDs, no `if/else` identity recreation) — verify in
  Dynamic Type + landscape previews.

**CosmosSlider cluster.**
- Verify `enabledBounds` × `step` interaction (stepped value clamps to enabled bounds) — codify in
  `CosmosSliderMath`.
- Verify `currentValueLabel` reflows under Dynamic Type; verify watchOS small-screen tick rendering.
- Confirm forwarding `V = Double` resolves `@SliderTickBuilder<V>` without making the atom generic.

**OS-27 surfaces.**
- Confirm the exact `if #available(iOS 27, macOS 27, tvOS 27, watchOS 27, visionOS 27, *)`
  multi-platform spelling compiles on all 5 platforms (`anyAppleOS 27` is interface-only).
- Decide `CosmosPickerAvailability.isAvailable(.tabs, …)` semantics: "available at the Cosmos 26
  baseline" (false everywhere — recommended) vs "available on this platform at all" (true on
  iOS/macOS/tvOS/visionOS). Document the choice; add a separate `isAvailableSince27`-style
  predicate if the latter is needed.
- Verify `.tabs` + `cosmosTabRole(.prominent)` rendering on a 27 simulator in `#Preview`; verify
  graceful below-27 fallback (no crash, no warning).

**bottomAccessory(isEnabled:).**
- Re-quote the exact `isEnabled:` overload signature from the Xcode 27 interface; verify the
  degrade-to-26.0 fallback branch compiles on iOS 26.0.

**Refuted-spec items corrected (re-confirm during implementation).**
- `TabRole.regular` does **not** exist in the Xcode 27 SDK — only `.search` + `.prominent`. Any
  earlier reference to `.regular` is wrong.
- `enabledBounds` is `ClosedRange<V>?`, **not** `Binding<(ClosedRange<Float>)>` and not `Float`-only.
- `ticks` is an init parameter via `@SliderTickBuilder<V>`, **not** a `.ticks(_:)` modifier; there
  is no `TickConfiguration` type.
- The iOS 26 Slider cluster **includes macOS 26.0** (not iOS/watchOS/visionOS only).

---

## 7. Test Plan Per Item

Tests use Swift Testing (no snapshots, no ViewInspector), reusing the Wave E test scaffolding
(`CosmosWaveEAtomsTests`). Test pure logic — config defaults, fluent builders, availability tables,
guard logic, motion/haptic policy gating — not rendered view trees.

**CosmosSelectableList.**
- Selection-init availability table as pure data: `Set` × platform (watchOS false),
  optional-single × platform (all true, watchOS 10 ≤ floor), non-optional-single × platform
  (macOS only — and document it's dropped from the API).
- `resolve` fallback (reuse `CosmosListAvailability.resolve` — unchanged).
- Theme selector reuse (`theme.listStyle` default `.automatic`; `withListStyle` non-mutation —
  already covered by Wave E tests, re-reference).
- Selection-haptic gate predicate (fires on selection change, gated by `CosmosHapticsPolicy`).

**CosmosSlider cluster.**
- `CosmosSliderMath` cluster math: `enabledBounds` clamping (value outside enabled subrange clamps
  to nearest enabled bound; `nil` enabledBounds is passthrough); tick-snap (aligns to nearest tick
  value) — pure functions.
- Cluster-init availability predicate (iOS/macOS/watchOS/visionOS 26 yes; tvOS no).
- `neutralValue` crossing motion mapping (valueChange + contentTransition) — token resolution.

**OS-27 surfaces.**
- `CosmosPickerStyle.allCases` includes `.tabs` (last).
- `CosmosPickerAvailability.isAvailable(.tabs, …)` per the chosen semantics (recommended: false at
  baseline on all 5; true on iOS/macOS/tvOS/visionOS only via a separate predicate).
- `resolve(.tabs, …)` fallback to `.automatic` below 27 / on watchOS.
- `cosmosTabRole(.prominent)` gate predicate (resolves to `.none` below 27).

**bottomAccessory(isEnabled:).**
- Overload availability predicate (iOS 26.1 gate; compile-absent on non-iOS).

**Build verification gate.** `swift build && swift test && swift build -c release`, then build for
EACH target platform (iOS/macOS/tvOS/watchOS/visionOS triples) to confirm `#if os()` + the new
`if #available` coverage, **zero concurrency warnings**. Visual verification via co-located
`#Preview` blocks (default / disabled-loading / dark / Dynamic Type accessibility / landscape / RTL
/ per-platform) using `#Preview(_:traits:)` — NOT the deprecated `.previewDevice`/`.previewLayout`;
inject env via `.cosmosPreviewEnv(...)`/`.cosmosPreviewVariant(_:)`; shared setup via
`CosmosPreviewModifier`. Above-floor previews (`.tabs`, `.prominent`) need a 27 simulator to render
the gated path; the below-27 fallback path must also be previewed.