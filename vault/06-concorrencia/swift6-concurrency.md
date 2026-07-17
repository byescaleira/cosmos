---
tags: [concorrencia, cross-cutting]
aliases: [Swift 6 Concurrency, Concorrência Swift 6]
related: [[ADR Swift 6 Concurrency]], [[ADR Observable MainActor Theme]], [[ADR Preview Mock Infra]]
---

# Concorrência Swift 6 (zero warnings)

> "Concorrência" no sentido de concurrency. Build com **zero concurrency warnings** em Swift 6 mode (6.4 / mode v6 / Xcode 26). Fix isolation/Sendable; não silenciar. → [[ADR Swift 6 Concurrency]].

## Regras estruturais

- Tipos públicos de valor são `Sendable` (conformance derivada; evitar `@unchecked`).
- Handler closures em configurations são `@Sendable`.
- `@Entry` env values devem ser `Sendable`.

## Proibidos

- **Sem `NSLock`.**
- **Sem `DispatchQueue` para sincronização.**
- **Sem `nonisolated(unsafe)` mutable globals.**

## Padrões permitidos

### Once-token (trabalho one-shot idempotente)
Um `static let` cujo initializer side-effect roda exatamente uma vez, thread-safe, via `swift_once`. Sem primitivo de lock. Uso: registro de fontes (`CosmosFont.registerAllFonts()`).

### Flag mutável genuinamente inevitável
`Mutex<T>` / `Atomic<T>` de `import Synchronization` (Swift 6.0+). Nunca locks crus.
- **Mock RNG state compartilhado** → `Mutex<CosmosPreviewRNG>` ([[ADR Preview Mock Infra]]) — nunca `static var` mutável global cru.

### Runtime theme mutável
`@Observable @MainActor` (`CosmosThemeObservable`) — injetado de forma que o acesso fique main-actor-isolated ([[ADR Observable MainActor Theme]]).

## Concurrency warnings comuns e como evitar

| Sintoma | Fix |
|---|---|
| `@MainActor @preconcurrency` em style protocols (`LabelStyle`, `ToggleStyle`, `GroupBoxStyle`, `MenuStyle`, `TabContent`) | Manter struct custom `Sendable`/`~Swift.Sendable`; marcar conformance `@preconcurrency` se preciso; `makeBody` MainActor-isolated |
| Captura de state non-Sendable em closure | Não capturar; passar só dados `Sendable`; closures `@Sendable` |
| `Progress` `@MainActor`-bound | Instâncias do call site MainActor-isolated ou value-backed |
| Mutable global shared | Substituir por `Mutex<T>`/`Atomic<T>` |

> Truth-tables de policy (`CosmosMotionPolicy`/`CosmosHapticsPolicy.shouldEmit`) são testadas como lógica pura em `CosmosMotionTests`/`CosmosMockTests` — sem render de view tree.