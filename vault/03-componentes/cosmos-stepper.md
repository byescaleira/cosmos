---
tags: [atom, wave-d]
tier: medium
pattern: wrap-view
guard: "#if !os(tvOS)"
aliases: [CosmosStepper, Cosmos Stepper]
related: [[Átomos Overview]], [[Plataforma Guards]]
---

# Cosmos Stepper

> Wave D · wrap-view (sem `StepperStyle`) · guard `#if !os(tvOS)` (todo o átomo + API referenciante) · watchOS floor 9.0

## Pattern & surface
Wrap-view (zero hits de StepperStyle). Label é View genérico (`@ViewBuilder`). Value/step/bounds via `Binding<V>` onde `V: Strideable`, ou closures `onIncrement`/`onDecrement`. `onEditingChanged: (Bool) -> Void` (true=begin, false=end). Modifiers: `.tint` (tinta +/- em iOS), `.controlSize`, `.font`/`.foregroundColor` no label, `.accessibilityLabel/Value/Hint/Identifier`, `.cosmosAnimation(.valueChange, value:)`, `.cosmosContentTransition(.numericText or .blurReplace)`, `.sensoryFeedback` (só se NÃO dobrar o nativo). SE-0299 N/A.

## Inits a expor
`init(label:, onIncrement:, onDecrement:, onEditingChanged:)` (label-first renamed — NÃO trailing-closure-last deprecated), `init(value:, step:, label:, onEditingChanged:)` (`V: Strideable`), `init(value:, in:, step:, label:, onEditingChanged:)` (bounded `ClosedRange`), conveniences Text-label (`init(_ titleKey:, onIncrement:onDecrement:onEditingChanged:)`, `init(_ titleKey:, value:, step:, onEditingChanged:)`, `init(_ titleKey:, value:, in:, step:, onEditingChanged:)`), format-based `init(value:, step:, format:, label:, onEditingChanged:)` + bounded (iOS 16+/macOS 13+/watchOS 9+; `F.FormatInput: BinaryFloatingPoint` — Double/Float only, **NÃO Int**).

## Fallback (tvOS)
Renderizar fallback não-interativo OU par `CosmosButton` +/- (dois Buttons wrapando `onIncrement`/`onDecrement`) com o mesmo `Binding` de valor. Preferir Button-pair p/ o controle continuar funcional em tvOS. Wrap em `#if os(tvOS) ... #else (real Stepper) #endif`. (Entregue — [[Changelog Resumo]].)

## Customization limits
Sem style protocol; rendering opaco/native-bridged — sem restyle de glyphs +/-, shapes de botão, spacing, repeat cadence, Digital Crown binding (watchOS), keyboard/long-press repeat (macOS). Sem placeholder, sem clear-button, sem multi-segment. tvOS não tem Stepper.

## Cross-cutting
- **A11y:** VoiceOver anuncia label e valor atual; increment/decrement via rotor/swipe/Digital Crown/arrow keys. Cosmos **DEVE** setar `accessibilityLabel`, `accessibilityValue` (syncado com Binding), `accessibilityHint` ("Increments/decrements by N"). `accessibilityIdentifier` flui pro trackingId fallback. **NÃO** forçar `.isButton` no Stepper nativo (só no fallback Button-pair tvOS, que já tem button traits). Dynamic Type aplica ao label; glyphs +/- são chrome nativo fixed-size.
- **Haptics:** Stepper nativo auto-emite haptics de sistema em iOS/watchOS — Cosmos **NÃO** deve layer `.sensoryFeedback(.selection, trigger: value)` no Stepper real (double-fire). No fallback Button-pair tvOS (sem haptic nativo): `.selection` no tap, gateado por `config.haptics.isEnabled && CosmosHapticsPolicy.shouldEmit(...) && accessibilityReduceMotion`.
- **Motion:** `valueChange` — cada +/- (ou Crown twist) muda o valor Strideable por `step`. `.cosmosAnimation(.valueChange, value: value)` wrapando o write do Binding + `.cosmosContentTransition(.numericText)` (ou `.blurReplace`) no texto de valor exibido. `onEditingChanged(true→false)` bracketa uma sessão; NÃO usar `appear`/`disappear`/`sheet`. Sem `containerTransform`/`matchedGeometry`.

## Key modifiers
`.tint`, `.controlSize`, `.font`/`.foregroundColor` no label, `.accessibilityLabel/Value/Hint/Identifier`, `.cosmosAnimation(.valueChange, value:)`, `.cosmosContentTransition(.numericText)`/`.blurReplace`, `.sensoryFeedback` (tvOS fallback only), `.cosmosTrackingId` + `CosmosTrackingConfiguration.track(.changed)` em increment/decrement.

## Riscos / TODOs
- Ausência tvOS é tipo-level — guardar átomo inteiro + API referenciante.
- watchOS floor é 9.0 (não 6.0) — não assumir watchOS 6.
- Inits trailing-closure-last deprecated — usar label-first renamed só.
- Risco double-haptic no Stepper real — só add haptics ao fallback tvOS.
- Inits format-based requerem `F.FormatInput: BinaryFloatingPoint` (Double/Float, NÃO Int) — para Int steppers usar inits Strideable.
- Semântica `onEditingChanged` tem que ser plumbed (callers deferem work caro).
- visionOS availability implícita (sem `@available(visionOS, unavailable)`) — verified available.