---
tags: [motion, cross-cutting]
aliases: [Motion Subsystem, Subsistema de Motion]
related: [[ADR Motion 9th Contract]], [[Motion Intent Matrix]], [[Reduce Motion Policy]], [[Spring Presets]]
---

# Motion Subsystem

> Motion é tokenizado e cross-cutting — ver [[ADR Motion 9th Contract]].

## Split (espelha o resto do sistema)

| Camada | Onde | Conteúdo |
|---|---|---|
| **Behavior/policy** | `cosmosConfiguration.motion` = `CosmosMotionConfiguration` | `isEnabled`, `respectReduceMotion`, `reduceMotionPolicy`, `respectReduceTransparency`, `stagger`, `handler @Sendable` |
| **Visual tokens** | `cosmosTheme.motion` = `CosmosMotionTokens` | `CosmosSpring` presets, `CosmosDuration` scale, `CosmosTransition`/`CosmosContentTransitionPreset`, resolver `animation(for:reduceMotion:policy:)` |

## Chokepoints (átomos NUNCA escrevem motion cru)

Átomos chamam:
- `.cosmosAnimation(_ kind:, value:)` — ex.: `.cosmosAnimation(.press, value: isPressed)`
- `.cosmosTransition(_:)` — ex.: `.cosmosTransition(.sheet)`
- `.cosmosContentTransition(_:)` — ex.: `.cosmosContentTransition(.numericText())`
- `.cosmosStagger(...)`

Esses resolvem tokens via `CosmosMotionTokens.animation(for:)` (**single source of truth**) e gateiam reduce-motion via `CosmosMotionPolicy` (config-aware, **não** o valor cru do env). Nunca `Animation.spring(...)`/`.transition(.move...)` direto.

## Gating

`CosmosMotionPolicy.shouldEmit(isEnabled:respectReduceMotion:reduceMotion:)` — espelha `CosmosHapticsPolicy`. Permite `configuration.motion.respectReduceMotion = false` override intencional.

**Symbol effects** (`.symbolEffect`) já auto-respeitam Reduce Motion — gate em `isEnabled` **only**; **não** double-gate em `respectReduceMotion`.

## Coordenacao

- **Single** `withAnimation(theme.motion.spring(for: .containerTransform).animation) { … }` por mudança de estado coordenada.
- Evitar per-view `.animation(_:value:)` com curvas diferentes (desyncs).
- `matchedGeometryEffect`: single `@Namespace`, single `isSource: true`, driven por um `withAnimation`.

## Sem `if #available`

No baseline Cosmos 26, **nenhum** primitive de motion precisa de gate: Spring, PhaseAnimator, KeyframeAnimator, BlurReplaceTransition (via `.transition<T>(:)` genérico — não é `AnyTransition`-composable), symbolEffect, withAnimation(completion), transition<T>, matchedGeometryEffect são todos iOS 17/18 ≤ 26 nas 5 plataformas. `GlassEffectTransition.matchedGeometry` (iOS 26) só precisaria de gate se o floor baixar.

## Vocabulário de intents

`press`, `appear`, `disappear`, `valueChange`, `tabSwitch`, `sheet`, `focus`, `containerTransform`, `listInsert`, `listRemove`, `none`. Mapeamento por átomo → [[Motion Intent Matrix]].

## Overrides per-instância

- `.cosmosMotion(_:)` — behavior
- `.cosmosMotionTokens(_:)` / `.cosmosSpringStyle(_:)` — visual