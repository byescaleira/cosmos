---
tags: [platform, cross-cutting]
aliases: [Plataforma Guards, Platform Guards, Guard Reference]
related: [[Versionamento]], [[Átomos Overview]]
---

# Plataforma — Guards & Disponibilidade

> Fonte: `PHASE2.md` §4. Matriz `#if os()` + fallback + `#available` por átomo. Centralize `if #available` gates ([[Versionamento]]).

| Átomo | `#if os()` guard | Fallback em ausência | Runtime `#available` |
|---|---|---|---|
| [[Cosmos Label]] | none | n/a | none no floor (comment iOS 16/17/26 + 14.5 origins p/ floor-lowering) |
| [[Cosmos Progress]] | none | n/a | none no floor |
| [[Cosmos Toggle]] | none | n/a | none (comment `isMixed` iOS 16) |
| [[Cosmos Divider]] | none | n/a | none |
| [[Cosmos Icon]] | `#if !os(watchOS)` p/ `.allowedDynamicRange`/`DynamicRange` only | n/a | none (comment iOS 15/16/17/26) |
| [[Cosmos Link]] | none | n/a | `OpenURLAction.Result.systemAction(_:prefersInApp:)` iOS 26+ (gate central se exposto) |
| [[Cosmos GroupBox]] | `#if !os(tvOS) && !os(watchOS)` | Plain: label `Text` header acima do content em `VStack` com theme padding/typography (sem chrome); API pública uniforme atrás do guard | none |
| [[Cosmos Menu]] | `#if !os(watchOS)` | watchOS: `CosmosButton` (ou `CosmosPicker`/overflow Sheet) | none (tvOS floor 17 — comment) |
| [[Cosmos DatePicker]] | `#if !os(tvOS)` (tipo-level) | tvOS: ausência compile-time; app-level escolhe `CosmosPicker` ou date chooser custom | none (watchOS floor 10.0; `.hourMinuteAndSecond` é `#if os(watchOS)` compile-time, não `#available`) |
| [[Cosmos TextField]] | none | n/a | `.bordered` `#available(iOS 26, ...)` — gate, fallback `.automatic`/`.plain` abaixo de 26; selection init iOS 18/macOS 15/visionOS 2 (tvOS/watchOS unavailable); AttributedString TextEditor init iOS 26/macOS 26/visionOS 26 |
| [[Cosmos SecureField]] | none | n/a | `.bordered` gate (shared); `.textFieldStyle(_:)` efetivamente no-op |
| [[Cosmos TextEditor]] | `#if !os(tvOS) && !os(watchOS)` (visionOS intentionally NOT guarded) | tvOS/watchOS: ausência compile-time; callers usam `TextField(...axis: .vertical)` (tvOS 16/watchOS 9) ou `CosmosScrollView`+Text | none p/ base; AttributedString init iOS 26/macOS 26/visionOS 26 |
| [[Cosmos Slider]] | `#if !os(tvOS)` (átomo inteiro + API referenciante) | tvOS: nada renderiza (arquivo excluído); documentar tvOS apps usam Stepper/Picker | none p/ base; cluster iOS 26 ticks/neutralValue/enabledBounds/currentValueLabel `@available(iOS 26.../watchOS 26/visionOS 26)` — manter em cluster `.v26`-only p/ floor-lowering |
| [[Cosmos Stepper]] | `#if !os(tvOS)` (átomo inteiro + API referenciante) | tvOS: par `CosmosButton` +/- (mesmo `Binding`) dentro de `#if os(tvOS) ... #else (real Stepper) #endif` | none (watchOS floor 9.0) |
| [[Cosmos Section]] | none (tipo); per-modifier guards | n/a | per-modifier: `.listSectionSpacing` iOS 17/watchOS 10 (macOS/tvOS unavailable, visionOS available); `.listSectionSeparator`/`.listRowSeparator` iOS 15/macOS 13 (tvOS/watchOS unavailable, visionOS available); `.sectionActions` iOS 18/macOS 15/visionOS 2 (tvOS/watchOS unavailable); `.listSectionMargins` iOS 26/visionOS 26 (macOS/tvOS/watchOS unavailable) |
| [[Cosmos Picker]] | none (Picker em todas as 5 via `*`) | Per-style fallback pra `.automatic` quando style unavailable | `.menu` precisa tvOS 17; `.sensoryFeedback` iOS 17/macOS 14/tvOS 17/watchOS 10/visionOS 26 |
| [[Cosmos List]] | none (tipo); per-style/per-modifier guards | Per-style fallback `.automatic`/`.plain` quando unavailable; per-modifier no-op em plataformas truly-unavailable (NÃO over-excluir visionOS) | `.listSectionSpacing` iOS 17/watchOS 10/visionOS (macOS/tvOS unavailable); `.listSectionMargins` iOS 26/visionOS 26; `.listRowSeparator`/`.listSectionSeparator` iOS 15/macOS 13/visionOS (tvOS/watchOS unavailable); `.swipeActions` iOS 15/macOS 12/watchOS 8/visionOS (tvOS unavailable); `.sectionActions` iOS 18/macOS 15/visionOS 2 (tvOS/watchOS unavailable) |
| [[Cosmos TabView]] | none (átomo); per-style `#if os()` dentro | Per-style: macOS `.page`→`.automatic`; watchOS `.sidebarAdaptable`/`.tabBarOnly`→`.page`/`.verticalPage`; tvOS/watchOS `.tabViewCustomization`→none | `tabBarMinimizeBehavior` all-5 iOS 26; `tabViewBottomAccessory` iOS 26.0/26.1 (iOS-only); `TabRole.prominent` OS 27 — omitir inteiramente do Cosmos 26 |

## Gates runtime centralizados no baseline Cosmos 26

`BorderedTextFieldStyle`/`.bordered` + `.textInputBorderShape(.roundedRectangle)` (OS 26); `tabBarMinimizeBehavior`/`tabViewBottomAccessory` (OS 26); AttributedString TextEditor init (OS 26); `labelReservedIconWidth`/`labelIconToTitleSpacing` (OS 26); `symbolVariableValueMode`/`symbolColorRenderingMode` (OS 26); `OpenURLAction.Result.systemAction(_:prefersInApp:)` (OS 26); cluster iOS 26 Slider ticks/neutralValue/enabledBounds/currentValueLabel; `listSectionMargins` (iOS 26/visionOS 26); `.hourMinuteAndSecond` (`#if os(watchOS)` compile-time, não runtime). Todos os outros features estão abaixo do floor. `GlassEffectTransition.matchedGeometry` (iOS 26) só gated se o floor baixar.