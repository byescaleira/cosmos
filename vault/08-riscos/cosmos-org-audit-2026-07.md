---
tags: [audit, organization, tech-debt, cosmos]
aliases: [Cosmos organization audit, Cosmos tech-debt inventory 2026-07]
related: [[phase4-core-navigation-atoms]], [[above-floor-gating-pattern]], [[cosmos-toast]]
---

# Cosmos — Organization Audit (2026-07)

Deep audit of the Cosmos source tree organization. Synthesis of 5 parallel dimensions
(structure, cross-cutting architecture, atom API consistency, duplication/dead-code, tests/docs).
**Source of truth stays the root docs** — this note is a synthesis/navigation layer.

> Verdict: the load-bearing spine (9 contracts + theme + motion split + Sendable + zero-UIKit +
> `@Entry`) is **clean** and matches `CLAUDE.md`. The "mixed up" feeling is real but comes from
> 3 structural sources + 1 interrupted refactor + stale docs — not from bad architecture.

## Root causes of the "mixed up" feeling

1. **One concept split across folders with no rule.** "Chrome" lives in `Base/Theme/`
   (`CosmosButtonChrome`) **and** inside atom files (`CosmosGroupBoxChrome`/`LabelChrome`/
   `ToggleChrome`/`ProgressChrome`). `*Style` enums live in `Base/Theme/` but their `*StyleApplier`
   `ViewModifier`s live in `Atoms/`. Accessibility is fragmented across 4 folders
   (`_CosmosAccessibilityApplicator` orphaned in `Atoms/`, helpers in `Environment/`, modifiers in
   `Modifiers/`, config in `Configuration/`). You can predict where a *file name* lives, not where
   a *kind of thing* lives.
2. **Atomic-design hierarchy advertised but not honored.** `Molecules/`, `Organisms/`, `Screen/`
   exist but are **empty**; `Atoms/` holds non-atoms (`CosmosTabRole` enum, `CosmosLocalizedText`
   buried in `CosmosLabel.swift`, `CosmosAdaptiveStack` a `View` in `Modifiers/`,
   `CosmosResources` in `Environment/`). `ARCHITECTURE.md` still describes the discarded pre-reset
   plan (molecules / `CosmosScreen` / `CosmosImage` / `CosmosBadge` / `CosmosSpacer` / JSON loader).
3. **Three competing test-suite axes, no rule.** Feature suites (Tokens/Theme/Motion/…),
   chronological Wave suites (A–G), and a spec-milestone suite (Wave E Refinements/PHASE3) coexist
   flat. Redundancy: `CosmosMotionPolicy` / `CosmosHapticsPolicy` / fluent-builders / `allCases`
   tested in **both** axes. Holes: ~13 atoms have **no behavior test** (only their selector enums)
   — `CosmosCard`, `CosmosButton`, `CosmosText`, `CosmosSection`, `CosmosDivider`, `CosmosIcon`,
   `CosmosLink`, `CosmosScrollView`, `CosmosAsyncImage`, and the Views of
   TextField/SecureField/TextEditor/Menu/GroupBox/DatePicker/Toggle/Label/Progress. `CosmosToastTests`
   labels itself "Wave H" but `ROADMAP.md` reserves Wave H for `CosmosForm`.

## Findings ranked by severity

### P0 — broken contract / actively misleading

