---
tags: [adr, motion]
aliases: [ADR Motion 9th Contract, Motion 9th Contract]
related: [[Motion Subsystem]], [[ADR Reduce Motion Policy]], [[ADR Spring Presets]]
---

# ADR — Motion como 9º contrato cross-cutting

> 2026-07-17 · Decided

**Contexto.** Motion é um concern cross-cutting tokenizado em todo design system maduro (Material 3, Carbon, Polaris, Lightning, Atlassian — ver [[Design Systems Comparison]]). Apple HIG + WWDC23 pedem spring-first, purposeful, optional, reduce-motion-aware. Tem que encaixar na arquitetura global-state com **zero desvio estrutural**.

**Decisão.** Split como o resto do sistema:
- **Behavior/policy** em `cosmosConfiguration.motion` = `CosmosMotionConfiguration` (isEnabled / respectReduceMotion / reduceMotionPolicy / respectReduceTransparency / handler `@Sendable`) — 9º membro do `CosmosConfiguration`, espelha `CosmosHapticsConfiguration` linha-a-linha.
- **Tokens visuais** em `cosmosTheme.motion` = `CosmosMotionTokens` (presets `CosmosSpring`, escala `CosmosDuration`, presets `CosmosTransition`/`CosmosContentTransitionPreset` + o **único** resolver `animation(for:reduceMotion:policy:)`) — espelha `CosmosTypographyTokens`.

Átomos **nunca** escrevem `Animation.spring(...)`/`.transition(.move...)` crus. Chamam:
`.cosmosAnimation(.press, value: x)` / `.cosmosTransition(.sheet)` / `.cosmosContentTransition(.numeric)` — os chokepoints que resolvem tokens via `CosmosMotionTokens.animation(for:)` (single source of truth) e gate reduce-motion via `CosmosMotionPolicy` (config-aware, **não** o valor cru do env).

Overrides per-instância: `.cosmosMotion(_:)` (behavior), `.cosmosMotionTokens(_:)` / `.cosmosSpringStyle(_:)` (visual).

**Sem `if #available`** para primitives de motion no baseline Cosmos 26 (Spring/PhaseAnimator/KeyframeAnimator/blurReplace/symbolEffect/withAnimation(completion)/transition<T>/matchedGeometryEffect são todos iOS 17/18 ≤ 26 nas 5 plataformas). Gate `GlassEffectTransition.matchedGeometry` (iOS 26) só se o floor baixar.

> Subsistema completo → [[Motion Subsystem]]. Política reduce-motion → [[Reduce Motion Policy]]. Presets → [[Spring Presets]].