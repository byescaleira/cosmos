---
tags: [cross-cutting]
aliases: [Contratos Cross-cutting, 9 Contracts]
related: [[Arquitetura Cosmos]], [[Checklist de Integração]], [[ADR Global State Entry]]
---

# Contratos Cross-cutting (9)

Todo átomo/molécula integra, onde relevante, estes 9 concerns. Fluem pelo `@Entry` environment (`cosmosConfiguration` agrega os 8 behavior; `cosmosTheme.motion` carrega os tokens visuais de motion). Os 9 primeiros itens do [[Checklist de Integração]].

| # | Contrato | Como | Gate |
|---|---|---|---|
| 1 | **Accessibility** | label/value/hint/identifier/traits/customContent + env gates `reduceMotion`/`reduceTransparency`/`colorSchemeContrast`/`differentiateWithoutColor` + Dynamic Type reflow | `cosmosConfiguration.accessibility` (NÃO env cru) |
| 2 | **Haptics** | `.sensoryFeedback` | `CosmosHapticsPolicy.shouldEmit(isEnabled:respectReduceMotion:reduceMotion:)` (NÃO env cru); no-op sem hardware; coord com value-change anim; não double-haptic contra nativo (Stepper, Toggle→`.switch`) |
| 3 | **Localization** | strings via `CosmosLocalizationConfiguration`; preferir `LocalizedStringKey`/`LocalizedStringResource`; símbolos string-constant públicos; baseline `en` + `pt-BR` | — |
| 4 | **Tracking** | `CosmosTrackingConfiguration.track(_:)`; `componentId = trackingId ?? accessibilityIdentifier` | opt-in, passivo, sem network/PII |
| 5 | **Motion** | `.cosmosAnimation(_:value:)`/`.cosmosTransition(_:)`/`.cosmosContentTransition(_:)` | `CosmosMotionPolicy.shouldEmit` (config-aware); `symbolEffect` gate `isEnabled` only; springs preferred; single `withAnimation` por mudança coordenada |
| 6 | **Enable** | `cosmosConfiguration.enable` (ou flag relevante) gateia behavior ativo; disabled é visualmente coerente | — |
| 7 | **Loading** | `cosmosConfiguration.loading` onde relevante | — |
| 8 | **Log** | `cosmosConfiguration.log` p/ eventos de diagnóstico (sem PII, sem network) | — |
| 9 | **Error** | `cosmosConfiguration.error` p/ reporte de erros (ex.: falha de validação de binding) | — |

## Origem dos 8→9

Originalmente 8 contratos (Accessibility, Localization, Log, Error, Loading, Enable + **Haptics** + **Tracking** — estes dois novos). Motion virou o **9º** em 2026-07-17 — [[ADR Motion 9th Contract]].

> Layout-adaptive (`AnyLayout`/`ViewThatFits` por size class) e multiplatform (`#if os()`) são itens 10 e 11 do checklist, não contratos próprios.