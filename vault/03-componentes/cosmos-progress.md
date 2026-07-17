---
tags: [atom, wave-a]
tier: low
pattern: style-protocol
guard: none
aliases: [CosmosProgress, Cosmos Progress]
related: [[Átomos Overview]], [[Reduce Motion Policy]]
---

# Cosmos Progress

> Wave A · `ProgressViewStyle` · sem guard · sem `#available` no floor `.v26`

## Pattern & surface
Style-protocol (`ProgressViewStyle`). `CosmosProgressStyle.makeBody(configuration:)` lê `fractionCompleted: Double?` (nil = indeterminate), `label`, `currentValueLabel`. Built-ins `.automatic/.linear/.circular` (SE-0299). `.tint(_:)` (Color iOS 15+, ShapeStyle iOS 16+). Style custom pode desenhar ring via `Circle().trim(from:to:)`.

## Inits a expor
Indeterminate: `init()`, `init(@ViewBuilder label:)`, `init(_ titleKey:)`, `init<S>(_ title:)`. Determinate: `init<V>(value: V?, total: V = 1.0)` + variants label/currentValueLabel; `init(_ titleKey:, value:, total:)`, `init<S,V>(_ title:, value:, total:)`; `init(_ progress: Progress)`; `init(timerInterval:countsDown:label:currentValueLabel:)` (iOS 16+).

## Customization limits
Bodies dos styles built-in são opacos — sem espessura de barra / cor de track / curva de anim sem um `makeBody` custom completo. `init(tint:)` em Linear/Circular é **deprecated** — use `.tint(_:)`, nunca exponha init com tint. Timing do spinner indeterminate não exposto.

## Cross-cutting
- **A11y:** trait `updatesFrequently` auto (documentado, NÃO no interface — trate como plausible-but-unverified). VoiceOver lê percentual (determinate) / "in progress" (indeterminate). Sempre `.accessibilityLabel`; opcional `.accessibilityValue` (determinate). `makeBody` custom **DEVE** re-aplicar `accessibilityLabel`/`Value`/`traits` (wiring nativo perdido).
- **Haptics:** none. Passivo. Haptic de completion, se quiserm, vem do call site (`.sensoryFeedback(.success)`), gateado por config + reduceMotion.
- **Motion:** `valueChange` para fills determinate (`.cosmosAnimation(.valueChange, value: fraction)`); `appear`/`disappear` quando loading começa/termina. **Indeterminate spinning é loop contínuo** — suprimir sob reduce-motion a menos que progress seja sinal único (`.preserve`); senão `.substitute` (crossfade / "Loading" estático). Rota por `CosmosMotionPolicy.shouldEmit`, NÃO env cru. Ao delegar a built-in, NÃO double-gate do spinner nativo (auto-respeita).

## Key modifiers
`.progressViewStyle`, `.tint`, `.accessibilityLabel/Value`, `.cosmosAnimation(.valueChange, value:)`, `.cosmosMotion`/`.cosmosMotionTokens`.

## Riscos / TODOs
- `makeBody` custom perde trait `updatesFrequently` nativo — re-aplicar a11y.
- `fractionCompleted` é `Double?` — tratar nil como indeterminate, nunca force-unwrap.
- `Progress` é `@MainActor`-bound — instâncias do call site MainActor-isolated ou value-backed sob Swift 6.