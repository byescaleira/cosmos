---
tags: [atom, wave-c]
tier: medium
pattern: style-protocol
guard: "#if !os(tvOS) && !os(watchOS)"
aliases: [CosmosGroupBox, Cosmos GroupBox]
related: [[Átomos Overview]], [[Plataforma Guards]]
---

# Cosmos GroupBox

> Wave C · `GroupBoxStyle` · guard `#if !os(tvOS) && !os(watchOS)` · sem `#available`

## Pattern & surface
Style-protocol (`GroupBoxStyle`). `CosmosGroupBoxStyle.makeBody(configuration:)` recebe `label`/`content` como opaque pass-throughs (`Body == Never`, place-only). Só `DefaultGroupBoxStyle` existe (`.automatic`) — sem `.bordered`/`.plain`. `.groupBoxStyle(_:)` aplica qualquer style conforme.

## Inits a expor
`init(@ViewBuilder content:)`, `init(_ titleKey:, @ViewBuilder content:)`, `init<S>(_ title:, @ViewBuilder content:)`, `init(_ titleResource:, @ViewBuilder content:)` (iOS 16+), `init(@ViewBuilder content:, @ViewBuilder label:)` (content-first canônico — **NÃO** o deprecated `init(label:content:)`).

## Fallback (tvOS/watchOS)
Renderizar fallback plain — o label (como `Text` header, se houver) acima do content num `VStack` com padding/typography do `CosmosTheme`, sem chrome GroupBox. API pública uniforme atrás do guard; branch internamente.

## Customization limits
Só um style built-in; seu body é token opaco — qualquer desvio visual exige `GroupBoxStyle` custom completo que reimplementation o chrome. Sem modifier escalar `.tint` para aparência do GroupBox. `.groupBoxStyle` indisponível em tvOS/watchOS.

## Cross-cutting
- **A11y:** NÃO forçar `.isContainer` (duplicaria o grouping do SwiftUI). Child atoms carregam seus próprios labels/traits. Dynamic Type reflui. Sem `accessibilityIdentifier` no box; rely on child `trackingId` fallback.
- **Haptics:** none — container estático.
- **Motion:** `none`. Style custom poderia opcionalmente aplicar `.cosmosTransition(.containerTransform)` em appear/disappear (caller-driven). `matchedGeometryEffect` se usado: single `@Namespace`, single `isSource: true`, um `withAnimation(theme.motion.spring(for: .containerTransform).animation)`.

## Key modifiers
`.groupBoxStyle`, `.automatic`, `.cosmosMotion`/`.cosmosMotionTokens`/`.cosmosSpringStyle`, `.cosmosPreviewVariant`/`.cosmosPreviewEnv`.

## Riscos / TODOs
- Confirmar fallback path em tvOS/watchOS compila sem referenciar símbolos GroupBox.
- `GroupBoxStyle` é `@MainActor @preconcurrency` — manter `CosmosGroupBoxStyle` `~Swift.Sendable`, `makeBody` MainActor-isolated.
- `init(_ configuration:)` (iOS 14/macOS 11) só precisa se um style re-emite GroupBox; não expor `init(label:content:)` deprecated.