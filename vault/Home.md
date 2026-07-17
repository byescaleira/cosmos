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

## Component index

- [[cosmos-section]] — `CosmosSection` (Wave E): `Section` wrap-view, container-modifier platform matrix.
- [[cosmos-picker]] — `CosmosPicker` (Wave E): `Picker` wrap-view, `PickerStyle` × platform matrix, `Sendable` selection + `Label`-shadowing gotcha.
- [[cosmos-list]] — `CosmosList` (Wave E): `List` wrap-view, `ListStyle` × platform matrix (9 styles), no-selection primary (selectable variant deferred), `#Preview`-struct-declaration gotcha.
- [[cosmos-tabview]] — `CosmosTabView` (Wave E): `TabView` wrap-view, `TabViewStyle` × platform matrix (6 styles), modern `TabContentBuilder` inits only, AnyView-in-init for selectable/non-selectable unification, `TabRole.prominent` OS-27-omitted.

## Risks index

- [[header-prominence-not-a-real-api]] — PHASE2 §2.13 lists `.headerProminence(_:)`; it does **not** exist in the Xcode 27 SwiftUI SDK (refuted spec).