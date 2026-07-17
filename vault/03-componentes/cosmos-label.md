---
tags: [atom, wave-a]
tier: low
pattern: style-protocol
guard: none
aliases: [CosmosLabel, Cosmos Label]
related: [[Átomos Overview]], [[Motion Intent Matrix]]
---

# Cosmos Label

> Wave A · `LabelStyle` · sem guard · sem `#available` no floor `.v26`

## Pattern & surface
Style-protocol (`LabelStyle`). `CosmosLabelStyle` compõe `configuration.title` + `configuration.icon` (ambos `SwiftUICore.View`, `Body == Never` no nível de configuration-piece mas usáveis como Views). Built-ins via `.labelStyle(.automatic/.iconOnly/.titleOnly/.titleAndIcon)`.

## Inits a expor
`init(_ titleKey:, systemImage:)`, `init<S>(_ title:, systemImage:)`, `init(_ titleKey:, image:)`, `init<S>(_ title:, image:)`, genérico `init(@ViewBuilder title:, @ViewBuilder icon:)`, e variants `LocalizedStringResource` (iOS 16+; key/String preferidos). **Não** re-declare o title como `accessibilityLabel`.

## Customization limits
`configuration.title`/`.icon` são opacos (`Body == Never`) — compõe apenas, nunca introspect. Sem controle pré-iOS-26 de spacing ícone↔título exceto layout nativo. Modifiers: `.foregroundStyle`, `.font` (`relativeTo:` em custom), `.symbolEffect` (iOS 17+, no ícone only), iOS 26 `.labelReservedIconWidth(_:)` / `.labelIconToTitleSpacing(_:)`.

## Cross-cutting
- **A11y:** rely on título inferido como label VoiceOver (NÃO double-label); override só via modifier `.cosmosAccessibleLabel`. Dynamic Type flui pelo title Text.
- **Haptics:** none. Estático.
- **Motion:** `none`. Style custom pode aplicar `.symbolEffect` no ícone (caller-driven); gate em `configuration.motion.isEnabled` ONLY — symbolEffect auto-respeita RM. PhaseAnimator contínuo no ícone suprimido sob reduce-motion a menos que seja sinal único (`.preserve`).

## Key modifiers
`.labelStyle`, `.foregroundStyle`, `.font`, `.labelReservedIconWidth`, `.labelIconToTitleSpacing`, `.symbolEffect`, `.accessibilityLabel/Hint/Identifier`.

## Riscos / TODOs
- Verificar iOS 26 `.labelReservedIconWidth`/`.labelIconToTitleSpacing` renderizam em telas pequenas watchOS/tvOS (declarados available — confirmar visualmente em `#Preview`).
- `LabelStyle` é `@preconcurrency @MainActor` — manter `CosmosLabelStyle` `Sendable`, evitar capturar state non-Sendable. → [[Swift 6 Concurrency]].