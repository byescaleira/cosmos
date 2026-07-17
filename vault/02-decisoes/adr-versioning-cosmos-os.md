---
tags: [adr, versionamento, platform]
aliases: [ADR Versioning Cosmos OS]
related: [[Versionamento]], [[Plataforma Guards]]
---

# ADR — Versionamento: Cosmos N ↔ OS N

> 2026-07-16 · Decided

**Contexto.** Usuário: *"totalmente versionado assim como SwiftUI … relacionado à versão do iOS, vamos começar com o cosmos 26."*

**Decisão.** Library major == OS major; baseline **Cosmos 26** (OS 26 / Liquid Glass).
- `@available(iOS 26, *)` == "disponível desde Cosmos 26" — API availability **é** versionamento de API.
- `if #available` gates **centralizados** (não espalhados pelos átomos).
- `CosmosTheme.version: CosmosVersion` — pin de design-language em runtime; apps podem fixar um look mais antigo num OS mais novo. Default `.cosmos26`.
- Semver minor/patch dentro de um major; deprecation runway antes da obsoletion.

**Política** em `VERSIONING.md`; mudanças em `CHANGELOG.md`. Detalhes → [[Versionamento]].