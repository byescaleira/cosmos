---
tags: [adr, atom]
aliases: [ADR Style Protocol or Wrap]
related: [[Átomos Overview]], [[Arquitetura Cosmos]]
---

# ADR — Style protocol quando conformable, wrap `View` caso contrário

> 2026-07-16 · Decided

**Decisão.** Honra a superfície real de customização de cada componente.
- **Com style protocol conformable** (`ButtonStyle`, `ToggleStyle`, `LabelStyle`, `ProgressViewStyle`, `GroupBoxStyle`, `MenuStyle`) → usa o protocolo + SE-0299 dot-syntax (`where Self ==`).
- **Sem style protocol** (Slider, Stepper, TextField/SecureField/TextEditor, DatePicker, Picker, List, Section, TabView, Divider, Image, Link, Spacer) → wrapa um `View`.

**Caveat.** Alguns "style protocols" são **opacos/native-bridged** (não conformable de forma útil): `PickerStyle`, `ListStyle`, `TabViewStyle`, `TextFieldStyle` (via SPI `_body`). Nesses casos o Cosmos struct **não pode** customizar o rendering — só wrap e aplicar styles built-in. Não tente criar `CosmosPickerStyle`/`CosmosListStyle`/`CosmosTabViewStyle` conformable. → maior surpresa de API (ver [[Cosmos Picker]], [[Cosmos List]], [[Cosmos TabView]], [[Itens Refutados]]).

> Detalhe por átomo: pattern + guard em [[Átomos Overview]] e na nota de cada átomo.