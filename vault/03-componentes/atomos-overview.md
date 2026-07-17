---
tags: [atom, moc]
aliases: [Átomos Overview, Build Order, Waves]
related: [[Home]], [[Motion Intent Matrix]], [[Checklist de Integração]], [[Plataforma Guards]]
---

# Átomos — Overview & Ordem de Build

> Fonte: `PHASE2.md` §1. A pesquisa de cada átomo foi feita contra Apple docs + Xcode 27 SDK interface e **adversarialmente verificada** ([[Phase 2 Research Workflow]]).

Risco = 3 eixos: (a) **style-protocol vs wrap-view**; (b) **complexidade do guard de plataforma** (sem guard < guards `#if os()` + fallbacks < runtime `#available`); (c) **fragmentação de styles built-in** (Picker/List/TabView têm matrices de disponibilidade selvagens por plataforma).

## Ondas (low-risk style-protocol → high-risk platform-fragile)

### Wave A — low-tier, style-protocol, sem guard
Valida o plumbing de motion/haptics/tracking.
1. [[Cosmos Label]] (`LabelStyle`) — display estático, sem motion/haptics; style-protocol mais puro.
2. [[Cosmos Progress]] (`ProgressViewStyle`) — display passivo; indeterminate-vs-determinate; valida reduce-motion de loop contínuo.
3. [[Cosmos Toggle]] (`ToggleStyle`) — primeiro interativo; valida re-aplicação de a11y em style custom + haptics + `valueChange`.

### Wave B — low-tier, wrap-view, sem guard
Valida o pattern wrap-view + disciplina de zero-customização.
4. [[Cosmos Divider]] — leaf primitivo, a11y decorativo; wrap-view mais simples.
5. [[Cosmos Icon]] (`Image`) — grande superfície de modifiers, sem style protocol; valida split a11y label vs decorativo.
6. [[Cosmos Link]] — URL-driven, intercept `.openURL`; valida routing behavior via env.

### Wave C — medium-tier, style-protocol com guards
Valida disciplina de fallback.
7. [[Cosmos GroupBox]] (`#if !os(tvOS) && !os(watchOS)`) — único style built-in; 1º fallback view.
8. [[Cosmos Menu]] (`#if !os(watchOS)`) — `MenuStyle` conformable; primaryAction + fallback watchOS.
9. [[Cosmos DatePicker]] (`#if !os(tvOS)`) — `DatePickerStyle` conformable; matriz de disponibilidade severa por style; watchOS floor 10.

### Wave D — medium-tier, opaque style-protocol / wrap-view com guards
10. [[Cosmos TextField]] group (TextFieldStyle opaco `_body` + SecureField wrap + TextEditor `#if !os(tvOS) && !os(watchOS)`) — 3 átomos coordenados; guards keyboard `#if os(iOS) || os(tvOS)`; gate `.bordered` iOS 26.
11. [[Cosmos Slider]] (`#if !os(tvOS)`) — sem SliderStyle; wrap-view; cluster iOS 26 ticks/neutralValue.
12. [[Cosmos Stepper]] (`#if !os(tvOS)`) — sem StepperStyle; fallback Button-pair tvOS; risco double-haptic nativo.

### Wave E — medium-tier, wrap-view, sem guard, fragmentação pesada (maior risco de integração)
13. [[Cosmos Section]] (wrap-view, sem guard) — primitivo; aparência determinada pelo List/Form envolvente; matriz de guards de modifier.
14. [[Cosmos Picker]] (wrap-view, sem guard) — `PickerStyle` opaco/não-conformable; fragmentação severa; `.tabs` é acima do baseline Cosmos 26 (NÃO expor).
15. [[Cosmos List]] (wrap-view, sem guard) — `ListStyle` opaco; selection-init branching watchOS; muitos guards; disciplina de row-identity.
16. [[Cosmos TabView]] (wrap-view, sem guard) — `TabViewStyle` opaco; `TabContentBuilder` moderno + legacy deprecated; guards `#if os()` por style dentro do átomo; `.prominent` é OS 27 (excluir).

## Racional

Wave A prova o plumbing style-protocol nos átomos mais fáceis; Wave B prova a disciplina wrap-view sem branching de plataforma; Waves C–D introduzem guards `#if os()` e gates `#available` um de cada vez; Wave E fica por último porque a matriz de fragmentação de styles é a maior fonte de risco de compile por plataforma e se beneficia de todos os patterns anteriores estabilizados.

## Status de entrega

- **Entregue**: A, B, C, D ([[Changelog Resumo]]).
- **Pendente**: Wave E (Section, Picker, List, TabView).

## Ver também

- [[Motion Intent Matrix]] — átomo → `CosmosMotionKind`.
- [[Checklist de Integração]] — 11 itens por átomo.
- [[Plataforma Guards]] — matriz guard + fallback + `#available` por átomo.
- [[Riscos Abertos]] — TODOs de verificação por plataforma.
- [[Itens Refutados]] — correções de spec já aplicadas.