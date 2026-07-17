---
tags: [atom, wave-e]
tier: medium
pattern: wrap-view
guard: none (átomo); per-style #if os() guards dentro
aliases: [CosmosTabView, Cosmos TabView]
related: [[Átomos Overview]], [[Plataforma Guards]]
---

# Cosmos TabView

> Wave E · wrap-view (`TabViewStyle` NÃO conformable de forma útil — só `_makeView`/`_makeViewList`) · sem guard no átomo · per-style guards dentro · `tabBarMinimizeBehavior` all-5 iOS 26

## Pattern & surface
Wrap-view. `.tabViewStyle(_:)` com built-ins: `.automatic` (DefaultTabViewStyle, all platforms iOS 14+), `.page` (PageTabViewStyle, iOS/tvOS/watchOS — NÃO macOS), `.sidebarAdaptable` (iOS 18/macOS 15/tvOS 18/visionOS 2 — NÃO watchOS), `.tabBarOnly` (same as sidebarAdaptable — NÃO watchOS), `.verticalPage` (VerticalPageTabViewStyle, watchOS 10 only — renamed do deprecated CarouselTabViewStyle), `.grouped` (GroupedTabViewStyle, macOS 15 only). Selection programática via `Binding<Hashable>`. Content moderno via `Tab(title:image:systemImage:value:role:content:)` + `TabSection` dentro de `TabContentBuilder`. User reordering/visibility via `.tabViewCustomization(_:)` + `.customizationBehavior` (iOS 18/macOS 15/visionOS 2 — NÃO tvOS/watchOS). `.tabBarMinimizeBehavior(_:)` (all 5 em iOS 26). `.tabViewBottomAccessory` (iOS 26.0/26.1 — `#if os(iOS)`). `.tint`, `.accessibilityLabel`, `.accessibilityIdentifier` por Tab.

## Inits a expor
Moderno `init<C>(selection:, @TabContentBuilder<SelectionValue> content:)` (iOS 18/macOS 15/tvOS 18/watchOS 11/visionOS 2); non-selectable `init<C>(@TabContentBuilder<Never> content:)`; legacy `init(@ViewBuilder content:)` onde `SelectionValue == Int` (NÃO anotado deprecated, mas superseded — preferir TabContentBuilder). **NÃO** usar deprecated `init(selection: Binding?, @ViewBuilder content:)` ou `.tabItem { }` + `.tag(_)` (deprecated 100000.0 — warnings-as-failures).

## Runtime `#available`
Nada no floor `.v26` p/ base; `tabBarMinimizeBehavior` all-5 iOS 26; `tabViewBottomAccessory` iOS 26.0/26.1 (iOS-only); `TabRole.prominent` é `anyAppleOS 27.0` — **NÃO** no baseline Cosmos 26 (omitir inteiramente).

## Customization limits
`TabViewStyle` não conformable — sem tab bar custom. Aparência do tab bar (background, item fonts, bar height, indicator) é opaca — rely on `.tint` e defaults Liquid Glass do sistema. `PageTabViewStyle.IndexDisplayMode` limitado a `.automatic/.always/.never` (`.always`/`.never` watchOS 8+). tvOS: sem `.tabViewCustomization`/`TabViewCustomization` e sem `.tabViewBottomAccessory`. watchOS: sem tab bar UI — só styles paged. macOS: sem `.page`. Sem layout de tab bar custom / indicator de selection custom / More-overflow custom sem UIKit. `TabRole.prominent` é OS 27 (excluir).

## Cross-cutting
- **A11y:** cada Tab/TabItem label auto-expõe seu accessibility label; tab bar items get button trait nativo. VoiceOver anuncia tab focused + selection changes. P/ label content custom, aplicar `.accessibilityLabel`/`.accessibilityValue` explícitos. Dynamic Type escala tab labels; page-index dots não escalam. tvOS tabs são focus-engine driven. `.accessibilityIdentifier` por tab p/ tracking.
- **Haptics:** `.sensoryFeedback(.selection, trigger: selectionValue)` em tab change — gateado via `cosmosConfiguration.haptics.enabled AND accessibilityReduceMotion`. Sem `.impact` (mudança discreta, não step). No-op onde não há hardware.
- **Motion:** `tabSwitch` — switchar o binding de selection swapa o content exibido; crossfade coordenado (opacity + minor displacement) em selection change mapeia pra `tabSwitch`. Aplicar via `.cosmosContentTransition(.tabSwitch)` ou single `withAnimation(theme.motion.spring(for: .containerTransform).animation) { selection = newValue }` ao redor do write do binding. Evitar per-content-view `.animation(_:value:)` com curvas diferentes (desyncs).

## Key modifiers
`.tabViewStyle`, `.tabViewCustomization` (guard `#if !os(tvOS) && !os(watchOS)`), `.tint`, `.tabBarMinimizeBehavior` (all 5 iOS 26), `.tabViewBottomAccessory` (`#if os(iOS)`), `.accessibilityLabel`/`.accessibilityIdentifier` por Tab, `.cosmosAnimation(.tabSwitch, value: selection)`/`.cosmosContentTransition(.tabSwitch)`, `.sensoryFeedback(.selection, trigger:)` (gated), `.cosmosMotion`/`.cosmosMotionTokens`.

## Riscos / TODOs
- Divergência por style por plataforma é o maior risco — cada um precisa compile-time `#if os(...)` guard dentro de CosmosTabView, não um guard atom-level único (PageTabViewStyle macOS-unavailable; SidebarAdaptable/TabBarOnly watchOS-unavailable mas available em tvOS 18; VerticalPageTabViewStyle watchOS-only; GroupedTabViewStyle macOS-only; TabViewCustomization tvOS+watchOS-unavailable; tabViewBottomAccessory iOS-only).
- `TabViewStyle` não conformable — wrap, **NÃO** tentar `CosmosTabViewStyle` custom.
- Legacy `init(selection: Binding?, @ViewBuilder content:)` + `.tabItem` deprecated — usar viola zero-warnings.
- `CarouselTabViewStyle` deprecated/renamed pra `VerticalPageTabViewStyle` — nunca referenciar Carousel.
- `TabRole.prominent` OS 27 — omitir inteiramente do Cosmos 26.
- `tabBarMinimizeBehavior` all-5 em iOS 26 — verificar no-op/ignored em tvOS/watchOS onde não há bar minimizable.
- Verificar init `TabContentBuilder` compila limpo em todas as 5 com zero warnings de concorrência (`TabView` é `~Swift.Sendable`; `TabContent` é `@preconcurrency @MainActor`).