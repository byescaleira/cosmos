---
tags: [atom, wave-b]
tier: low
pattern: wrap-view
guard: none
aliases: [CosmosLink, Cosmos Link]
related: [[Átomos Overview]]
---

# Cosmos Link

> Wave B · wrap-view (sem `LinkStyle`; `LinkButtonStyle` é `PrimitiveButtonStyle` p/ Button, macOS-only — NÃO é um style de Link) · sem guard · `#available`: `OpenURLAction.Result.systemAction(_:prefersInApp:)` iOS 26+

## Pattern & surface
Wrap-view. Label genérico (qualquer View). Modifiers de View standard no Link renderizado. URL handling interceptável via `.environment(\.openURL, OpenURLAction { ... })` — Cosmos **deve** centralizar um intercept openURL para tracking + routing in-app (ver `.cosmosOpenURL` / `CosmosOpenURLRouting`, já entregue em Wave B — [[Changelog Resumo]]).

## Inits a expor
`init(_ titleKey:, destination:)`, `init<S>(_ title:, destination:)`, `init(_ titleResource:, destination:)` (iOS 16+), `init(destination:, @ViewBuilder label:)`.

## Customization limits
Sem style protocol; sem closure de action (URL-driven only); sem exposição de press-state; press/highlight é system-controlled.

## Cross-cutting
- **A11y:** sistema expõe behavior de link; setar `.accessibilityLabel` quando label é icônico, `.accessibilityHint` para destination. Keyboard/focus navegável em tvOS/macOS.
- **Haptics:** none — sem state change observável. Haptic de intercept-counter artificial não é natural; se algum dia add, gate `config.haptics.isEnabled && !reduceMotion` com `.selection`.
- **Motion:** `none`. Label content pode carregar seu próprio `symbolEffect` (auto-respeita RM; gate `isEnabled` only).

## Key modifiers
`.environment(\.openURL, ...)` (centralizar), `.accessibilityLabel/Hint/Identifier`, `.foregroundStyle`/`.tint`, `.font`, `.cosmosMotion`/`.cosmosMotionTokens` (no label content).

## Riscos / TODOs
- `Link` é `@_Concurrency.MainActor @preconcurrency ~Swift.Sendable` — manter isolation MainActor limpo sob Swift 6.
- watchOS openURL pode ser no-op/restricted — documentar.
- `LinkButtonStyle` **nunca** deve ser wired como um style de Link.