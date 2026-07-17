---
tags: [projeto, changelog]
aliases: [Changelog Resumo, Changelog]
related: [[Roadmap]], [[Átomos Overview]]
---

# Changelog Resumo

> Fonte: `CHANGELOG.md` (seção `[Unreleased]`). Resumo — o changelog raiz é autoritativo.

## Ondas de atoms já entregues

### Wave A — style-protocol, sem guard (baixo risco)
`CosmosLabel`, `CosmosProgress`, `CosmosToggle`. Validou o plumbing de motion/haptics/tracking no padrão style-protocol.

### Wave B — wrap-view, sem guard
`CosmosDivider` (decorativo, a11y hidden), `CosmosIcon` (wrapper de `Image`, foreground style via token, symbol-effect caller-driven), `CosmosLink` (wrapper de `Link`, `.isLink`, intercept `.cosmosOpenURL`). + `CosmosOpenURLRouting` (render-free, testável). Motion `none`, sem haptics.

### Wave C — style-protocol com guards
`CosmosGroupBox` (`GroupBoxStyle` + chrome `.cosmos`; fallback plain em tvOS/watchOS), `CosmosMenu` (`MenuStyle` `.automatic`/`.button`; fallback `CosmosButton` em watchOS; primaryAction com `.selection`/`.impact(.rigid)` + `press` motion), `CosmosDatePicker` (resolução per-style `#if os()` com fallback `.automatic`; guard tipo `#if !os(tvOS)`; haptic `.selection` debounced; `numericText` content transition). + `CosmosPlatform` enum + tabelas de disponibilidade render-free (`CosmosGroupBoxAvailability`, `CosmosMenuAvailability`, `CosmosMenuAccessibility`, `CosmosDatePickerAvailability`).

### Wave D — text-input + value-controls
`CosmosTextField` (variantes via `textFieldStyle`: `.automatic`/`.plain`/`.bordered`/`.cosmos`; `.bordered` gated a OS 27 com fallback `.automatic`; chrome `.cosmos` no body onde `@FocusState` é visível já que `TextFieldStyle._body` é SPI opaco; focus border via `.cosmosAnimation(.focus, value:)`; `.submitLabel(.done)` iOS/tvOS; haptic `.impact(.light)` + tracking no `.onSubmit`), `CosmosSecureField` (sem style selector — SecureField não tem style protocol conformable; focus motion), `CosmosTextEditor` (`#if !os(tvOS) && !os(watchOS)`; built-ins nativos só — `TextEditorStyleConfiguration` é struct opaco vazio; `.roundedBorder` visionOS-only). `CosmosSlider` (`#if !os(tvOS)`; `V` fixo em `Double`; sem SliderStyle; `.tint` único; `.cosmosAnimation(.valueChange)` + haptic `.selection` quantizados via `CosmosSliderMath.stepped` — feedback no step-snap, nunca por pixel de drag; cluster iOS 26 ticks/neutralValue/`SliderTickBuilder` deferido), `CosmosStepper` (API uniforme 5 plataformas; tvOS → fallback `CosmosButton` +/- pair; closures só capturam init params, nunca `self`; label-first não-deprecated; sem double haptic). + math enums render-free `CosmosSliderMath`/`CosmosStepperMath` + `CosmosTextEditorAvailability`.

## Subsistemas entregues

- **Motion subsystem** — 9º contrato + tokens visuais + modifiers chokepoint (`.cosmosAnimation`/`.cosmosTransition`/`.cosmosContentTransition`/`.cosmosStagger` + overrides). Integrado em `CosmosButton`/`CosmosButtonChrome`/`CosmosText`/`CosmosCard`. `BlurReplaceTransition` via `.transition<T>(:)` genérico (não é `AnyTransition`-composable). → [[Motion Subsystem]].
- **Preview + mock infra** — `CosmosPreviewRNG` (SplitMix64), `CosmosPreviewModifier`, `.cosmosPreviewEnv`/`.cosmosPreviewVariant` (SPI underscore), `CosmosMock` (geradores determinísticos), `Mutex<CosmosPreviewRNG>`. Sem deps terceiros, sem UIKit, sem `#if DEBUG`. → [[ADR Preview Mock Infra]].
- Fontes custom (DM Sans, Space Grotesk, JetBrains Mono) via CoreText; `CosmosFont.registerAllFonts()`; presets `.dmSans`/`.spaceGrotesk`/`.jetBrainsMono` com `relativeTo:`.

## Mudanças estruturais

- SPM em **alvo único `Cosmos`**; merge de `CosmosBase`→`Base/`, `CosmosScreen`→`Screen/`; removidos `@_exported`.
- Pacote **explicitamente UIKit-free** (`Color(.systemBackground)` no lugar de `Color(uiColor:)`; removido `#if canImport(UIKit)` do `CosmosList`). → [[ADR UIKit Free]].
- **Matriz multiplatform restaurada**: 5 plataformas em `.v26` (Swift 6.4, mode v6). Draft anterior listava só iOS/macOS/tvOS 27 — corrigido.
- CI migrado de `xcodebuild docbuild` (iOS Simulator) para `swift build` + `swift test`.

## Pendente (Wave E)

[[Cosmos Section]], [[Cosmos Picker]], [[Cosmos List]], [[Cosmos TabView]] — ver [[Átomos Overview]].