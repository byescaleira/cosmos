---
tags: [adr, cross-cutting]
aliases: [ADR Global State Entry, Estado Global]
related: [[Arquitetura Cosmos]], [[Contratos Cross-cutting]]
---

# ADR — Estado & theme globais via `@Entry`

> 2026-07-16 · Decided

**Contexto.** Usuário: *"um componente deve ter seu state, seu theme … tudo global"*. Concerns cross-cutting fluem pelo SwiftUI environment, não por structs per-component.

**Decisão.** Componentes **não** donam structs de state/theme per-component. Tudo via `@Entry`:
- `cosmosConfiguration: CosmosConfiguration` — behavior/state (enable, loading, accessibility, haptics, **motion**, tracking, localization, log, error).
- `cosmosTheme: CosmosTheme` — visual tokens (colors, typography, padding, textStyle, buttonStyle, controlSize, **motion**, version).
- `cosmosTrackingId: String?` — fallback de analytics id (default `accessibilityIdentifier`).

Cada átomo lê explicitamente seu subconjunto relevante. Overrides per-instância via modifiers `.cosmos*` que leem o env, mutam cópia via `.with*`, e re-injetam. Theming runtime mutável via [[ADR Observable MainActor Theme]].

**Consequências.** Sem structs per-component; superfície uniforme; testabilidade off-main. Modifiers focados implementados como `ViewModifier` que leem valor atual, mutam cópia, re-injetam com `.environment(_:_:)`.

**Por que split behavior↔visual** — misturar `isEnabled`/`isLoading` com color tokens confundia concerns (ADR separada).