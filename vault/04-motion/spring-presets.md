---
tags: [motion]
aliases: [Spring Presets, CosmosSpring, CosmosDuration]
related: [[ADR Spring Presets]], [[Motion Subsystem]]
---

# Spring Presets & Duration Scale

> Polaris removeu overshoot/anticipate p/ uso minimalista em produção — over-shippar presets é anti-pattern. Apple HIG avisa contra motion gratuito. → [[Design Systems Comparison]]

## 5 presets `CosmosSpring`

| Preset | Espelha / uso |
|---|---|
| `.cosmosSmooth` | SwiftUI `.smooth` |
| `.cosmosSnappy` | SwiftUI `.snappy` |
| `.cosmosBouncy` | SwiftUI `.bouncy` |
| `.cosmosGentle` | Large / visionOS-safe relocations, **sem overshoot** |
| `.cosmosInteractive` | Preservação de **velocity** de gesto |

`CosmosSpringStyle` selector + SE-0299 dot-syntax (paralelo a `CosmosButtonStyle` — `where Self ==`).

## Escala `CosmosDuration` (Carbon-hybrid, 6 tiers)

| Tier | ms |
|---|---|
| instant | 0 |
| 1 | 70 |
| 2 | 110 |
| 3 | 150 |
| 4 | 240 |
| 5 | 400 |
| 6 | 700 |

## Uso

Resolver único: `CosmosMotionTokens.animation(for: <CosmosMotionKind>, reduceMotion: <Bool>, policy: <CosmosReduceMotionPolicy>)` → `Animation`. Atoms só passam o `kind` + `value` no chokepoint (`.cosmosAnimation(.valueChange, value:)`); o resolver picka o spring/duration certos e a variante reduce-motion.