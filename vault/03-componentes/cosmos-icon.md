---
tags: [atom, wave-b]
tier: low
pattern: wrap-view
guard: "#if !os(watchOS) para .allowedDynamicRange/DynamicRange only"
aliases: [CosmosIcon, Cosmos Icon]
related: [[Átomos Overview]]
---

# Cosmos Icon (Image)

> Wave B · wrap-view (sem `ImageStyle`) · guard só p/ `.allowedDynamicRange` · sem `#available` no floor `.v26`

## Pattern & surface
Wrap-view. Image-returning methods: `.resizable(capInsets:resizingMode:)`, `.renderingMode(.template/.original)`, `.interpolation`, `.antialiased`, `.symbolRenderingMode(_:)` (iOS 15+), `.symbolVariableValueMode`/`.symbolColorRenderingMode` (iOS 26+), `.allowedDynamicRange(_:)` (`#if !os(watchOS)`). View modifiers: `.foregroundStyle`/`.tint` (template only), `.font` + `.imageScale`, `.symbolVariant`, `.symbolEffect` (iOS 17+, auto-respeita RM — gate `isEnabled` only), `.contentTransition(.symbolEffect(.replace))`, `.scaledToFit/.scaledToFill/.frame/.clipShape/.overlay/.shadow/.grayscale/.opacity`.

## Inits a expor
`init(systemName:)`, `init(systemName:variableValue:)` (iOS 16+), `init(_ name:, bundle:)`, `init(_ name:, bundle:, label: Text)`, `init(decorative name:, bundle:)`, `init(decorative name:, variableValue:, bundle:)`, `init(_ resource: ImageResource)` (iOS 17+), CGImage variants, `init(size:, label:, opaque:, colorMode:, renderer:)` (iOS 16+). **NÃO** expor `init(uiImage:)` (UIKit-bridged, forbidden) nem `init(nsImage:)` (AppKit-bridged, excluir). → [[ADR UIKit Free]].

## Customization limits
Imagens raster (asset/CG) não podem ser tintadas a menos que `.renderingMode(.template)` seja setado antes. Sem `init(uiImage:)`/`init(nsImage:)` na superfície Cosmos. `init(_systemName:colorPalette:)` deprecated — route pra `.renderingMode(.original)`.

## Cross-cutting
- **A11y:** SF Symbols: VoiceOver pode anunciar o nome cru do símbolo — SEMPRE setar `.accessibilityLabel(_:)` para símbolos significativos e `.accessibilityHidden(true)` para decorativos. A escolha decorative vs labelled init é load-bearing. `.isImage` trait auto.
- **Haptics:** none. Se usado como label de Button/Toggle, o style controlador owna haptics.
- **Motion:** `none`. `.symbolEffect` é caller-driven; symbol-replace em value change mapeia pra `valueChange` no use site, não dentro do átomo.

## Key modifiers
`.resizable`, `.renderingMode(.template|.original)`, `.symbolRenderingMode`, `.symbolEffect(_:options:isActive:)`, `.font`/`.imageScale`, `.symbolVariant`, `.foregroundStyle`, `.accessibilityLabel`/`.accessibilityHidden`, `.cosmosMotion`/`.cosmosAnimation(value:)`/`.cosmosTransition`.

## Riscos / TODOs
- A11y de SF Symbol — fácil esquecer `.accessibilityLabel`.
- Documentar template-mode como o path tintable.
- `ImageResource` codegen presente nas 5 plataformas (iOS 17/macOS 14/tvOS 17/watchOS 10 ≤ 26).
- `.allowedDynamicRange` watchOS-unavailable — verificar compile watchOS com o guard.