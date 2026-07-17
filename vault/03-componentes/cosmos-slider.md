---
tags: [atom, wave-d]
tier: medium
pattern: wrap-view
guard: "#if !os(tvOS)"
aliases: [CosmosSlider, Cosmos Slider]
related: [[Átomos Overview]], [[Plataforma Guards]]
---

# Cosmos Slider

> Wave D · wrap-view (sem `SliderStyle`) · guard `#if !os(tvOS)` (todo o arquivo + API pública referenciante) · cluster iOS 26 sempre disponível no floor

## Pattern & surface
Wrap-view (zero hits de SliderStyle em qualquer interface). `.tint(_:)` (Color, iOS 15+) / `.tint<S>(_:)` ShapeStyle (iOS 16+, NÃO 15+) colorem o track MÍNIMO/filled. Label/min/max value label closures. `step: V.Stride` p/ discretização. `onEditingChanged: (Bool) -> Void`. iOS 26: `neutralValue`, `enabledBounds`, `currentValueLabel`, `ticks` via `@SliderTickBuilder`. `.controlSize`. AccessibilityLabel/Value/Hint/Identifier.

## Inits a expor
`init<V>(value:, in:, onEditingChanged:)` (Label == EmptyView), `init<V>(value:, in:, step:, onEditingChanged:)`, variants com label, com min/max value label (label-first builder order ONLY — nunca a ordem deprecated `onEditingChanged`-before-`label`). Cluster iOS 26: `init<V>(value:, in:, neutralValue:, enabledBounds:, label:, currentValueLabel:, minimumValueLabel:, maximumValueLabel:, onEditingChanged:)`, variant `ticks: @SliderTickBuilder<V>`, e single-tick `tick: (V) -> SliderTick<V>?`.

## Fallback (tvOS)
Nada renderiza (arquivo excluído); documentar que apps tvOS usam Stepper/Picker.

## Customization limits
Sem style protocol — não pode customizar altura/shape do track, tamanho/shape/imagem/glyph do thumb, cor do max-track independentemente, renderização de ticks pré-iOS-26, ou focus ring. Só o min (filled) track é tintable. Thumb/hit-target/continuous-vs-discrete são opacos/native-bridged. `V` deve conformar a `BinaryFloatingPoint` (Double/Float, não Int).

## Cross-cutting
- **A11y:** VoiceOver adjustable element; **step é OBRIGATÓRIO** para ajuste significativo (sem step, VoiceOver usa increment default). Sempre suprir label e, quando valor exibido difere do Double cru, setar `.accessibilityValue`. `.accessibilityHint`. Focusable p/ keyboard (macOS/visionOS) e Full Keyboard Access (iOS) — `.focusable()`/`.focused`. Não confiar só no tint (WCAG 1.4.1 — thumb position é sinal primário).
- **Haptics:** `.sensoryFeedback(.selection, trigger: steppedValue)` no step-snap (discrete), e/ou `.sensoryFeedback(.impact(.soft), trigger: isEditing)` no drag begin/end. Gate `CosmosHapticsPolicy.shouldEmit`. Contínuo (sem step): só edit-begin/end `.impact`, não per-pixel. watchOS haptics available (watchOS 10+). (Entregue: haptic `.selection` quantizado via `CosmosSliderMath.stepped` — feedback no step-snap, nunca por pixel — [[Changelog Resumo]].)
- **Motion:** `valueChange` — drag contínuo move thumb + tint fill. Secundário `press` no drag-begin (thumb escala/pressiona). Step-snap usa `valueChange` com spring mais snappy. iOS 26 neutralValue crossing usa `valueChange` coordenado com `.cosmosContentTransition` no tint.

## Key modifiers
`.tint(_:)` (Color), `.tint<S>(_:)` (ShapeStyle), `.controlSize`, `.accessibilityLabel/Value/Hint/Identifier/AdjustableAction`, `.sensoryFeedback(.selection, trigger:)` (gated), `.cosmosAnimation(.valueChange, value:)`, `.cosmosMotion`/`.cosmosMotionTokens`/`.cosmosSpringStyle`, `.focusable`/`.focused`.

## Riscos / TODOs
- TODO ARQUIVO INTEIRO + API pública referenciante `#if !os(tvOS)`.
- **NÃO** criar `CosmosSliderStyle`.
- Expor SÓ inits label-first builder (ordem antiga deprecated → warnings-as-failures).
- `step` é `V.Stride` (BinaryFloatingPoint.Stride) — manter `V` BinaryFloatingPoint.
- watchOS interaction awkward (tela pequena) — verificar preview, considerar `.controlSize(.mini)`.
- **NÃO** animar o binding por frame de drag (`withAnimation` briga com o gesto) — só commits programáticos e crossfades de tint.
- `.tint<S>(_:)` ShapeStyle overload é iOS 16.0+ (corrigir erro do spec original iOS 15.0+) — ver [[Itens Refutados]].
- `.sensoryFeedback` disponível em tvOS 17.0 (corrigir spec original) — moot p/ este átomo (gated `#if !os(tvOS)`) mas não assumir tvOS-unavailability alhures.