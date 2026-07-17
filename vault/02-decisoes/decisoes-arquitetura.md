---
tags: [adr, decisoes, moc]
aliases: [Decisões de Arquitetura, ADRs]
related: [[Home]]
---

# Decisões de Arquitetura

> Fonte: `DECISIONS.md`. ADRs do **Cosmos 26 rebuild** (from-scratch, a partir de 2026-07-16). Supersede o decision log pré-rebuild.

## ADRs por tema

### Fundação & escopo
- **From-scratch rebuild com reset de histórico** (2026-07-16) — repo limpo para um commit inicial (backup branch/tag/stash); re-autoria de tudo. *Decided.*
- [[ADR Multiplatform 5 v26]] — todas as 5 plataformas em `.v26`. (Decided.)
- [[ADR UIKit Free]] — sem `import UIKit`/`UIColor`/`UIViewController`/`#if canImport(UIKit)`/`UIHostingController`. APIs SwiftUI que encapsulam UIKit internamente OK. (Decided.)
- [[ADR Global State Entry]] — estado & theme globais via `@Entry`, não por-componente. (Decided.)
- **Split behavior vs visual** (2026-07-16) — `CosmosConfiguration` (behavior) ↔ `CosmosTheme` (visual), ambos env values. (Decided.) → [[Arquitetura Cosmos]].
- **8 contratos cross-cutting** (2026-07-16) — accessibility, localization, log, error, loading, enable + **haptics** + **tracking**. Todos `Sendable`; handlers `@Sendable`. (Decided.) → depois virou 9 com motion ([[ADR Motion 9th Contract]]).

### Concorrência
- [[ADR Swift 6 Concurrency]] — zero warnings, sem `NSLock`/`DispatchQueue`/`nonisolated(unsafe)`; once-token `static let`; `Mutex`/`Atomic` (`import Synchronization`); `@Entry` values `Sendable`. (Decided.)
- [[ADR Observable MainActor Theme]] — runtime theme via `@Observable @MainActor` (`CosmosThemeObservable`). (Decided.)

### Versionamento & docs
- [[ADR Versioning Cosmos OS]] — Cosmos N ↔ OS N, baseline Cosmos 26. (Decided.)
- **String Catalogs, sem plugin** (2026-07-16) — `.xcstrings` via `.process("Resources")`; `LocalizedStringResource`/`#bundle`/`String(localized:)`; baseline `en` + `pt-BR`. (Decided.) → [[Versionamento]].
- **`AnyLayout`/`ViewThatFits` para portrait↔landscape** (2026-07-16) — preserva identidade de view no reflow. (Decided.)
- [[ADR Style Protocol or Wrap]] — style protocol quando conformable, wrap `View` caso contrário. (Decided.)
- **Fontes custom via `Font.custom(_:size:relativeTo:)`** (2026-07-16) — sempre `relativeTo:` para Dynamic Type. (Decided.)
- **Camada de tokens semânticos** (2026-07-16) — `CosmosColorTokens`/`TypographyTokens`/`SpacingTokens`/`RadiusTokens` + seletores. (Decided.)
- **Liquid Glass: `.glass` via native styles, chrome para o resto** (2026-07-16) — `.glass`/`.glassProminent` não customizáveis via `ButtonStyle`; `CosmosButtonStyle.glass` aplica `.buttonStyle(.glassProminent)` (gate iOS 26). (Decided.)

### Motion
- [[ADR Motion 9th Contract]] — `CosmosMotionConfiguration` (9º contrato) + `CosmosMotionTokens` no theme; chokepoints `.cosmosAnimation`/`.cosmosTransition`/`.cosmosContentTransition`; `CosmosMotionPolicy` config-aware. (2026-07-17, Decided.)
- [[ADR Reduce Motion Policy]] — `.substitute` (default) / `.instant` / `.preserve` (WCAG 2.3.3 exempt). (2026-07-17, Decided.)
- [[ADR Spring Presets]] — 5 presets espelhando SwiftUI + 2 extensões Cosmos; 6-tier duração Carbon-hybrid. (2026-07-17, Decided.)
- [[ADR Preview Mock Infra]] — preview/mock no alvo `Cosmos`, público, sem `#if DEBUG`, RNG seeded hand-rolled; `Mutex` para state compartilhado. (2026-07-17, Decided.)
- **Split motion behavior vs visual** (2026-07-17) — behavior em `CosmosConfiguration.motion`, tokens em `CosmosTheme.motion`. (Decided.)

> Todas as decisões marcadas **Decided** em `DECISIONS.md`. Ao mudar uma, abra um novo ADR e link aqui.