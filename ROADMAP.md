# Roadmap

> Last updated: 2026-07-18 (PHASE4 Wave G done — `CosmosAsyncImage` slot architecture + OS-27 cache
> surface; flicker timer deferred as a Wave-G refinement. Waves F + G shipped; Wave H `CosmosForm`
> next)
>
> This roadmap reflects the project state **after the from-scratch reset** that produced PHASE2.
> The earlier pre-reset cycle (molecules, `CosmosScreen` data-driven renderer, `CosmosImage`/
> `CosmosBadge`/`CosmosSpacer`, JSON loader) was discarded and is **not** carried forward here —
> those layers are to be (re)introduced as explicit next steps, not assumed done.

## Done (post-reset baseline)

### Package & platform
- [x] Bootstrap SPM package `Cosmos` for Apple v26 platforms (iOS / macOS / tvOS / watchOS / visionOS, all `.v26`)
- [x] Swift 6.4 toolchain, language mode v6, Xcode 26 — zero concurrency warnings
- [x] UIKit-free (CoreText font registration, `.sensoryFeedback` haptics, `Color(.systemBackground)`); no `#if canImport(UIKit)`
- [x] Single `Cosmos` target, no third-party dependencies; `CosmosTests` via Swift Testing

### Cross-cutting base (global, via `@Entry`)
- [x] `cosmosConfiguration` (enable, loading, accessibility, haptics, **motion**, tracking, localization, log, error) + `cosmosTheme` + `cosmosTrackingId`
- [x] Split behavior configuration (`CosmosConfiguration`) from visual theme (`CosmosTheme`); both `Sendable`
- [x] Runtime-mutable theming via `CosmosThemeObservable` (`@Observable @MainActor`)
- [x] Semantic token layer: `CosmosColorTokens`, `CosmosTypographyTokens`, `CosmosSpacingTokens`, `CosmosRadiusTokens`, `CosmosMotionTokens`
- [x] Versioning: Cosmos N ↔ OS N (baseline Cosmos 26); `@available(iOS 26,*)` == "since Cosmos 26"; `CosmosTheme.version` design pin

### Motion subsystem (9th cross-cutting contract)
- [x] `CosmosMotionConfiguration` (behavior/policy) + `CosmosMotionTokens` (visual: springs, durations, transition presets) + `CosmosMotionPolicy` (config-aware reduce-motion, not bare env)
- [x] `.cosmosAnimation` / `.cosmosTransition` / `.cosmosContentTransition` / `.cosmosMotion` / `.cosmosMotionTokens` / `.cosmosSpringStyle` modifiers; single source of truth via `CosmosMotionTokens.animation(for:)`

### Preview + mock infrastructure
- [x] `CosmosPreviewRNG` (SplitMix64 seeded; shared state via `Mutex`, never a raw `static var`)
- [x] `CosmosPreview` / `CosmosPreviewContainer` / `CosmosPreviewVariant` + `CosmosPreviewModifier` (`PreviewModifier` shared context)
- [x] `.cosmosPreviewEnv` / `.cosmosPreviewVariant` modifiers; `#Preview(_:traits:)` (no deprecated `.previewDevice`/`.previewLayout`)
- [x] `CosmosMock` deterministic generators (string/number/date/color/email/name/uuid/lorem/currency/percentage) + wordlists

### Atoms — PHASE2 §2.1–2.16 (Waves A–E)
- [x] Wave A (style-protocol, no guard): `CosmosLabel`, `CosmosProgress`, `CosmosToggle` (+ base `CosmosText`, `CosmosButton`, `CosmosCard`)
- [x] Wave B (wrap-view, no guard): `CosmosDivider`, `CosmosIcon`, `CosmosLink`
- [x] Wave C (style-protocol with guards): `CosmosGroupBox`, `CosmosMenu`, `CosmosDatePicker`
- [x] Wave D (opaque style / wrap-view with guards): `CosmosTextField` + `CosmosSecureField` + `CosmosTextEditor`, `CosmosSlider`, `CosmosStepper`
- [x] Wave E (wrap-view, style fragmentation): `CosmosSection`, `CosmosPicker`, `CosmosList`, `CosmosTabView`
- [x] **PHASE3 — Wave E refinements** (spec: `PHASE3.md`): `CosmosSlider` iOS 26 cluster (ticks / `neutralValue` / `enabledBounds` / current-value label); `.cosmosTabViewBottomAccessory(isEnabled:)` (iOS 26.1 — first shallow runtime `if #available` gate); `CosmosSelectableList` (optional-single universal primary + `Set` `#if !os(watchOS)`, one `Selection` generic, AnyView-in-init); **OS-27 surfaces** — `CosmosPickerStyle.tabs` (combined compile + runtime gate) + `CosmosTabRole` (`.prominent` runtime-gated resolver; first above-floor/Cosmos-27 surface)
- [x] Style-enum + pure availability-table + applier pattern for opaque styles (`PickerStyle`/`ListStyle`/`TabViewStyle`/`DatePickerStyle`), each case `#if os()`-guarded with `.automatic` fallback
- [x] Haptics via `.cosmosHaptic(_:trigger:)` gated by `CosmosHapticsPolicy` + reduce-motion
- [x] Tracking via `CosmosTrackingConfiguration.track(_:)` (passive, opt-in, no network/PII)
- [x] Localization via String Catalogs (`.xcstrings`), `LocalizedStringResource`, `CosmosLocalizedText`; baseline `en` + `pt-BR`

