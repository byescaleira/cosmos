---
tags: [adr, preview, meta]
aliases: [ADR Preview Mock Infra]
related: [[Arquitetura Cosmos]], [[Swift 6 Concurrency]]
---

# ADR — Preview/mock infra no alvo `Cosmos`, público, sem `#if DEBUG`, RNG seeded hand-rolled

> 2026-07-17 · Decided

**Contexto.** Apps consumidores reusariam `CosmosMock` nos próprios previews/tests; um alvo de preview separado forçaria uma segunda aresta product/dependency sem ganho (geradores mock são minúsculos, `Sendable`, no-UIKit, multiplatform). Regra zero-terceiros descarta SwiftFixtures/Genything/LoremSwiftify.

**Decisão.** `Sources/Cosmos/Base/Preview/` hospeda:
- `CosmosPreviewRNG` — SplitMix64, `RandomNumberGenerator & Sendable`.
- `CosmosPreview` — namespace + `CosmosPreviewVariant` + `CosmosPreviewContainer`.
- `CosmosPreviewModifier` — `PreviewModifier` (iOS 18+), path de shared-context (`makeSharedContext()` `@MainActor async throws`).
- `CosmosMock` + `CosmosMockWordlists` — geradores determinísticos (string/number/date/color/email/name/uuid/lorem/currency/percentage).

State RNG compartilhado via **`Mutex<CosmosPreviewRNG>`** (`import Synchronization`) — **nunca** `static var` mutável global cru (CLAUDE.md / [[ADR Swift 6 Concurrency]]).

**Sem modifiers de preview deprecados** (`.previewDevice`/`.previewLayout`/`.previewDisplayName`/`.previewInterfaceOrientation`/`.previewContext` deprecados em OS 27). Usar `#Preview(_:traits:)` + `.cosmosPreviewEnv`/`.cosmosPreviewVariant`. Accessibility env keys injetadas via **SPI underscore** (`._accessibilityReduceMotion` etc.) — get-only public, estáveis, usadas pelo tooling da Apple.

> Mock data determinístico documentado em [[Arquitetura Cosmos]]; padrão RNG em [[Swift 6 Concurrency]].