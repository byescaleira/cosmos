---
tags: [atom, wave-c]
tier: medium
pattern: style-protocol
guard: "#if !os(watchOS)"
aliases: [CosmosMenu, Cosmos Menu]
related: [[Átomos Overview]], [[Plataforma Guards]]
---

# Cosmos Menu

> Wave C · `MenuStyle` · guard `#if !os(watchOS)` · sem `#available` no floor `.v26` (tvOS floor p/ Menu é 17)

## Pattern & surface
Style-protocol (`MenuStyle`). `CosmosMenuStyle.makeBody(configuration:)` — customiza totalmente o **TRIGGER** (wrap `configuration.label` com `.buttonStyle(.bordered/.borderless/.plain/.glass/.glassProminent)`, `.tint`, `.controlSize`, `.labelStyle`, `.font`, padding, `.glassEffect`, a11y). Built-ins `.automatic` (DefaultMenuStyle) e `.button` (ButtonMenuStyle, iOS 16+). Modifiers: `.menuOrder(_:)` (`.priority` unavailable macOS/tvOS/watchOS — iOS/visionOS only), `.menuIndicator(_:)` (tvOS 17+, watchOS unavailable), `.menuActionDismissBehavior(_:)` (`.disabled` available iOS 16.4+/tvOS 17.0+/visionOS 1.0+, unavailable macOS/watchOS — **NÃO** tvOS-exclusive), `.buttonStyle(_:)` paired com `.menuStyle(.button)`. Content builder: Button, Toggle, Picker(.menu), nested Menu, Section, Divider, ControlGroup.

## Inits a expor
`init(@ViewBuilder content:, @ViewBuilder label:)`, `init(_ titleKey:, @ViewBuilder content:)`, `init(_ titleResource:, @ViewBuilder content:)`, `init<S>(_ title:, @ViewBuilder content:)`, variants `systemImage:`/`image: ImageResource` (iOS 17+), variants `primaryAction:` (iOS 15+), `init(_ configuration: MenuStyleConfiguration)`.

## Fallback (watchOS)
Renderizar `CosmosButton` (ou `CosmosPicker` / overflow Sheet) como substituto de overflow dentro de `#if os(watchOS)`; body Menu-backed em `#if !os(watchOS)`.

## Customization limits
Conteúdo do popover é opaco (`MenuStyleConfiguration.Content`/`.Label` `Body == Never`) — não dá inspecionar/decompor/re-render rows/separadores/chrome/highlight/surface; só o chrome ao redor do trigger é customizável. `BorderedButtonMenuStyle` macOS-only deprecated; `BorderlessButtonMenuStyle` deprecated → route pra `.menuStyle(.button)` + `.buttonStyle`. watchOS não tem Menu. Popover + Liquid Glass chrome em OS 26 são system-controlled.

## Cross-cutting
- **A11y:** trigger precisa `accessibilityLabel` descritivo (title Text/Label basta; setar explícito se icon-only). `accessibilityIdentifier` no trigger para tracking. Buttons/Toggles contidos herdam traits standard.
- **Haptics:** plain (no-primary) Menu — none on open (Apple menus não hapticam; Buttons contidos ownam os seus). primaryAction Menu — `.sensoryFeedback(.selection, trigger:)` (ou `.impact(.rigid)` se destructivo) no primary tap. Gate `CosmosHapticsPolicy.shouldEmit`.
- **Motion:** `press` — resposta de press do trigger. Popover appear/dismiss é nativo system-controlled — NÃO mapear `.sheet`/`.appear`/`.containerTransform` ao popover. Regra single-resolver: Cosmos só owna o trigger.

## Key modifiers
`.menuStyle`, `.buttonStyle` (com `.menuStyle(.button)`), `.controlSize`/`.labelStyle`/`.font`/`.tint`, `.menuOrder`, `.menuIndicator`, `.menuActionDismissBehavior`, `.accessibilityLabel/Value/Hint/Identifier/traits`, `.cosmosAnimation(.press, value:)`, `.cosmosMotion`/`.cosmosMotionTokens`/`.cosmosSpringStyle`, `.cosmosTrackingId`.

## Riscos / TODOs
- `MenuStyle` é `@preconcurrency @MainActor` — zero warnings Swift 6 (marcar conformance `@preconcurrency` se preciso, struct fica `Sendable`); configuration.Label/Content opaco — nunca decompor.
- `primaryAction` closure `@Sendable`-friendly.
- Verificar `.glassProminent` availability no target.
- **NÃO** aplicar `.glassEffect` ao conteúdo do popover.