### Research vault
- [x] Obsidian knowledge vault at `vault/` (research → vault binding); root docs remain source of truth

### CI
- [x] GitHub CI (`.github/workflows/ci.yml`) — single-platform `macos-latest` `swift build` + `swift test`

### Verification
- [x] 5-platform build (iOS/macOS/tvOS/watchOS/visionOS) + `swift build -c release`, zero warnings
- [x] 198 Swift Testing tests passing

## Next

### PHASE4 — Core navigation & layout atoms

> Per-wave blueprints (`PHASE4.md` or per-wave docs) are deferred to each wave's implementation
> time and are NOT written now — at which point every `@available` clause is re-verified against the
> Xcode `.swiftinterface` (the #1 historical rework source). The waves below define scope, order,
> and the per-atom pattern tag only. Apply the PHASE2 §5 cross-cutting checklist per atom
> (accessibility, haptics, motion, tracking, enable, loading, localization, multiplatform guards).

**Design principles (standing rules for these waves):**

1. **Size-class-adaptive reflow preserves view identity.** Switch layout by
   `horizontalSizeClass` / `verticalSizeClass` / `dynamicTypeSize` via `AnyLayout` / `ViewThatFits`,
   NEVER via `if/else` that recreates view identity. Applies to Scroll / Form axis reflow.
2. **Stack ↔ SplitView is the documented exception.** `AnyLayout` cannot erase `NavigationStack`
   into `NavigationSplitView` (different root types; neither is a `Layout`). **Default:** a single
   `NavigationSplitView` root — it auto-collapses to stack-style push nav in compact width
   (identity-preserving; the system owns the reflow). **When an explicit compact `NavigationStack`
   is required** (different destinations, or a tvOS/watchOS shape where collapse is wrong): select
   one root per size class via the AnyView-in-init pattern and **persist logical nav state in shared
   bindings** (`path`, `columnVisibility`, `selectedRoute`). Honest tradeoff: physical view identity
   (focus, per-destination scroll offset, in-flight animation) does NOT survive the root switch;
   logical nav state (depth, selected route, column visibility) DOES. Coordinate the switch write
   with one `withAnimation(theme.motion.spring(for: .containerTransform).animation) { … }`.
3. **TabView ↔ Navigation contract.** Each `Tab` hosts one `CosmosNavigation`; nav state is
   tab-scoped. Do not double-adapt: inside a `.sidebarAdaptable` `CosmosTabView` tab, use the
   single-`NavigationSplitView`-root form and let the tab style own compact/regular chrome. No
   nav-side tab-switch haptic (the tab atom already fires `.selection`). Tracking anchor = per-tab
   `accessibilityIdentifier`.
4. **Custom-style atoms reuse the GroupBox-proven sub-pattern** (`CosmosGroupBoxChrome:
   GroupBoxStyle` in `Sources/Cosmos/Atoms/CosmosGroupBox.swift`): selector enum + pure availability
   table + applier + a `public struct: StyleProtocol` with `makeBody(configuration:)` using theme
   tokens and re-applying `applyCosmosAccessibility`. Applies to `FormStyle` / `ControlGroupStyle`.
   No new sub-pattern. (Difference from opaque styles: `PickerStyle` / `ListStyle` / `TabViewStyle`
   are non-conformable → selector-enum + applier only; `FormStyle` / `ControlGroupStyle` /
   `GroupBoxStyle` ARE conformable → custom `makeBody` is genuinely possible.)

**Waves (low-risk-first):**

- [x] **Wave F — `CosmosScrollView`** (`Sources/Cosmos/Atoms/CosmosScrollView.swift`) — wrap-View
      container atom (structural: no haptics/tracking/container-motion; no `ScrollViewStyle` so no
      theme selector). Programmatic scroll-to-top/bottom via native `ScrollViewReader` +
      `CosmosScrollAnchor` sentinels + `ScrollViewProxy` helpers + `.cosmosScrollAnchor(_:)`. Two
      platform-guarded pass-throughs — `cosmosScrollDismissesKeyboard` (visionOS-unavailable, whole
      wrapper gated `#if !os(visionOS)` — its `ScrollDismissesKeyboardMode` type is also
      visionOS-unavailable) and `cosmosScrollEdgeEffectStyle` (floor-exact 26, visionOS no-op). All
      scroll APIs verified floor (≤ .v26) against the Xcode 27 `.swiftinterface` — zero above-floor
      gates. AnyLayout reflow applies to content inside, not the scroll axis (switching the axis
      would destroy scroll identity).
- [x] **Wave G — `CosmosAsyncImage`** (`Sources/Cosmos/Atoms/CosmosAsyncImage.swift`) — wrap-View
      atom over `AsyncImage` with an explicit slot architecture (placeholder / error / retry),
      policy-gated phase-transition motion (`.cosmosTransition(.blurReplace)` + a motion-policy-gated
      `Transaction`), and an OS-27 cache/performance surface. No `CosmosAsyncImageStyle` selector
      (`AsyncImage` has no style protocol) → `CosmosTheme` untouched. Uses the floor phase-based
      `AsyncImage(url:scale:transaction:content:)`; `AsyncImagePhase` → Cosmos slots
      (`.empty`→placeholder, `.success`→content, `.failure`→failure; `@unknown default`→placeholder).
      The phase is authoritative for the slot; `configuration.loading.isLoading` is **not** consulted.
      Retry via `.id(retryToken)` (re-fetch on identity change); `.error` haptic on failure appear
      (via `failureToken`), the retry `CosmosButton` fires its own `.impact(.light)` (no double
      haptic); `configuration.error.report(_:code:)` + passive `track(.appear)` on failure. **OS-27
      cache surface:** `CosmosImageCache` (tuned `URLSession`+`URLCache`, `Sendable` namespace,
      once-token `static let defaultSession`) + `@Entry cosmosAsyncImageURLSession` +
      `View.cosmosAsyncImageURLSession(_:)` + `CosmosAsyncImageSessionApplier` (dual-gated
      `#if swift(>=6.4)` + `if #available(iOS 27, macOS 27, watchOS 27, tvOS 27, visionOS 27, *)`;
      `asyncImageURLSession` is `@available(anyAppleOS 27.0, *)` with no platform carve-out — OS-26 /
      Xcode 26 fall back to the system default). Pure `CosmosAsyncImageAvailability` table (true on
      all 5). The `configuration.loading.delay`/`minimumDisplayTime` placeholder-flicker gate is a
      documented **Wave-G refinement** (deferred — `AsyncImagePhase` has no `.loading` case, and no
      atom consumes those fields today). `CosmosMock.imageURL(seed:width:height:)` + `badImageURL()`
      added for previews + the future unified `CosmosImage`. All `@available` re-verified against the
      Xcode 27 Beta.3 `.swiftinterface`. Builds clean on all 5 platforms; 198 tests passing.
- [ ] **Wave H — `CosmosForm`** (`Sources/Cosmos/Atoms/CosmosForm.swift`) — custom-style
      (`CosmosFormStyle` / `CosmosFormChrome: FormStyle` `makeBody` with tokens + a11y re-apply) +
      wrap-View container; coherent loading / disabled / read-only via
      `CosmosEnableConfiguration` / `CosmosLoadingConfiguration`; composes with `CosmosSection`.
      Sibling `CosmosControlGroupStyle` / `CosmosControlGroupChrome` (style-only; no standalone
      `CosmosControlGroup` atom in PHASE4 — that wrapper stays PHASE5+).
- [ ] **Wave I — `CosmosNavigation`** (`Sources/Cosmos/Atoms/CosmosNavigation.swift`) — wrap-View +
      AnyView-in-init (Stack vs SplitView roots differ, cf. `CosmosTabView`); typed route +
      programmatic nav via `navigationDestination(for:)` + `path` binding; `columnVisibility`
      binding; size-class-adaptive root per principle 2; `CosmosTabView` composition per principle 3.

### Other next (unchanged)

- [ ] **Modifiers module** — consolidate typography / spacing / surface / motion modifiers into a coherent module surface
- [ ] **Molecules** — compositions of atoms (to be scoped; the pre-reset molecule list is not assumed)
- [ ] **Organisms** — higher-level compositions
- [ ] **Preview catalog app** — a standalone app surfacing every atom/molecule/organism with variant previews
- [ ] **Per-platform CI matrix** — extend CI to build iOS/macOS/tvOS/watchOS/visionOS + `swift build -c release` to exercise `#if os()` coverage
- [ ] **DocC generation** via `swift-docc-plugin` in CI

## Later (PHASE5+)

- [ ] Runtime theming engine (expand on `CosmosThemeObservable`)
- [ ] Accessibility audit tooling
- [ ] Component gallery website
- [ ] **Remaining missing atoms (future PHASE5+ — NOT in PHASE4 scope):**
  - Grids / Lazy (`LazyVStack` / `LazyHStack` / `LazyVGrid` / `LazyHGrid`)
  - `Table` (macOS / iOS) — `TableStyle` conformable
  - `OutlineGroup` / `DisclosureGroup` — `OutlineGroupStyle` / `DisclosureGroupStyle` where conformable
  - `ShareLink` / `ColorPicker`
  - `ControlGroup` as a standalone atom (the style ships in Wave H; the atom wrapper is deferred)
  - `Spacer` / `Badge`
  - Presentation (sheets / popovers / full-screen cover / alerts / confirmationDialog) — `presentationDetents` etc.
  - Drawing (`Canvas` / `Path` / `Shape` / `TimelineView`)
- [ ] **Deferred from Wave E** (recorded decisions, not lost work) — beyond what PHASE3 already covers:
  - Further OS-27 surface follow-ups as the floor lowers.

### Open risks / verification TODOs (PHASE4 — verified at blueprint time, NOT now)

- `NavigationSplitView` three-column + `columnVisibility` behavior on tvOS / watchOS at `.v26`; any
  above-floor new SplitView transition API.
- watchOS `Form` rendering under custom `CosmosFormChrome` (watchOS `Form` is `List`-like); built-in
  `FormStyle` cases available per platform.
- watchOS `ScrollView` surface: `ScrollViewReader`, `scrollPosition(id:)`,
  `onScrollGeometryChange` / `onScrollVisibilityChange` — which are OS-27 vs floor.
- ~~`AsyncImage` watchOS cache / phase limits at floor.~~ **Resolved (Wave G):** `AsyncImage` +
  `AsyncImagePhase` (`.empty`/`.success`/`.failure`, no `.loading` case, no `.content` accessor) are
  floor on all 5 platforms (iOS 15 / macOS 12 / tvOS 15 / watchOS 8). The OS-27 cache surface
  (`View.asyncImageURLSession(_:)`) is `@available(anyAppleOS 27.0, *)` — **no watchOS/tvOS/visionOS
  carve-out** (verified in the Xcode 27 Beta.3 `.swiftinterface`); dual-gated
  `#if swift(>=6.4)` + `if #available`, OS-26 falls back to the system default `URLSession`.
- `FormStyle` / `ControlGroupStyle` built-in case availability per platform
  (`.grouped` / `.insetGrouped` / `.columns` / …).
- OS-27 surfaces inside PHASE4 scope (scroll geometry / visibility APIs, new nav transitions) —
  flag any that need the runtime `if #available` gate (PHASE3 introduces the mechanic; PHASE4 may
  extend it).
- ~~Haptic kind for AsyncImage retry / error (confirm a `.error` / `.warning` kind exists or reuse).~~
  **Resolved (Wave G):** `CosmosHapticsFeedback.error` and `.warning` both exist
  (`CosmosHapticsConfiguration.swift`). Wave G fires `.error` **on failure appear** (via
  `failureToken`) — semantically correct (the error occurred); the retry tap is a `CosmosButton`
  that fires its own `.impact(.light)` (no double haptic).
- `@preconformance @MainActor` conformance for `FormStyle` / `ControlGroupStyle` under Swift 6 mode
  v6 (match the `CosmosGroupBoxChrome` precedent).