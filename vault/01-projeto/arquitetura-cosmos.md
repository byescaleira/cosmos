---
tags: [projeto, arquitetura]
aliases: [Arquitetura Cosmos, Arquitetura, Architecture]
related: [[Cosmos Proposta]], [[Contratos Cross-cutting]], [[Motion Subsystem]]
---

# Arquitetura Cosmos

> Fonte: `ARCHITECTURE.md`

Cosmos é um design system SwiftUI multiplataforma distribuído como pacote SPM. Começa com **dois value types mutáveis-por-substituição** distribuídos via `@Entry` environment:

- **`CosmosConfiguration`** — contratos de **comportamento** cross-cutting: accessibility, localization, log, error, loading, enablement, haptics, **motion**, tracking (9 contratos → [[Contratos Cross-cutting]]).
- **`CosmosTheme`** — **tokens visuais**: colors, typography, spacing, radii, **motion** (springs/durations/transitions) + seletores de estilo.

Todo componente (átomo/molécula/organismo) lê ambos pelo environment.

## Princípios

1. **Foundation first** — todo componente herda o mesmo contrato base.
2. **Modularidade** — alvo único `Cosmos` expõe fundação (`Base/`) + biblioteca (`Atoms`/`Molecules`/…); import só o que usa.
3. **Testabilidade** — value types + env keys são fáceis de unit-testar.
4. **Maintainability** — atomic design mantém escopo pequeno e composável.
5. **Concurrency safety** — Swift 6 strict; tipos públicos `Sendable`.
6. **Apple-aligned** — segue HIG, Accessibility, Localization.

## Estrutura

```
Sources/Cosmos/
├── Base/  (Configuration, Theme, Environment, Preview)
├── Atoms/        (flat folder)
├── Molecules/
├── Modifiers/
├── Organisms/
└── Screen/  (Model, Renderer, Registry, Loader)
```

## Mutação por substituição

`CosmosConfiguration` / `CosmosTheme` são `Sendable struct`. Mutação:
1. Substituir o objeto inteiro: `.cosmosConfiguration(new)` / `.cosmosTheme(new)`.
2. Mutar cópia local em `@State` e re-injetar.
3. Modifiers focados: `.cosmosEnabled(false)`, `.cosmosLoading(true)`, `.cosmosAccessibilityLabel(…)`, `.cosmosControlSize(.large)` — `ViewModifier`s que leem o valor atual, mutam cópia, re-injetam com `.environment(_:_:)`.

Evita fricção `@Observable` + `@MainActor` e mantém objetos testáveis off-main. Atoms têm inits **content-only**; state/config vêm do environment. (Exceção: runtime theming via [[ADR Observable MainActor Theme]].)

## `@Entry` (SwiftUI v26)

Uma declaração gera `EnvironmentKey` + accessor + modifier:

```swift
extension EnvironmentValues {
  @Entry public var cosmosConfiguration: CosmosConfiguration = .default
  @Entry public var cosmosTheme: CosmosTheme = .default
}
```

## Tokens (theme)

| Token | Responsabilidade |
|---|---|
| `CosmosColorTokens` | primary, secondary, accent, background, surface, success, warning, error |
| `CosmosTypographyTokens` | largeTitle, title, body, caption, … |
| `CosmosSpacingTokens` | none, xs, small, medium, large, xl, xxl (4-pt grid) |
| `CosmosRadiusTokens` | none, small, medium, large, full |

Seletores (`CosmosTextStyle`, `CosmosButtonStyle`, `CosmosControlSize`, …) ficam no `CosmosTheme` para os átomos escolherem um look default sem expor points crus.

## Data-driven screens

`CosmosScreen` renderiza um modelo serializável em SwiftUI:
- `CosmosScreen` — id + array de `CosmosComponent` (enum `Sendable`/`Codable`/`Equatable`).
- `CosmosScreenRenderer` — renderer recursivo (cada case → átomo, em `AnyView` para quebrar inferência recursiva).
- `CosmosActionRegistry` — desacopla ids de ação serializáveis de closures runtime.
- `CosmosScreenLoader` — decodifica JSON (snake_case).

Permite screens como JSON/payload de servidor renderizados com os mesmos átomos.

## UI testing

Sem deps de terceiros: **Swift Testing** (lógica), **Xcode Previews** (regressão visual), **Catalog app** (planejado). Sem snapshot/inspection libs (nenhuma da Apple). Futura alternativa nativa só seria avaliada sem quebrar a API pública. → [[ADR Preview Mock Infra]].