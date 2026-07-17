---
tags: [risk, atom]
aliases: [Itens Refutados, Refuted Spec Items]
related: [[Verificação Adversarial]], [[Riscos Abertos]]
---

# Itens Refutados (correções de spec)

> Specs que a [[Verificação Adversarial]] refutou e já foram corrigidas no `PHASE2.md`. **Re-confirmar durante implementação — não recair nelas.**

| # | Claim original (errada) | Verdade verificada | Onde importa |
|---|---|---|---|
| 1 | Slider `.tint<S>(_:)` ShapeStyle overload é iOS 15.0+ | É **iOS 16.0+** | [[Cosmos Slider]] — gate do overload ShapeStyle |
| 2 | Slider `.sensoryFeedback` é tvOS-unavailable | **É available em tvOS 17.0** | Moot p/ CosmosSlider (gated `#if !os(tvOS)`) — mas não assumir tvOS-unavailability alhures |
| 3 | `InsetGroupedListStyle` é visionOS-unavailable | **É visionOS-available** em Xcode 27 (claim antiga outdated) | [[Cosmos List]] — não over-excluir visionOS |
| 4 | `MenuActionDismissBehavior.disabled` é tvOS-exclusive | **NÃO** — também available em iOS 16.4+/visionOS 1.0+ (unavailable macOS/watchOS) | [[Cosmos Menu]] |
| 5 | `PalettePickerStyle` unavailable em visionOS | **É available em visionOS via `*`** wildcard | [[Cosmos Picker]] — não gatear `.palette` com `#if !os(visionOS)` |
| 6 | `ButtonToggleStyle` unavailable em visionOS | **É available em visionOS desde 1.0** (sem `@available` restriction) | [[Cosmos Toggle]] |

## Lição

Estas são exatamente o tipo de surpresa de SDK que o workflow ([[Phase 2 Research Workflow]]) existe para pegar. A regra de ouro: **`PickerStyle`/`ListStyle`/`TabViewStyle` são native-bridged/opacos — não tente conformar um struct Cosmos custom** ([[ADR Style Protocol or Wrap]]). E **não over-excluir visionOS** sem checar a wildcard `*` na interface.