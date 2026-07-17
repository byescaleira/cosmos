---
tags: [projeto]
aliases: [Cosmos Proposta, Proposta, Proposal]
related: [[Arquitetura Cosmos]], [[Decisões de Arquitetura]]
---

# Cosmos Proposta

> Fonte: `PROPOSAL.md`

## Problema

O design system anterior, **Prism**, driftou e acumulou tech debt. Falta uma fundação nova para as plataformas Apple v26 com atomic design estrito. Começar pelos componentes gerou comportamento inconsistente e lógica de configuração duplicada.

## Solução

Criar **Cosmos** — design system que começa por um **objeto base compartilhado** (`CosmosConfiguration`) distribuído via SwiftUI `Environment`. Todo componente herda os mesmos contratos (accessibility, localization, log, error, loading, enablement). Só depois da base sólida vêm átomos, moléculas, organismos.

## Metas

- Comportamento previsível via configuração compartilhada.
- Sensação nativa alinhada ao HIG.
- Swift 6 strict concurrency com value types `Sendable`.
- SPM alvo único `Cosmos` expondo config + theme + atoms + molecules + data-driven screens via um `import Cosmos`.

## Não-metas (históricas da proposta)

- Suporte a UIKit ou dependência explícita de UIKit. → Consolidado em [[ADR UIKit Free]].
- watchOS / visionOS / Mac Catalyst. → **Revertido**: hoje são 5 plataformas em `.v26` (ver [[ADR Multiplatform 5 v26]] e [[Roadmap]]).
- Compatibilidade pré-v27. → Hoje baseline é **v26** (ver [[Versionamento]]).
- Engine de theming em runtime na 1ª iteração. (Depois veio `CosmosThemeObservable` — [[ADR Observable MainActor Theme]].)

## Critérios de sucesso

- `swift build` e `swift test` passam em todo commit.
- Todo componente lê behavior do `CosmosConfiguration`.
- Contratos base documentados e com unit test.

## Próximos passos (originais)

1. `.strings` catalog com keys de exemplo.
2. Plugin Claude Code `/byescaleira` com contexto do projeto.
3. Implementar o 1º átomo usando o contrato base.