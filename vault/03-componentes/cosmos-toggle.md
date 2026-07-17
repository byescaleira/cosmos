---
tags: [atom, wave-a]
tier: low
pattern: style-protocol
guard: none
aliases: [CosmosToggle, Cosmos Toggle]
related: [[Átomos Overview]], [[Motion Intent Matrix]]
---

# Cosmos Toggle

> Wave A · `ToggleStyle` · sem guard · sem `#available` no floor `.v26`

## Pattern & surface
Style-protocol (`ToggleStyle`). `CosmosToggleStyle.makeBody(configuration:)` lê `label`, `$isOn`, `isMixed` (iOS 16+). Built-ins `.automatic/.switch/.button/.checkbox`. `.tint(_:)` (substitui deprecated `SwitchToggleStyle(tint:)`). `.controlSize(_:)`/`.controlSize(_:range)`, `.labelsHidden()`, `.sensoryFeedback(.selection, trigger: isOn)`.

## Inits a expor
`init(isOn: Binding<Bool>, @ViewBuilder label:)` (primário), `init(_ titleKey:, isOn:)`, `init<S>(_ title:, isOn:)`, `init(_ titleResource:, isOn:)` (`@_disfavoredOverload`, iOS 16+), `init(_ titleKey:, systemImage:, isOn:)` + variants, `init<C>(sources:isOn:label:)` (iOS 16+ multi-row), `init(_ configuration: ToggleStyleConfiguration)`.

## Customization limits
Bodies dos styles built-in opacos; sem tunar thumb/track/corner-radius sem style custom completo. `.checkbox` macOS-only, `.button` tvOS-unavailable, `.switch` tvOS-min-raised-to-18. `Toggle.body` opaco — não pode wrappar e mutar rendering default.

## Cross-cutting
- **A11y:** trait `.isToggle` + valor on/off são **PERDIDOS** quando Cosmos desenha seu próprio thumb/track — style custom **DEVE** re-add `.accessibilityAddTraits(.isToggle)` (ou `.isButton` p/ button-style) + `.accessibilityValue(isOn ? "On" : "Off")` (+ "Mixed" quando `isMixed`). Verificar com VoiceOver.
- **Haptics:** `.sensoryFeedback(.selection, trigger: isOn)` gateado por `CosmosHapticsPolicy` (config.haptics.isEnabled + respectReduceMotion). Coordenar com anim value-change. No-op no macOS graciosamente.
- **Motion:** `valueChange`. Drive thumb/fill com **single** `withAnimation(theme.motion.spring(for: .valueChange).animation)` por state change; mapear via `.cosmosAnimation(.valueChange, value: isOn)`. Sem per-view `.animation(_:value:)` com curvas diferentes. Thumb do `SwitchToggleStyle` nativo **não** é driven por SwiftUI `Animation` — ao delegar a `.switch`, suprimir Cosmos motion (evita double anim).

## Key modifiers
`.toggleStyle`, `.tint`, `.controlSize`, `.labelsHidden`, `.cosmosMotion`/`.cosmosMotionTokens`, `.cosmosAnimation(.valueChange, value:)`, `.cosmosContentTransition`, `.sensoryFeedback(.selection, trigger:)`, `.accessibilityLabel/Value/Hint/Identifier/traits`.

## Riscos / TODOs
- Guards de style built-in por plataforma (`.checkbox` `#if os(macOS)`, `.button` `#if !os(tvOS)`, `.switch` tvOS ≥ 18 — nunca baixar o floor tvOS abaixo de 18).
- `SwitchToggleStyle(tint:)` deprecated — nunca expor.
- Verificar sem double anim ao wrapar `.switch` + `.cosmosAnimation`.
- Verificar semântica do binding multi-row `sources:` se exposto.