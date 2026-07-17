---
tags: [adr, motion]
aliases: [ADR Spring Presets]
related: [[ADR Motion 9th Contract]], [[Spring Presets]]
---

# ADR — Spring presets espelham SwiftUI built-ins + 2 extensões Cosmos

> 2026-07-17 · Decided

**Contexto.** Polaris removeu overshoot/anticipate para uso minimalista em produção — over-shippar presets é anti-pattern. Apple HIG avisa contra motion gratuito.

**Decisão.** 5 presets `CosmosSpring`:
- `.cosmosSmooth` / `.cosmosSnappy` / `.cosmosBouncy` — espelham `.smooth`/`.snappy`/`.bouncy` do SwiftUI.
- `.cosmosGentle` — large/visionOS-safe relocations, sem overshoot.
- `.cosmosInteractive` — preservação de velocity de gesto.

`CosmosSpringStyle` selector + SE-0299 dot-syntax (paralelo a `CosmosButtonStyle`).

**Escala `CosmosDuration` de 6 tiers** (Carbon-hybrid): instant / 70 / 110 / 150 / 240 / 400 / 700 ms.

> Presets em detalhe → [[Spring Presets]].