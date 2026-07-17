---
tags: [atom, cross-cutting]
aliases: [Checklist de Integração, Per-atom Checklist]
related: [[Contratos Cross-cutting]], [[Átomos Overview]]
---

# Checklist de Integração (por átomo)

> Fonte: `PHASE2.md` §5. Antes de marcar um átomo completo, verificar os 11 itens.

1. **Accessibility** — label/value/hint/identifier/traits/customContent conforme; gates `reduceMotion`/`reduceTransparency`/`colorSchemeContrast`/`differentiateWithoutColor` lidos via `cosmosConfiguration` (não env cru); Dynamic Type reflow (custom fonts passam `relativeTo:`); em `makeBody` custom que reimplementation rendering, **RE-APPLY** traits/labels nativos perdidos (Toggle `.isToggle`+value; ProgressView `updatesFrequently`+label/value; Menu trigger label; GroupBox children carry their own).
2. **Haptics** — `.sensoryFeedback` gateado por `CosmosHapticsPolicy.shouldEmit(isEnabled:respectReduceMotion:reduceMotion:)` (NÃO env cru); no-op onde não há hardware; coordenar com anim value-change; NÃO double-haptic contra emissões nativas (Stepper, Toggle delegado a `.switch`).
3. **Localization** — strings via `CosmosLocalizationConfiguration`; preferir inits `LocalizedStringKey`/`LocalizedStringResource`; símbolos string-constant públicos; baseline `en` + `pt-BR`.
4. **Tracking** — `CosmosTrackingConfiguration.track(_:)` com `componentId = trackingId ?? accessibilityIdentifier`; opt-in, passivo, sem network/PII.
5. **Motion** — `.cosmosAnimation(_:value:)`/`.cosmosTransition(_:)`/`.cosmosContentTransition(_:)` resolvidos via `CosmosMotionTokens.animation(for:)`; gateados por `CosmosMotionPolicy.shouldEmit` (config-aware, NÃO `accessibilityReduceMotion` cru); `symbolEffect` gate em `isEnabled` ONLY (auto-respeita RM — não double-gate); springs preferred; **single** `withAnimation` por mudança de estado coordenada; sem per-view `.animation(_:value:)` com curvas diferentes.
6. **Enable** — `cosmosConfiguration.enable` (ou flag relevante) gateia behavior ativo; estado disabled visualmente coerente.
7. **Loading** — onde relevante (ProgressView, Picker/Toggle/Menu em contextos loading), `cosmosConfiguration.loading` reflete loading.
8. **Log** — `cosmosConfiguration.log` para eventos de diagnóstico (sem PII, sem network).
9. **Error** — `cosmosConfiguration.error` para reporte de erros (ex.: falha de validação de binding).
10. **Layout-adaptive** — `AnyLayout`/`ViewThatFits` switched por `horizontalSizeClass`/`verticalSizeClass`/`dynamicTypeSize` para identidade de view (focus/scroll/animation) sobreviver ao reflow; sem `if/else` que recria identidade em rotação. Verificar em previews landscape + Dynamic Type accessibility.
11. **Multiplatform** — guards `#if os()` corretos per [[Plataforma Guards]]; build para CADA plataforma (iOS/macOS/tvOS/watchOS/visionOS); `#available` runtime centralizado; `#Preview` blocks por variante (default / disabled-loading / dark / Dynamic Type accessibility / landscape / RTL / per-platform) usando `#Preview(_:traits:)` — NÃO os modifiers deprecados; inject env via `.cosmosPreviewEnv`/`.cosmosPreviewVariant` + SPI keys de a11y; setup compartilhado via `CosmosPreviewModifier`.

> Os 9 primeiros = os [[Contratos Cross-cutting]]; 10 e 11 = layout + multiplatform.