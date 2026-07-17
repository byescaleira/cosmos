---
tags: [atom, wave-e]
tier: medium
pattern: wrap-view
guard: none (Picker em todas as 5 via *)
aliases: [CosmosPicker, Cosmos Picker]
related: [[Átomos Overview]], [[Plataforma Guards]], [[Itens Refutados]]
---

# Cosmos Picker

> Wave E · wrap-view (`PickerStyle` é OPAQUE/native-bridged — sem `makeBody`, sem `Configuration` associatedtype; struct Cosmos NÃO pode conformar de forma útil) · sem guard · `.menu` precisa tvOS 17

## Pattern & surface
Wrap-view. `.pickerStyle(_:)` com built-ins `.automatic`/`.menu`/`.segmented`/`.wheel`/`.inline`/`.palette`/`.navigationLink`/`.radioGroup` (cada um platform-gated — ver [[Plataforma Guards]]). `.tint(_:)` (iOS 15+, color selection accent em segmented/menu). `.disabled`/`.labelsHidden`. Content closure per-option + `.tag(_:)`/`.tags(_:)`. `.accessibilityLabel/Value/Hint/Identifier`. `.onChange(of: selection)` p/ observar p/ haptics+tracking. Label forms (Text titleKey, StringProtocol, Label<Text,Image> com systemImage).

## Inits a expor
`init(_ titleKey:, selection:, @ViewBuilder content:)`, `init<S>(_ title:, selection:, @ViewBuilder content:)`, `init(selection:, @ViewBuilder content:, @ViewBuilder label:)`, `init(_ titleKey:, systemImage:, selection:, @ViewBuilder content:)` (iOS 14+). Opcionalmente currentValueLabel inits iOS 18+ só se precisar. **NÃO** expor `.tabs` (`TabsPickerStyle` é iOS 27/macOS 27/tvOS 27/visionOS 27 — ACIMA do baseline Cosmos 26).

## Customization limits
Sem path de customização-via-protocol — Cosmos **DEVE** wrapar um View que configura um `Picker` nativo e aplica um style built-in. Não pode customizar chrome de wheel/segment/menu, layout de option-row além da content closure, placeholder (Picker não tem), ou clear button. Disponibilidade por style é altamente fragmentada. Um `CosmosPickerStyle` enum exposto a consumidores **DEVE** mapear pra um style safe por plataforma ou cair pra `.automatic` — nunca forward cego um style escolhido pelo user.

## Cross-cutting
- **A11y:** Picker é focusable; `label` arg vira o label VoiceOver. VoiceOver anuncia a selection atual (option tagged) como value; mirror via `.accessibilityValue(_:)` setado pro label do option selecionado p/ controle explícito. `.accessibilityHint`. `.accessibilityIdentifier` p/ tracking. Dynamic Type escala label/per-option Text. **NÃO** add `.isButton` manualmente (style nativo seta traits apropriados).
- **Haptics:** `.sensoryFeedback(.selection, trigger: selection)` gateado via `CosmosHapticsPolicy` usando `config.haptics` + `accessibilityReduceMotion`. No-op em plataformas sem hardware haptic (safe aplicar incondicionalmente).
- **Motion:** `valueChange` — mudança do binding de selection É uma value change. Aplicar `.cosmosAnimation(.valueChange, value: selection)` SÓ em conteúdo reativo ao redor, **NÃO** no próprio Picker (sua anim de selection nativa — wheel spin, segment slide, menu highlight — é system-driven e não deve ser override com curva diferente, que desyncs). Reservar `tabSwitch` para [[Cosmos TabView]].

## Key modifiers
`.pickerStyle` (gated por plataforma), `.tint`, `.tags`/`.tag`, `.labelsHidden`, `.disabled`, `.onChange(of: selection)`, `.accessibilityLabel/Value/Hint/Identifier`, `.sensoryFeedback(.selection, trigger:)` (gated).

## Riscos / TODOs
- `PickerStyle` é native-bridged — **NÃO** tentar `CosmosPickerStyle` custom (maior surpresa de API).
- Fragmentação por style: `.segmented`/`.menu` watchOS-unavailable, `.wheel` macOS/tvOS-unavailable, `.radioGroup` macOS-only (visionOS-unavailable), `.palette` tvOS/watchOS-unavailable **mas visionOS-available via `*`** (NÃO gatear visionOS out), `.navigationLink` macOS-unavailable, `.menu` precisa tvOS 17.
- `TabsPickerStyle` é OS 27 — **NÃO** expor.
- `PopUpButtonPickerStyle` macOS-only deprecated — usar `.menu`.
- Default style difere por plataforma (macOS ≈ menu, iOS ≈ menu, watchOS ≈ wheel/list, tvOS ≈ ?) — documentar.
- Verificar tvOS focus-engine + `.tint` em `#Preview`.