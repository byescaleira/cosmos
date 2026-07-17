---
tags: [adr, concorrencia]
aliases: [ADR Observable MainActor Theme, Runtime Theme]
related: [[ADR Global State Entry]], [[Swift 6 Concurrency]]
---

# ADR — Runtime theme via `@Observable @MainActor`

> 2026-07-16 · Decided

**Contexto.** Live theme switching precisa de estado mutável; struct `Sendable` imutável é o path primário (testável off-main), mas não cobre troca em runtime.

**Decisão.** Theming mutável em runtime via `CosmosThemeObservable` (`@Observable @MainActor`), que wrapa um `CosmosTheme`. Injetado de forma que o acesso fique main-actor-isolated.

**Por que não `@Observable` no struct base.** Value types `Sendable` + substituição via env é o path primário (evita fricção `@Observable` + `@MainActor`, mantém testabilidade off-main). O observable é a **exceção** para live-switch, não o default.