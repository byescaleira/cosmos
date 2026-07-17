---
tags: [projeto, versionamento, platform]
aliases: [Versioning]
related: [[ADR Versioning Cosmos OS]], [[Plataforma Guards]]
---

# Versionamento

> Fonte: `VERSIONING.md`

Cosmos versiona **alinhado 1:1 com a versão do OS Apple** — não há número major separado para manter; o major da library **é** o major do OS que ela targeta.

## Major == OS

| Cosmos | iOS | macOS | tvOS | watchOS | visionOS | Era |
|---|---|---|---|---|---|---|
| **26** | 26 | 26 | 26 | 26 | 26 | Liquid Glass |

Quando um novo OS major sai, Cosmos bumpa o major para casar e pode deprecar patterns do OS anterior.

## API availability == versionamento de API

Como o deployment target do SwiftPM trackeia o OS, `@available(iOS 26, *)` é a forma canônica de dizer "disponível desde Cosmos 26". Use `@available(*, deprecated, message:)` com migration runway antes do `obsoleted:`. **Centralize** `if #available` gates em vez de espalhar pelos átomos.

### Feature → OS gate

| Feature | Gate |
|---|---|
| `.sensoryFeedback`, `symbolEffect`, `ShapeStyle.resolve(in:)`, `listSectionSpacing` | iOS 17 |
| `Tab`, `.sectionActions`, `TabViewStyle.sidebarAdaptable` | iOS 18 |
| Liquid Glass (`.glassEffect`, `.glassProminent`), `listSectionMargins` | iOS 26 |

Motion primitives (`Spring`, `PhaseAnimator`, `KeyframeAnimator`, `BlurReplaceTransition`, `withAnimation(completion)`, `.transition<T>(_:)`, `matchedGeometryEffect`, tokens/modifiers `CosmosMotion*`) são todos iOS 17/18 ≤ 26 nas 5 plataformas — **nenhum `if #available`** no baseline Cosmos 26. `GlassEffectTransition.matchedGeometry` (iOS 26) só precisaria de gate se o floor baixasse.

## Runtime design-language pin

`CosmosTheme.version: CosmosVersion` deixa um app renderizar uma **linguagem de design Cosmos mais antiga** num OS mais novo (espelha como SwiftUI adapta aparência por OS mas pode ser pinnada). Default `CosmosVersion.current` (= build target = `.cosmos26`).

## Dentro de um major: semver

- **Patch** (`26.0.x`) — bug fixes, sem mudança de API/behavior.
- **Minor** (`26.x.0`) — APIs aditivas, novos componentes, tokens não-quebrantes.
- **Major** (`N+1.0.0`) — alinha a novo OS major; pode remover APIs deprecadas (após runway) e mudar a linguagem de design.

## Deprecation runway

1. `@available(*, deprecated, message: "Use <replacement>; removed in Cosmos <N+1>.")`.
2. Funciona por pelo menos um minor.
3. Remove (ou `obsoleted:`) no próximo major.

## Changelog

Cada release registra mudanças em seções Keep-a-Changelog no `CHANGELOG.md`, com o alinhamento Cosmos/OS no topo do entry.