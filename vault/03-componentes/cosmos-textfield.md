---
tags: [atom, wave-d]
tier: medium
pattern: style-protocol (opaque) + wrap-view
guard: "#if !os(tvOS) && !os(watchOS) para TextEditor/TextEditorStyle"
aliases: [CosmosTextField, CosmosSecureField, CosmosTextEditor, TextField group, Cosmos TextField, Cosmos SecureField, Cosmos TextEditor]
related: [[Átomos Overview]], [[Plataforma Guards]]
---

# Cosmos TextField + SecureField + TextEditor

> Wave D · grupo de 3 átomos coordenados · gates `.bordered` OS 26 · keyboard guards `#if os(iOS) || os(tvOS)`

## Patterns
- **TextField/SecureField** — style-protocol via `TextFieldStyle` (opaque `_body` pattern, `@_opaqueReturnTypeOf`).
- **TextEditor** — `TextEditorStyle` (iOS 17+/macOS 14+/visionOS 1+; Configuration struct **vazio** — provavelmente expor modifiers only, não style custom). Guard `#if !os(tvOS) && !os(watchOS)` para TextEditor + TextEditorStyle + Configuration. TextField/SecureField sem guard (visionOS intentionally NOT guarded).

## Runtime `#available`
`.bordered` (`BorderedTextFieldStyle`, `@available(anyAppleOS 27.0)` = OS 26) — gate; `.roundedBorder` deprecated (NÃO usar; non-deprecated em visionOS via `*` mas evitar p/ consistência); selection init iOS 18/macOS 15/visionOS 2 (tvOS/watchOS unavailable); AttributedString TextEditor init iOS 26/macOS 26/visionOS 26.

## Inits a expor
- **TextField:** `init(_ titleKey:, text:)`, `init(_ titleKey:, text:, prompt: Text?)` (iOS 15+), `init(_ titleKey:, text:, axis: Axis)` (iOS 16+), `init(text:, prompt:, axis:, @ViewBuilder label:)` (iOS 16+).
- **SecureField:** `init(_ titleKey:, text:)`, `init(_ titleKey:, text:, prompt: Text?)` (iOS 15+), `init(text:, prompt:, @ViewBuilder label:)` (iOS 15+).
- **TextEditor:** `init(text: Binding<String>)` (guarded).

## Customization surface
`CosmosTextFieldStyle : TextFieldStyle` com `_body(configuration: TextField<Self._Label>)` — wrap com padding/background(.ultraThinMaterial)/overlay/border/clipShape. Built-ins `.automatic` (Default), `.plain` (Plain), `.bordered` (Bordered, OS 26). Modifiers: `.textFieldStyle`, `.tint`, `.font`, `.foregroundStyle`, `prompt: Text?`, `.keyboardType` (`#if os(iOS) || os(tvOS)`), `.textContentType`, `.textInputAutocapitalization` (`#if os(iOS) || os(tvOS)`), `.autocorrectionDisabled`, `.submitLabel` (all 5, no guard; no-op sem submit keyboard), `.focused`/`.focused(_:equals:)`, `.lineLimit`, `axis: .vertical`, `.onSubmit(of:)`, `.textInputBorderShape(.roundedRectangle)` (iOS 26). TextEditor: `.textEditorStyle(_:)` (guarded).

## Customization limits
`TextFieldStyle._Body` opaco; `_Label` tem `Body == Never` — não pode ler o text binding, não pode recolor placeholder direto (só via styling `prompt: Text`), não pode add/remove/inspect o clear button nativo, não pode substituir o inner text field nativo. SecureField **NÃO** tem style protocol conformable — `.textFieldStyle(_:)` é efetivamente no-op; customização só via modifiers. `TextEditorStyle.Configuration` é struct opaco **vazio** — `CosmosTextEditorStyle` não pode ler text/selection no `makeBody`; provavelmente exponer modifiers, não style custom. TextEditor sem prompt/placeholder API.

## Cross-cutting
- **A11y:** string title/prompt é o label default; text field nativo auto-expõe traits editable-text + texto atual como value. `.textContentType` p/ autofill/QuickType. Dynamic Type via `.font` com `relativeTo:`. Focus via `@FocusState` + `.focused`. Guardar keyboard modifiers com `#if os(iOS) || os(tvOS)`.
- **Haptics:** sem haptic nativo p/ typing. Opcional `.sensoryFeedback(.impact(.light), trigger:)` no `.onSubmit` gateado por config + reduceMotion. Default: none. (Entregue: haptic `.impact(.light)` + tracking no `.onSubmit` — [[Changelog Resumo]].)
- **Motion:** `focus` — animar border/background emphasis quando `isFocused` flipa via `.cosmosAnimation(.focus, value: isFocused)` com `theme.motion.spring(for: .focus)`. Sob reduce-motion usar `.substitute` (crossfade) ou `.instant`. **NÃO** bindar `valueChange` no text binding (dispara por keystroke — noisy, vestibular-hostile). Sem motion contínuo/looping, sem `symbolEffect`, sem `matchedGeometry`. Single `withAnimation` por focus change.

## Key modifiers
`.textFieldStyle` (resolve via `CosmosTheme.textFieldStyle`), `.focused`/`.focused(_:equals:)`, `.onSubmit(of:)`, `.keyboardType` (guard), `.textInputAutocapitalization` (guard), `.autocorrectionDisabled`, `.textContentType`, `.submitLabel`, `.lineLimit`/`axis`, `.tint`, `.font`/`.foregroundStyle`, `.textInputBorderShape(.roundedRectangle)` (iOS 26), `.textEditorStyle` (TextEditor only, guarded).

## Riscos / TODOs
- `.bordered` é `@available(anyAppleOS 27.0)` = OS 26 — gate `#available(iOS 26, ...)`, fallback `.automatic`/`.plain` abaixo de 26.
- Verificar arquivo TextEditor guarded compila stub no-op em tvOS/watchOS ou omite o tipo inteiro.
- SecureField sem style protocol — verificar `.textFieldStyle(_:)` é no-op nele.
- `ToggleSecureTextButton`/`SecureFieldVisibility`/`toggleSecureEntry` — ZERO hits em interfaces macOS/visionOS — localizar no SDK iOS/visionOS antes de confiar p/ show/hide do CosmosSecureField.
- Confirmar inits visionOS existem em 1.0/2.0.