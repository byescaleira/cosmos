---
tags: [atom, wave-c]
tier: medium
pattern: style-protocol
guard: "#if !os(tvOS)"
aliases: [CosmosDatePicker, Cosmos DatePicker]
related: [[Átomos Overview]], [[Plataforma Guards]]
---

# Cosmos DatePicker

> Wave C · `DatePickerStyle` · guard `#if !os(tvOS)` (unavailability tipo-level) · floor watchOS 10.0

## Pattern & surface
Style-protocol (`DatePickerStyle`). `CosmosDatePickerStyle.makeBody(configuration:)` lê `label`, `$selection`, `minimumDate`, `maximumDate`, `displayedComponents`. 6 styles built-in (SE-0299): `.automatic`, `.wheel` (iOS/watchOS; NÃO macOS), `.graphical` (iOS/macOS; NÃO watchOS/tvOS), `.compact` (iOS/macOS 10.15.4; NÃO watchOS/tvOS), `.field`/`.stepperField` (macOS-only). `.datePickerStyle(_:)` (tvOS unavailable). Range via `in:`. Label custom via `@ViewBuilder`.

## Inits a expor
`init(_ titleKey:, selection:, displayedComponents:)`, range variants (`in: ClosedRange<Date>`, `PartialRangeFrom`, `PartialRangeThrough`), `init<S>(_ title:, selection:, displayedComponents:)`, `init(selection:, displayedComponents:, @ViewBuilder label:)` + range variants, `init(_ titleResource:, selection:, displayedComponents:)` (iOS 16+).

## Fallback (tvOS)
Ausência compile-time; código app-level escolhe alternativa (`CosmosPicker` ou date chooser custom baseado em navigation). Sem fallback in-place.

## Customization limits
Rendering interno de wheel/graphical/compact é opaco/native-bridged. Sem controle de cor do texto wheel-row, tint do dia do calendar, chrome do popover, cor do texto compact-display. Field/StepperField macOS-only; Wheel macOS-unavailable; Graphical/Compact watchOS/tvOS-unavailable. Sem clear-button/placeholder. `.hourMinuteAndSecond` watchOS-only.

## Cross-cutting
- **A11y:** label é o label VoiceOver; valor system-announced. Wheel/graphical expõem interação adjustable-like. `.accessibilityHint` quando restringe a range. `accessibilityIdentifier` para tracking.
- **Haptics:** `.sensoryFeedback(.selection, trigger: selection)` — DatePicker **NÃO** emite haptic de sistema automaticamente (ao contrário de Toggle/Slider), então é aditivo. Gate `CosmosHapticsPolicy`. Confirmar não double-fire em wheel scroll (debounce por mudança real de selection, não por scroll).
- **Motion:** `valueChange` — `.cosmosAnimation(.valueChange, value: selection)` / `.cosmosContentTransition(.numericText())` para reflow do compact/field. Wheel/graphical scroll intrínseco + popover são system-native — NÃO aplicar Cosmos motion kind neles.

## Key modifiers
`.datePickerStyle`, `.cosmosMotion`/`.cosmosMotionTokens`/`.cosmosSpringStyle`, `.cosmosContentTransition(.numericText())`, `.sensoryFeedback(.selection, trigger:)`, `.accessibilityLabel/Value/Hint/Identifier`, `.cosmosHaptics`, `.tint`, `.labelsHidden`, `.dynamicTypeSize`, `.cosmosTrackingId`.

## Riscos / TODOs
- Matriz de availability por style — um preset Cosmos **DEVE** guardar cada style com `#if os()` AND `#available`, nunca blanket-apply.
- Verificar visionOS DatePicker renderiza (sem UI de calendar nativa; default pode cair pra compact/field).
- Confirmar `makeBody` custom compila/roda em watchOS 10.
- `configuration.selection` setter é iOS 16/macOS 13/watchOS 10.
- Garantir default Cosmos resolve `.automatic` (não `.graphical`) em watchOS.
- Confirmar `.sensoryFeedback(.selection)` não double-fire em wheel scroll (debounce por selection change).