# Roadmap

> Last updated: 2026-07-17

## Now (current cycle)
- [x] Bootstrap SPM package `Cosmos` for Apple v26 platforms
- [x] Define `CosmosBase` target with shared configuration object
- [x] Implement base contracts: Accessibility, Localization, Log, Error, Loading, Enable
- [x] Adopt `@Entry` for `cosmosConfiguration` and `cosmosTheme`
- [x] Split behavior configuration from visual theme
- [x] Add semantic token layer: colors, typography, spacing, radii
- [x] Refactor existing atoms to consume the new base
- [x] Reduce atom APIs to content-only initializers
- [x] Add environment modifiers for state, accessibility, and theme overrides
- [x] Flatten atom folder structure into `Sources/Cosmos/Atoms/`
- [x] Build `CosmosScreen` data-driven renderer, action registry, and JSON loader
- [x] Add Swift Testing unit tests for base contracts, models, and JSON round-trips
- [x] Build + test passing on macOS, iOS, and tvOS via `swift build`/`swift test`
- [x] Wire localization into atoms so JSON keys resolve through configured bundle/locale
- [x] Fix empty accessibility label/hint overrides that silenced VoiceOver
- [x] Decouple `CosmosScreen` models from `Cosmos` target
- [x] Harden existing atoms (`CosmosText`, `CosmosButton`, `CosmosIcon`, `CosmosDivider`) with native controls
- [x] Add `CosmosControlSize` and loading placeholder support across atoms
- [x] Add `CosmosImage` atom supporting resource, SF Symbol, URL (URL and String), placeholder, and loading placeholders
- [x] Add `CosmosLabel` and `CosmosSpacer` atoms
- [x] Add `CosmosLink`, `CosmosTextField`, `CosmosToggle`, `CosmosProgress`, `CosmosSlider`, `CosmosPicker`, and `CosmosBadge` atoms
- [x] Add `CosmosStepper`, `CosmosDatePicker`, and `CosmosMenu` atoms
- [x] Add `CosmosSection`, `CosmosList`, and `CosmosTabView` container atoms
- [x] Implement adaptive `CosmosTabView` for compact/regular size classes
- [x] Wire all atoms into `CosmosScreen` JSON models and renderer
- [x] Add molecule: `CosmosInputRow` (label + text field)
- [x] Add molecule: `CosmosListRow` (icon + text + divider)
- [x] Add molecule: `CosmosFormRow` (label + control)
- [x] Add molecule: `CosmosEmptyState` (image + title + subtitle + button)
- [x] Add molecule: `CosmosButtonRow` (full-width icon + text button)
- [x] Add molecule: `CosmosSearchBar` (search icon + text field + clear button)

## Now (current cycle)
- [x] Add molecule: `CosmosStatusRow` (icon + text + badge)
- [x] Add molecule: `CosmosCard` (image + title + subtitle + badge/button)
- [x] Add molecule: `CosmosAlertBanner` (icon + text + action)
- [x] Add molecule: `CosmosLoadingState` (progress + text)

## Next
- [x] **Motion subsystem** — `CosmosMotionConfiguration` (9th cross-cutting contract) + `CosmosMotionTokens` (`CosmosSpring`/`CosmosDuration`/`CosmosTransition`/`CosmosContentTransitionPreset` + `CosmosMotionTokens.animation(for:)` resolver) + `CosmosMotionPolicy` + `.cosmosMotion`/`.cosmosMotionTokens`/`.cosmosSpringStyle`/`.cosmosAnimation`/`.cosmosTransition`/`.cosmosContentTransition`/`.cosmosStagger` modifiers; integrate into `CosmosButton`/`CosmosButtonChrome`/`CosmosText`/`CosmosCard` (replace hardcoded easing, route reduce-motion through the policy).
- [x] **Preview + mock-data infrastructure** — `CosmosPreviewRNG` (SplitMix64 seeded RNG) + `CosmosPreview` namespace (`CosmosPreviewVariant` + `CosmosPreviewContainer`) + `CosmosPreviewModifier` (`PreviewModifier` shared-context path) + `.cosmosPreviewEnv`/`.cosmosPreviewVariant` modifiers + `CosmosMock` deterministic generators (string/number/date/color/email/name/uuid/lorem/currency/percentage) + `CosmosMockWordlists`.
- [ ] Modifiers module: typography, spacing, surface, **motion**
- [ ] Organisms
- [ ] Preview catalog app
- [x] GitHub CI
- [ ] DocC generation via swift-docc-plugin in CI

## Later
- [ ] **Reconcile doc baseline** — `CHANGELOG.md`/`ARCHITECTURE.md` previously said "tvOS 27 / dropped watchOS+visionOS / Swift 6.2", contradicting `Package.swift` + `CLAUDE.md` (5 platforms at `.v26`, Swift 6.4). Reconciled 2026-07-17 — verify on each doc edit.
- [ ] **Per-platform CI matrix** — CI (`.github/workflows/ci.yml`) runs only a single `macos-latest` `swift build`+`swift test`; add a per-platform build matrix (iOS/macOS/tvOS/watchOS/visionOS) + `swift build -c release` to exercise `#if os()` coverage per CLAUDE.md (motion needs no `#if os()`, but the matrix should exist).
- [ ] Runtime theming engine
- [ ] Accessibility audit tooling
- [ ] Component gallery website
