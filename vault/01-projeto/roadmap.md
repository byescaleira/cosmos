---
tags: [projeto, roadmap]
related: [[Home]], [[Changelog Resumo]]
---

# Roadmap

> Fonte: `ROADMAP.md` (last updated 2026-07-17)

## Now (entregue)

- Bootstrap SPM `Cosmos` para Apple v26.
- `CosmosBase` + contratos base (Accessibility, Localization, Log, Error, Loading, Enable) + `@Entry` para `cosmosConfiguration`/`cosmosTheme`.
- Split behavior (config) vs visual (theme); camada de tokens semânticos (colors, typography, spacing, radii).
- Refatorar átomos para consumir a base; inits content-only; modifiers de env para state/a11y/theme.
- Pasta de atoms flat em `Sources/Cosmos/Atoms/`.
- `CosmosScreen` (renderer + action registry + JSON loader) + round-trip tests.
- Build + test passando em macOS/iOS/tvOS; localization wired nos atoms.
- Harden atoms (`CosmosText`, `CosmosButton`, `CosmosIcon`, `CosmosDivider`).
- `CosmosControlSize` + loading placeholder.
- `CosmosImage` (resource / SF Symbol / URL / String / placeholder).
- `CosmosLabel`, `CosmosSpacer`, `CosmosLink`, `CosmosTextField`, `CosmosToggle`, `CosmosProgress`, `CosmosSlider`, `CosmosPicker`, `CosmosBadge`.
- `CosmosStepper`, `CosmosDatePicker`, `CosmosMenu`.
- `CosmosSection`, `CosmosList`, `CosmosTabView` (adaptativo compact/regular).
- Atoms wired no `CosmosScreen`.
- Moléculas: `CosmosInputRow`, `CosmosListRow`, `CosmosFormRow`, `CosmosEmptyState`, `CosmosButtonRow`, `CosmosSearchBar`, `CosmosStatusRow`, `CosmosCard`, `CosmosAlertBanner`, `CosmosLoadingState`.
- **Motion subsystem** + **preview/mock infra** (ver [[Motion Subsystem]], [[ADR Preview Mock Infra]]).
- GitHub CI.

## Next

- [ ] Modifiers module: typography, spacing, surface, motion.
- [ ] Organisms.
- [ ] Preview catalog app.
- [ ] DocC via swift-docc-plugin em CI.

## Later

- [ ] **Reconcile doc baseline** — docs já reconciliados em 2026-07-17 (5 plataformas `.v26`, Swift 6.4); verificar a cada edição de doc.
- [ ] **Per-platform CI matrix** — CI hoje roda só `macos-latest` `swift build`+`swift test`; adicionar matrix iOS/macOS/tvOS/watchOS/visionOS + `swift build -c release` para exercitar `#if os()` (ver [[Plataforma Guards]]).
- [ ] Runtime theming engine.
- [ ] Accessibility audit tooling.
- [ ] Component gallery website.

> **Ondas de atoms** (Wave A→E) — ver [[Átomos Overview]]. Waves A, B, C, D entregues; Wave E (Section/Picker/List/TabView) pendente.