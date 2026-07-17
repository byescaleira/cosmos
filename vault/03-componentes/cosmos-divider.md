---
tags: [atom, wave-b]
tier: low
pattern: wrap-view
guard: none
aliases: [CosmosDivider, Cosmos Divider]
related: [[Átomos Overview]]
---

# Cosmos Divider

> Wave B · wrap-view (sem `DividerStyle`) · sem guard · sem `#available`

## Pattern & surface
Wrap-view. `Divider` ignora `.foregroundStyle`/`.background`/`.tint` para a cor da linha — recolor via `.overlay(Color, in: .rectangle)` ou substitua por `Rectangle`/`Canvas` desenhado de tokens do theme. Aplique padding do theme; `.accessibilityHidden(true)`; show/hide condicional via `.cosmosTransition(.sheet)`. **Eixo é inferido do `HStack`/`VStack` envolvente — NÃO re-wrapar num container para forçar eixo.**

## Inits a expor
`init()` (forward zero-arg).

## Customization limits
Sem style protocol; sem param de cor/espessura/dash/eixo; recolor exige overlay ou `Rectangle` desenhado à mão. Decidir se `CosmosDivider` oferece token de espessura ou um `CosmosHairline` separado para separadores customizados.

## Cross-cutting
- **A11y:** `.accessibilityHidden(true)` — puramente decorativo, nunca alvo de VoiceOver. Se overlay temático, garantir contraste contra o background (gate via `@Environment(\.colorSchemeContrast)` / `.accessibilityDifferentiateWithoutColor`).
- **Haptics:** none.
- **Motion:** `none`. Estático. Motion container-driven (list insert/remove) lida com aparição condicional: `.cosmosTransition(.sheet)` ou `listInsert`/`listRemove` no nível do container — um `withAnimation` via `theme.motion.spring(for: .containerTransform)`, não `.animation(_:value:)` por-divider.

## Key modifiers
`.accessibilityHidden(true)`, `.overlay(_:in:)` / `Rectangle` custom, `.padding(...)`, `.cosmosTransition(.sheet)`, `.frame(...)` para constrain length.

## Riscos / TODOs
- Confirmar overlay cobre o hairline confiavelmente (`Rectangle().fill` nos bounds do divider).
- Confirmar availability visionOS em runtime (linha `@available` omite visionOS por quirk pre-visionOS-symbol — deve compilar/rodar em visionOS 1.0+, verificar com build visionOS).
- Verificar quirks de renderização de separador em watchOS/tvOS.