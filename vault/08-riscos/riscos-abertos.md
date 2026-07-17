---
tags: [risk, atom, platform]
aliases: [Riscos Abertos, Open Risks, TODOs]
related: [[Átomos Overview]], [[Plataforma Guards]]
---

# Riscos Abertos & TODOs

> Fonte: `PHASE2.md` §6. Agregado para re-verificação por plataforma (iOS/macOS/tvOS/watchOS/visionOS) em CI.

## Low-tier atoms
- **Label** — verificar iOS 26 `.labelReservedIconWidth`/`.labelIconToTitleSpacing` renderizam em telas pequenas watchOS/tvOS (declarados available — confirmar em `#Preview`); `LabelStyle` `@preconcurrency @MainActor` — manter `Sendable`, zero warnings Swift 6.
- **Progress** — `makeBody` custom perde trait `updatesFrequently` — re-aplicar a11y; `fractionCompleted` `Double?` — nunca force-unwrap; `Progress` `@MainActor`-bound — instâncias do call site isoladas.
- **Divider** — overlay cobre o hairline confiavelmente; availability visionOS em runtime (quirk pre-visionOS-symbol — compila/roda em visionOS 1.0+, verificar); quirks de render em watchOS/tvOS.
- **Icon** — a11y de SF Symbol (sempre `.accessibilityLabel`/`.accessibilityHidden`); documentar template-mode; `.allowedDynamicRange` watchOS-unavailable — verificar compile.
- **Link** — isolation MainActor limpo Swift 6; watchOS openURL pode ser no-op; nunca wire `LinkButtonStyle` como style de Link.

## Medium style-protocol com guards
- **GroupBox** — fallback tvOS/watchOS compila sem referenciar símbolos GroupBox; `GroupBoxStyle` `@MainActor @preconcurrency` — `~Swift.Sendable`, `makeBody` MainActor; não expor `init(label:content:)` deprecated.
- **Menu** — `MenuStyle` `@preconcurrency @MainActor` — zero warnings; Label/Content opaco — nunca decompor; `primaryAction` `@Sendable`-friendly; `.glassProminent` availability no target; **não** `.glassEffect` no popover content.
- **DatePicker** — matriz por style — guard cada style com `#if os()` AND `#available`; visionOS renderiza; `makeBody` custom compila/roda watchOS 10; setter `configuration.selection` iOS 16/macOS 13/watchOS 10; default resolve `.automatic` (não `.graphical`) em watchOS; `.selection` não double-fire em wheel scroll (debounce por selection change).

## Medium opaque/wrap-view com guards
- **TextField group** — `.bordered` `@available(anyAppleOS 27.0)` = OS 26 — gate + fallback; TextEditor guarded compila stub no-op tvOS/watchOS ou omite; SecureField sem style protocol — `.textFieldStyle` no-op; `ToggleSecureTextButton`/`SecureFieldVisibility`/`toggleSecureEntry` — ZERO hits macOS/visionOS — localizar no SDK iOS/visionOS antes de confiar; inits visionOS 1.0/2.0.
- **Slider** — arquivo inteiro `#if !os(tvOS)`; não criar `CosmosSliderStyle`; só inits label-first; `step` `V.Stride` (BinaryFloatingPoint); watchOS preview (`.controlSize(.mini)`); não animar binding por frame; `.tint<S>(_:)` ShapeStyle é iOS 16.0+ (não 15.0+); `.sensoryFeedback` available tvOS 17.0 (moot aqui, não assumir tvOS-unavailable alhures).
- **Stepper** — tvOS ausência tipo-level — guard átomo + API; watchOS floor 9.0; inits label-first não-deprecated; double-haptic só no fallback tvOS; format inits requerem `BinaryFloatingPoint` (não Int); `onEditingChanged` plumbed.

## Medium wrap-view, sem guard, fragmentação pesada (maior risco)
- **Section** — não setar próprio background/inset/separators; `isExpanded` requer `Footer == EmptyView`; não over-excluir visionOS (`listSectionSpacing`/`listSectionSeparator` visionOS-available); primitivo — previews wrap em List/Form; title-key/LocalizedStringResource forçam `Parent == Text`, `Footer == EmptyView`.
- **Picker** — `PickerStyle` native-bridged — não tentar custom; fragmentação por style (`.segmented`/`.menu` watchOS-unavailable, `.wheel` macOS/tvOS-unavailable, `.radioGroup` macOS-only, `.palette` tvOS/watchOS-unavailable **mas visionOS via `*`** — não gatear visionOS, `.navigationLink` macOS-unavailable, `.menu` tvOS 17); `TabsPickerStyle` OS 27 — não expor; `PopUpButtonPickerStyle` deprecated — usar `.menu`; verificar tvOS focus + `.tint`; não aplicar `.cosmosAnimation(.valueChange, value: selection)` no Picker (desyncs) — só em conteúdo dependente.
- **List** — não tentar `ListStyle` custom; `InsetGroupedListStyle` visionOS-available em Xcode 27 (claim antiga outdated); Set-based selection watchOS-unavailable — branch/drop; hierarchical `children:` tvOS+watchOS unavailable; `listSectionSpacing` iOS/watchOS/visionOS (não over-excluir visionOS); `listSectionMargins` iOS 26/visionOS 26; `swipeActions` tvOS-unavailable; `refreshable` system-controlled — não double-gate; `.listStyle(.automatic)` default nas 5; row identity stability (IDs estáveis, sem `if/else` recreation).
- **TabView** — divergência per-style por plataforma (cada um `#if os(...)` dentro, não guard atom-level); `TabViewStyle` não conformable — wrap; legacy `init(selection: Binding?, @ViewBuilder content:)` + `.tabItem` deprecated — viola zero-warnings; `CarouselTabViewStyle` deprecated → `VerticalPageTabViewStyle` (nunca Carousel); `TabRole.prominent` OS 27 — omitir; `tabBarMinimizeBehavior` all-5 iOS 26 — no-op/ignored em tvOS/watchOS; `TabContentBuilder` compila limpo nas 5 com zero warnings (`TabView` `~Swift.Sendable`, `TabContent` `@preconcurrency @MainActor`).

> Itens de spec já refutados/corrigidos → [[Itens Refutados]] (não recair).