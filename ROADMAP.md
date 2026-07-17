# Roadmap

> Last updated: 2026-07-17
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
- [x] 178 Swift Testing tests passing

## Next

- [ ] **Modifiers module** — consolidate typography / spacing / surface / motion modifiers into a coherent module surface
- [ ] **Molecules** — compositions of atoms (to be scoped; the pre-reset molecule list is not assumed)
- [ ] **Organisms** — higher-level compositions
- [ ] **Preview catalog app** — a standalone app surfacing every atom/molecule/organism with variant previews
- [ ] **Per-platform CI matrix** — extend CI to build iOS/macOS/tvOS/watchOS/visionOS + `swift build -c release` to exercise `#if os()` coverage
- [ ] **DocC generation** via `swift-docc-plugin` in CI

## Later

- [ ] Runtime theming engine (expand on `CosmosThemeObservable`)
- [ ] Accessibility audit tooling
- [ ] Component gallery website
- [ ] **Deferred from Wave E** (recorded decisions, not lost work):
  - `CosmosSelectableList` — selectable `List` variant (selection inits fragment too far across platforms for one clean API)
  - OS-27 surfaces (above the Cosmos 26 floor): `TabRole.prominent`, `TabsPickerStyle` (`.tabs`)
  - iOS 26 `Slider` cluster (ticks / `neutralValue` / `enabledBounds` / current-value label)
  - `.cosmosTabViewBottomAccessory(isEnabled:)` (iOS 26.1, above floor)