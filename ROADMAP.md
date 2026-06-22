# Roadmap

> Last updated: 2026-06-22

## Now (current cycle)
- [x] Bootstrap SPM package `Cosmos` for Apple v26 platforms
- [x] Define `CosmosBase` target with shared configuration object
- [x] Implement base contracts: Accessibility, Localization, Log, Error, Loading, Enable, Redaction
- [x] Adopt `@Entry` for `cosmosConfiguration` and `cosmosTheme`
- [x] Split behavior configuration from visual theme
- [x] Add semantic token layer: colors, typography, spacing, radii
- [x] Refactor existing atoms to consume the new base
- [x] Reduce atom APIs to content-only initializers
- [x] Add environment modifiers for state, accessibility, and theme overrides
- [x] Flatten atom folder structure into `Sources/Cosmos/Atoms/`
- [x] Build `CosmosScreen` data-driven renderer, action registry, and JSON loader
- [x] Add ViewInspector structural tests for atoms, renderer, and JSON loader
- [x] Add SnapshotTesting visual regression tests on iOS
- [x] Build + test passing on macOS and iOS simulator
- [x] Wire localization into atoms so JSON keys resolve through configured bundle/locale
- [x] Fix empty accessibility label/hint overrides that silenced VoiceOver
- [x] Decouple `CosmosScreen` models from `Cosmos` target
- [x] Exclude snapshot baselines from SwiftPM test target
- [x] Harden existing atoms (`CosmosText`, `CosmosButton`, `CosmosIcon`, `CosmosDivider`) with native controls
- [x] Add `CosmosControlSize` and redaction support across atoms
- [x] Add `CosmosImage` atom supporting resource, SF Symbol, URL (URL and String), placeholder, and loading redaction
- [x] Add `CosmosLabel` and `CosmosSpacer` atoms
- [x] Add `CosmosLink`, `CosmosTextField`, `CosmosToggle`, `CosmosProgress`, `CosmosSlider`, `CosmosPicker`, and `CosmosBadge` atoms
- [x] Add `CosmosStepper`, `CosmosDatePicker`, and `CosmosMenu` atoms
- [x] Add `CosmosSection`, `CosmosList`, and `CosmosTabView` container atoms
- [x] Implement adaptive `CosmosTabView` for compact/regular size classes
- [x] Wire all atoms into `CosmosScreen` JSON models and renderer
- [x] Add ViewInspector tests for all atoms

## Next
- [ ] Create `/byescaleira` Claude Code plugin with project context
- [ ] Add molecule: `CosmosInputRow` (label + text field)
- [ ] Add molecule: `CosmosListRow` (icon + text + divider)

## Later
- [ ] Modifiers module: typography, spacing, surface
- [ ] Organisms
- [ ] Preview catalog app
- [ ] GitHub CI

## Future
- [ ] Runtime theming engine
- [ ] Accessibility audit tooling
- [ ] Component gallery website
