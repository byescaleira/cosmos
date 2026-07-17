---
tags: [adr, concorrencia, cross-cutting]
aliases: [ADR Swift 6 Concurrency, Concorrência Swift 6]
related: [[Swift 6 Concurrency]], [[ADR Global State Entry]]
---

# ADR — Concorrência Swift 6, zero warnings

> 2026-07-16 · Decided

**Contexto.** Usuário: *"não vem com nslock … tudo conforme a nova concorrência, sem warnings."* Swift 6.4 / language mode v6 / Xcode 26.

**Decisão.** Build com **zero concurrency warnings** em Swift 6 mode. Fix isolation/Sendable; não silenciar.
- Tipos públicos de valor são `Sendable` (conformance derivada; evitar `@unchecked`).
- Handler closures em configurations são `@Sendable`.
- **Sem `NSLock`, sem `DispatchQueue` para sync, sem `nonisolated(unsafe)` mutable globals.**
- Trabalho one-shot idempotente (ex.: registro de fontes): **once-token pattern** — `static let` cujo initializer side-effect roda uma vez, thread-safe, via `swift_once`. Sem primitivo de lock.
- Flag mutável genuinamente inevitável: `Mutex<T>` / `Atomic<T>` de `import Synchronization` (Swift 6.0+). Nunca locks crus.
- Runtime theme: `@Observable @MainActor` ([[ADR Observable MainActor Theme]]).
- `@Entry` env values devem ser `Sendable`.

> Detalhes e padrões práticos → [[Swift 6 Concurrency]].