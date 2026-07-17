---
tags: [moc, index]
aliases: [Cosmos vault, knowledge vault]
related: []
---

# Cosmos — Knowledge Vault

Synthesis/navigation layer for the [[Cosmos]] SwiftUI design-system library. The **source of truth stays the root docs** (`PHASE2.md`, `DECISIONS.md`, `ARCHITECTURE.md`, `VERSIONING.md`, `CLAUDE.md`); this vault is a synthesis layer. On conflict, the root doc wins — update the note.

## Folders

- `02-decisoes/` — new ADRs / decisions
- `03-componentes/` — atoms (per-component notes: API surface, platform availability, customization limits)
- `06-concorrencia/` — design-system comparison + Swift concurrency
- `07-metodologia/` — workflows / methods
- `08-riscos/` — open risks / refuted specs

## Methodology index

- [[phase4-core-navigation-atoms]] — PHASE4 roadmap restructure: core navigation/layout atoms (Scroll / AsyncImage / Form / Navigation), standing design principles (AnyLayout reflow, Stack↔SplitView identity crux, TabView↔Navigation contract, GroupBox-proven custom-style sub-pattern), waves F–I.
- [[above-floor-gating-pattern]] — PHASE3: the three above-floor (Cosmos-27) gate shapes (shallow runtime / combined compile+runtime / resolver), pure-table-vs-runtime separation, and the recorded `TabRole`-has-no-modifier deviation. Template for future OS-27 surfaces.

## Component index

- [[cosmos-section]] — `CosmosSection` (Wave E): `Section` wrap-view, container-modifier platform matrix.
- [[cosmos-picker]] — `CosmosPicker` (Wave E): `Picker` wrap-view, `PickerStyle` × platform matrix (9 styles incl. `.tabs` OS-27 combined gate), `Sendable` selection + `Label`-shadowing gotcha.
- [[cosmos-list]] — `CosmosList` (Wave E): `List` wrap-view, `ListStyle` × platform matrix (9 styles), no-selection primary, `#Preview`-struct-declaration gotcha.
- [[cosmos-selectable-list]] — `CosmosSelectableList` (PHASE3): selectable `List` wrap-view; one `Selection` generic unifies optional-single (all 5) + `Set` (`#if !os(watchOS)`); AnyView-in-init; `AnyHashable`-not-`Sendable` gotcha.
- [[cosmos-tabview]] — `CosmosTabView` (Wave E): `TabView` wrap-view, `TabViewStyle` × platform matrix (6 styles), modern `TabContentBuilder` inits only, AnyView-in-init for selectable/non-selectable unification; `CosmosTabRole` (`.prominent` OS-27 resolver) + `bottomAccessory(isEnabled:)` iOS-26.1 gate added in PHASE3.

## Risks index

- [[header-prominence-not-a-real-api]] — PHASE2 §2.13 lists `.headerProminence(_:)`; it does **not** exist in the Xcode 27 SwiftUI SDK (refuted spec).