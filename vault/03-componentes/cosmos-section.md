---
tags: [atom, wave-e]
tier: medium
pattern: wrap-view
guard: none (tipo); per-modifier guards
aliases: [CosmosSection, Cosmos Section]
related: [[Átomos Overview]], [[Plataforma Guards]]
---

# Cosmos Section

> Wave E · wrap-view (sem `SectionStyle`; primitivo, `Body == Never`) · sem guard no tipo · per-modifier guards

## Pattern & surface
Wrap-view primitivo. Inits: `init(content:, header:, footer:)` (primário), `init(content:, footer:)`, `init(content:, header:)`, `init(content:)`, `init(_ titleKey:, content:)` (iOS 15+), `init<S>(_ title:, content:)` (iOS 15+), `init(_ titleResource:, content:)` (iOS 16+), `init(isExpanded: Binding<Bool>, content:, header:)` (iOS 17+) + variants title-key/String/resource. **NÃO** expor deprecated `init(header:footer:content:)`/`init(footer:content:)`/`init(header:content:)` nem macOS-only `.collapsible(_:)`.

Container-driven modifiers: `.headerProminence(_:)` (iOS 15+), `.listSectionSpacing(_:)` (iOS 17+/watchOS 10+, unavailable macOS/tvOS), `.listSectionSeparator(_:edges:)`/`.listSectionSeparatorTint`/`.listRowSeparator`/`.listRowSeparatorTint` (iOS 15+/macOS 13+, unavailable tvOS/watchOS), `.sectionActions(_:)` (iOS 18+/macOS 15+/visionOS 2+, unavailable tvOS/watchOS), `.listSectionMargins(_:_:)` (iOS 26+/visionOS 26+, unavailable macOS/tvOS/watchOS). `Parent List/Form`/`.listStyle` determina o chrome real.

## Customization limits
Aparência é totalmente determinada pelo `List`/`Form`/`.listStyle` envolvente — `CosmosSection` **NÃO DEVE** setar seu próprio background/inset/separadores; só forward os modifiers documentados. `isExpanded` requer `Footer == EmptyView`. `Section` é primitivo — não renderiza nada útil fora de um container List/Form/GroupBox-like (previews precisam wrap em List/Form).

## Cross-cutting
- **A11y:** estrutural, sem traits próprios. Header `Text` → SwiftUI expõe semântica de header automaticamente. Header `View` custom → add `.accessibilityAddTraits(.isHeader)` (e opcional `.accessibilityHeading(.h2)`). Footer `Text` announced. Seções collapsible expõem expand/collapse via disclosure nativo; não duplicar. `.headerProminence(.increased)` raise visibility (iOS 15+).
- **Haptics:** none — não-interativo; disclosure/expand é nativo com seu próprio feedback. Haptics de botões `.sectionActions` pertencem àqueles átomos.
- **Motion:** `none`. O único motion de Section é expand/collapse nativo (driven internamente pelo SwiftUI com sua própria anim) — **NÃO** layer `.cosmosAnimation` em cima. `listInsert`/`listRemove` pertencem às rows da List dentro, não à Section. Callers querendo expand/collapse coordenado wrapam a mutação do `Binding<Bool>` num single `withAnimation(theme.motion.spring(for: .containerTransform).animation)` no call site.

## Key modifiers
`.headerProminence`, `.listSectionSpacing` (guard), `.listSectionSeparator`/`.listSectionSeparatorTint` (guard), `.listRowSeparator`/`.listRowSeparatorTint` (guard), `.sectionActions` (guard), `.listSectionMargins` (guard), `.listStyle` no enclosing List/Form, `.accessibilityHeading`/`.accessibilityAddTraits(.isHeader)` p/ header View custom, `.cosmosAnimation`/`.cosmosTransition` pass-through.

## Riscos / TODOs
- `CosmosSection` **NÃO DEVE** setar próprio background/inset/separadores (documentar prominentemente).
- `isExpanded` requer `Footer == EmptyView` — seção collapsible com footer não é expressável publicamente (`Section.create` interno aceita ambos mas nenhum init público expõe).
- **NÃO** over-excluir visionOS — `listSectionSpacing`/`listSectionSeparator` são visionOS-available implicitamente.
- Section é primitivo — previews precisam wrap em List/Form.
- title-key/LocalizedStringResource inits forçam `Parent == Text`, `Footer == EmptyView` — usar `content:header:footer:` com `Text(...)` p/ footer ao lado de header `Text`.
- Manter generic params `Sendable`; init `LocalizedStringResource` é iOS 16+ — gate se o floor baixar.