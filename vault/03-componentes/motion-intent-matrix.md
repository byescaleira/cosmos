---
tags: [atom, motion]
aliases: [Motion Intent Matrix, Matriz de Motion]
related: [[Motion Subsystem]], [[Átomos Overview]], [[Reduce Motion Policy]]
---

# Motion Intent Matrix

> Fonte: `PHASE2.md` §3. Vocabulário: `press`, `appear`, `disappear`, `valueChange`, `tabSwitch`, `sheet`, `focus`, `containerTransform`, `listInsert`, `listRemove`, `none`.

| Átomo | `CosmosMotionKind` | Racional | Reduce-motion |
|---|---|---|---|
| [[Cosmos Label]] | none | Display estático | n/a; `symbolEffect` no ícone gate em `isEnabled` only (auto-respeita RM) |
| [[Cosmos Progress]] | valueChange (determinate); appear/disappear (lifecycle) | Fill é mutação de valor; aparece quando loading começa | Spinner indeterminate é loop contínuo — suprimir a menos que seja sinal único (`.preserve`); senão `.substitute`. NÃO double-gate do spinner nativo |
| [[Cosmos Toggle]] | valueChange | Flip binário de thumb/fill | `.substitute` (espacial → crossfade/snap) via `CosmosMotionPolicy`, não env cru. Suprimir Cosmos motion quando delega pra `.switch` (thumb nativo não é SwiftUI-driven — evita double anim) |
| [[Cosmos Divider]] | none | Estático | Motion container-driven (`.cosmosTransition(.sheet)`/listInsert/listRemove); um `withAnimation`, não por-divider |
| [[Cosmos Icon]] | none | Display estático | `symbolEffect` caller-driven, gate `isEnabled` only; loop contínuo suprimido a menos que sinal único (`.preserve`) |
| [[Cosmos Link]] | none | Controle estático, URL-driven | `symbolEffect` do label auto-respeita RM; gate `isEnabled` only |
| [[Cosmos GroupBox]] | none | Container estático | Style custom pode add `.cosmosTransition(.containerTransform)` (caller-driven); `matchedGeometry` single `@Namespace`/`isSource`/`withAnimation` |
| [[Cosmos Menu]] | press | Press do trigger é o motion Cosmos-relevante | `.cosmosAnimation(.press, value:)` via tokens; popover é system-controlled e auto-respeita RM — NÃO gatear do Cosmos |
| [[Cosmos DatePicker]] | valueChange | Seleção de data/hora é mutação de valor | `.cosmosContentTransition(.numericText())` no compact/field; wheel/graphical + popover são system-native — NÃO double-gate |
| [[Cosmos TextField]] group | focus | Transição de focus-state (border/background) | `.substitute` (crossfade) ou `.instant`; NÃO bindar `valueChange` no text binding (dispara por keystroke — vestibular-hostile) |
| [[Cosmos Slider]] | valueChange (primário); press (drag-begin thumb scale) | Drag contínuo move thumb + tint fill | Drag é gesture-tracked (NÃO Cosmos-driven) — NÃO wrapar o binding em `withAnimation` por frame. Tint crossfade snapa pra instant sob `.substitute`; press-scale suprimido. Thumb tracking = motion-as-sole-signal (`.preserve`, WCAG 2.3.3 exempt) |
| [[Cosmos Stepper]] | valueChange | Mutação escalar discreta por step | `.substitute`/`.instant` → crossfade/snap do texto de valor; single `.cosmosAnimation(.valueChange, value:)` |
| [[Cosmos Section]] | none | Primitivo estrutural; expand/collapse nativo | NÃO layer `.cosmosAnimation` em disclosure nativo (desyncs). Caller wrapa `isExpanded` num single `withAnimation(theme.motion.spring(for: .containerTransform))` |
| [[Cosmos Picker]] | valueChange | Mudança do binding de selection | Aplicar `.cosmosAnimation(.valueChange, value: selection)` SÓ em conteúdo reativo, NUNCA no Picker (animação de selection nativa é system-driven; curva diferente desyncs) |
| [[Cosmos List]] | listInsert/listRemove (row lifecycle); valueChange (selection); containerTransform (matchedGeometry) | Listas = inserção/remoção/reordenação | Single `withAnimation(theme.motion.spring(for: .listInsert))` por mudança coordenada; `matchedGeometryEffect` single `@Namespace`/`isSource`/um `withAnimation`. `.refreshable` spinner system-controlled — NÃO double-gate |
| [[Cosmos TabView]] | tabSwitch | Selection swapa conteúdo exibido | Single `withAnimation` no write do selection, não per-view `.animation(_:value:)` (desyncs). PageTabViewStyle swipe = paging nativo — system handle RM. Symbol effects nos ícones gate `isEnabled` only |