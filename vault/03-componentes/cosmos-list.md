---
tags: [atom, wave-e]
tier: medium
pattern: wrap-view
guard: none (tipo); per-style/per-modifier guards
aliases: [CosmosList, Cosmos List]
related: [[Átomos Overview]], [[Plataforma Guards]], [[Itens Refutados]]
---

# Cosmos List

> Wave E · wrap-view (`ListStyle` é OPAQUE — só `_makeView`/`_makeViewList`, sem `makeBody`) · sem guard no tipo · per-modifier guards

## Pattern & surface
Wrap-view. `.listStyle(_:)` seleciona `ListStyle` built-in (SE-0299): `.automatic`/`.plain` (all 5), `.grouped` (iOS/tvOS/visionOS), `.inset`/`.insetGrouped`/`.sidebar` (iOS/macOS/visionOS; `.insetGrouped` é iOS/visionOS em Xcode 27 — **NÃO** visionOS-unavailable, corrigindo spec antigo), `.elliptical`/`.carousel` (watchOS-only), `.bordered` (macOS-only). Row/section modifiers: `.listRowSeparator`/`.listRowSeparatorTint`/`.listSectionSeparator`/`.listSectionSeparatorTint` (iOS 15+/macOS 13+, tvOS/watchOS unavailable, visionOS available), `.listSectionSpacing(_:)` (iOS 17+/watchOS 10+, macOS/tvOS unavailable, visionOS available — NÃO visionOS-unavailable), `.listSectionMargins(_:_:)` (iOS 26+/visionOS 26+, macOS/tvOS/watchOS unavailable), `.swipeActions(edge:allowsFullSwipe:content:)` (iOS 15+/macOS 12+/watchOS 8+, tvOS unavailable, visionOS available), `.refreshable(action:)` (iOS 15+/macOS 12+/tvOS 15+/watchOS 8), `.sectionActions(content:)` (iOS 18+/macOS 15+/visionOS 2+, tvOS/watchOS unavailable), `.listRowInsets`, `.listRowBackground`, `.headerProminence`, `.environment(\.defaultMinListRowHeight)`.

## Inits a expor
`init(@ContentBuilder content:)` (universal, SelectionValue == Never — primário), `init<Data, RowContent>(_ data:, @ContentBuilder rowContent:)` (Identifiable), `init<Data, ID, RowContent>(_ data:, id:, @ContentBuilder rowContent:)`, `init<RowContent>(_ data: Range<Int>, @ContentBuilder rowContent:)`. Selection-bearing inits só se expondo variante selecionável — guard watchOS (`Set` watchOS-unavailable; optional single watchOS 10+; non-optional single macOS 13 only — **NÃO** expor o init macOS-only non-optional).

## Customization limits
`ListStyle` opaco — não dá sintetizar renderer de lista wholly custom. Set-based selection init watchOS-unavailable; non-optional single-value selection macOS 13 only. Hierarchical/outline `children:` inits tvOS+watchOS unavailable. Row background/separator tint colors são `Color?` (sem UIKit). `.swipeActions` tvOS-unavailable. Sem customização de row touch/response sem UIKit. Sem curva de anim de row height custom (usar tokens).

## Cross-cutting
- **A11y:** List é anunciada como lista com rows navegáveis; selection via binding. `.accessibilityLabel`/`.accessibilityHint`/`.accessibilityIdentifier` por row; rows selecionáveis get `.accessibilityAddTraits(.isButton)` (+ `.isSelected` quando bound). Section headers/footers anunciados on scroll-into. Dynamic Type reflui rows; passar `Font.custom(_:size:relativeTo:)` dentro das rows. `.swipeActions` buttons hoisted como row accessibility actions automaticamente. Focus/scroll position sobrevive ao reflow se row identity for estável (`ForEach(data:id:)` com IDs estáveis; evitar `if/else` que recria identity).
- **Haptics:** List própria não owna. `.sensoryFeedback(.selection, trigger: selectionBinding)` em selection change; `.impact(weight: .light)` em reorder drop ou swipe-action commit. Gateado por `config.haptics` + `accessibilityReduceMotion` via `CosmosHapticsPolicy`. No-op onde não há hardware.
- **Motion:** `listInsert`/`listRemove` p/ row lifecycle (via `ForEach` + `.cosmosAnimation(.listInsert, value: dataIDs)` / `.cosmosTransition`/`.cosmosContentTransition` no row content), `valueChange` quando selection binding muta, `containerTransform` se `matchedGeometryEffect` usado p/ detail expansion. A List container em si não tem motion inerente.

## Key modifiers
`.listStyle`, `.listSectionSpacing` (guard), `.listSectionMargins` (guard), `.listRowSeparator`/`.listSectionSeparator` + Tints (guard), `.swipeActions(edge:allowsFullSwipe:content:)` (guard), `.refreshable`, `.sectionActions(content:)` (guard), `.listRowInsets`/`.listRowBackground`/`.headerProminence`, `.environment(\.defaultMinListRowHeight)`/`.environment(\.listSectionSpacing)`, `.cosmosAnimation(.listInsert/.listRemove, value:)` no `ForEach` que drive row lifecycle.

## Riscos / TODOs
- **NÃO** tentar struct `ListStyle` custom-conforming.
- Verificar `InsetGroupedListStyle` é visionOS-available em Xcode 27 (claim antiga "visionOS-unavailable" é outdated — [[Itens Refutados]]).
- Set-based selection init watchOS-unavailable — branch ou drop selection em watchOS.
- Hierarchical `children:` inits tvOS+watchOS unavailable.
- `listSectionSpacing` available em iOS/watchOS/visionOS (NÃO over-excluir visionOS).
- `listSectionMargins` iOS 26/visionOS 26 only.
- `swipeActions` tvOS-unavailable — guard ou silently drop em tvOS.
- `refreshable` spinner é system-controlled e respeita reduce-motion — confirmar `CosmosMotionPolicy` não double-gate.
- Verificar `.listStyle(.automatic)` default renderiza sensatamente em todas as 5.
- Row identity stability no reflow — IDs estáveis, sem `if/else` identity recreation (verificar em previews Dynamic Type + landscape).