- **`.cosmosTextEditorStyle(_:)` is a silent no-op.** Applier was deleted from `CosmosTextEditor`
  but the modifier + `CosmosTextEditorStyle` enum + `CosmosTextEditorAvailability` remain public;
  doc comment (`CosmosTextEditor.swift:3-4,7-8,12,18-22,26`) still claims it applies style/tint/
  typography. Violates `VERSIONING.md` deprecation-runway. Fix: restore applier **or** deprecate
  the whole surface with `@available(*,deprecated)` (don't delete silently).
- **Interrupted de-styling refactor, no policy.** 3 atoms de-styled (`CosmosText`,
  `CosmosTextField`, `CosmosTextEditor`) vs 14 still imposing theme defaults (`CosmosButton`/
  `Label`/`Icon`/`Link`/`GroupBox`/`Menu`/`Stepper`/`SecureField`/`Toggle`/`Progress`/`Slider`/
  `Card`/`ToastContent`/`ButtonChrome`). No ADR. Concrete fallout:
  - `CosmosSecureField` still imposes `.tint/.font/.foregroundStyle` + `.submitLabel(.done)`
    (`:47-53`); `CosmosTextField` (same family) imposes none — divergence with no justification.
  - `CosmosText` had `.cosmosAnimation`/`.cosmosContentTransition` removed but `onAppear` still
    fires `motion.handler(.valueChange)` (`:62-68`) — vestigial motion event with no animated value.
- **`ARCHITECTURE.md` substantially stale.** Describes discarded molecules/`CosmosScreen`/
  `CosmosImage`/`CosmosBadge`/`CosmosSpacer`, a non-existent `CosmosBase` module, non-existent
  selectors `CosmosIconScale`/`CosmosDividerStyle`, and a non-existent "catalog app `CosmosPreview`"
  target. `ROADMAP.md:5-7` confirms the discard; ARCHITECTURE was never synced. See
  [[phase4-core-navigation-atoms]] for the current direction.

### P1 — structural organizational debt

- **`controlSize` honored on 5 controls, ignored on 3.** `Button`/`Toggle`/`Slider`/`Stepper`/
  `Menu` apply `.controlSize(theme.controlSize.controlSize)`; `Picker`/`DatePicker`/`TabView` do
  **not** → `.cosmosControlSize(.small)` silently ignored there.
- **Dead/under-used config.** `CosmosMotionConfiguration.reduceTransparencyPolicy` (`:71`) declared,
  defaulted `.substitute`, read **nowhere** (only the Bool `respectReduceTransparency` is used) —
  unfinished sibling of `reduceMotionPolicy`. `motion.stagger` + `cosmosStagger(_:)`
  (`CosmosMotionHelpers.swift:141`) have no internal consumer. Accessibility gates
  `colorSchemeContrast`/`differentiateWithoutColor`/`showButtonShapes` documented in `CLAUDE.md`
  but read by no atom and absent from `CosmosAccessibilityConfiguration`. 4th `@Entry`
  `cosmosAsyncImageURLSession` (`CosmosAsyncImage.swift:247`) outside the documented 3-value env
  model (Sendable-safe but unmodeled).
- **Stale docs beyond ARCHITECTURE.** `DECISIONS.md` (says 8 contracts, is 9; says bundled fonts
  via CoreText, ships none). `CONTRIBUTING.md` (cites non-existent `CosmosStyles`/`CosmosModifiers`/
  catalog target). `README` atom table (omits `CosmosAsyncImage` + `CosmosScrollView`;
  `CosmosDivider` misdescribed as "theme-tinted" — the atom explicitly does not recolor).
- **In-source comments now false.** `CosmosText.swift:3-4` ("token-driven typography/color") and
  `CosmosTextEditor.swift:3-4,7-8,12,18-22,26` (style/tint/typography/applier) describe behavior
  that was just removed.

### P2 — boilerplate (cosmetic)

- **18 identical "read-mutate-reinject" `ViewModifier`s** in `CosmosThemeModifiers.swift:7-187`
  → collapsible to one generic `(inout CosmosTheme)->Void` (~140→~40 lines). Keep the 3
  multi-field ones (`Font`/`CustomFontName`/`ColorToken`) explicit.
- **7 copy-paste availability+applier pairs** (List/Picker/TabView/DatePicker/GroupBox/Menu/
  Label-Progress-Toggle). The applier is a mechanical projection of the availability matrix into
  `#if os()` — generalizable for the ~7 pure-`#if os()` cases (the 2 hybrids `.tabs`/`.bordered`
  stay bespoke). ~150 lines saved, partly cosmetic.
- **`.tint/.controlSize/.font` triplet** repeated across Menu/Toggle/Stepper/Slider/Button →
  candidate `.cosmosControlChrome()` helper.
- **Misplaced files.** `CosmosAdaptiveStack` (View) in `Modifiers/`; `CosmosResources` in
  `Environment/`; `CosmosTabRole` (enum) in `Atoms/`; `CosmosLocalizedText` buried in
  `CosmosLabel.swift`; `_CosmosAccessibilityApplicator` orphaned in `Atoms/`.

## What is clean (do not touch)

- Concurrency: zero `@unchecked Sendable` / `nonisolated(unsafe)` / `NSLock` / `DispatchQueue` /
  `import UIKit`; only shared mutable state is `Mutex<CosmosPreviewRNG>` (sanctioned); all `@Entry`
  Sendable; no per-component state/theme structs.
- Motion behavior-vs-tokens split: clean (except the dead `reduceTransparencyPolicy`);
  `CosmosMotionPolicy.shouldEmit` chokepoint used by every motion atom.
- `#if os()` platform gating: the **most consistent** part of the atom layer — every guard
  documents the SDK `@available` it mirrors.
- Deprecation pattern `.cosmosTextStyle`/`.cosmosCustomFont` → `.cosmosFont`: correct — the model
  the TextEditor removal should have followed.
- Accessibility applicator + preview infra already centralized (`applyCosmosAccessibility`,
  `CosmosPreviewContainer`/`Variant`/`Env`/`Modifier`) — no real duplication there.

## Recommended cleanup sequence

1. **Decide the de-styling policy** (P0): either "atoms impose theme defaults" (revert the 3) or
   "atoms are pass-through, callers own styling" (apply to the 14 + deprecate the TextEditor style
   surface). Record as an ADR in `DECISIONS.md` + a [[02-decisoes]] note. Without this, any reorg
   is sand.
2. **Resolve the TextEditor no-op** + `CosmosText` vestigial motion + SecureField↔TextField
   divergence (follows from #1).
3. **Sync stale docs**: `ARCHITECTURE.md` (or retire it), `DECISIONS.md` 8→9 + fonts,
   `CONTRIBUTING.md`, README atom table + `CosmosDivider`, the false in-source comments.
4. **Structural reorg** (P1, after policy): give Chrome/applier/accessibility a single home;
   delete or fill empty `Molecules/Organisms/Screen`; move misplaced files.
5. **Tests** (P1): pick ONE axis (recommend feature suites; archive/migrate the Wave suites);
   prioritize behavior tests for the uncovered atoms (start with `CosmosButton`/`CosmosCard`/
   `CosmosText`).
6. **Boilerplate** (P2, last): collapse the 18 modifiers; generalize appliers; `cosmosControlChrome`.
7. **Dead config**: wire or remove `reduceTransparencyPolicy` / `stagger`; decide the unwired
   accessibility gates (wire, or drop from `CLAUDE.md`).