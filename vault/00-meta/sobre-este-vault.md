---
tags: [meta]
related: [[Home]], [[README]]
---

# Sobre este vault

## Origem

Consolida as pesquisas feitas ao longo do desenvolvimento do Cosmos — concorrência (outros design systems), componentes (16 átomos SwiftUI), documentações (arquitetura/versionamento/proposta) e revisões (verificação adversarial + ADRs).

A pesquisa de átomos foi gerada pelo workflow [[Phase 2 Research Workflow]] (3 fases: research → verify → synthesize) e consolidada em `PHASE2.md` na raiz do repo. Este vault reorganiza esse conteúdo em grafo.

## Fonte de verdade

| Note do vault | Doc raiz autoritativo |
|---|---|
| [[Arquitetura Cosmos]] | `ARCHITECTURE.md` |
| [[Decisões de Arquitetura]] | `DECISIONS.md` |
| [[Átomos Overview]] + notas de átomo | `PHASE2.md` |
| [[Versionamento]] | `VERSIONING.md` |
| [[Roadmap]] | `ROADMAP.md` |
| [[Cosmos Proposta]] | `PROPOSAL.md` |
| [[Changelog Resumo]] | `CHANGELOG.md` |
| [[Phase 2 Research Workflow]] | `.claude/workflows/phase2-atom-research.js` |

**Conflito → doc raiz vence.** Atualize o note.

## Convenções

- Arquivos em kebab-case (ex.: `cosmos-toggle.md`), mas o título do Obsidian é o H1 com espaços.
- Frontmatter: `tags`, `aliases`, `related` (links para notas relacionadas).
- Links: `[[Nome do Note]]` (usa o título, não o filename).
- Notas de átomo: tag `#atom` + `tier` no frontmatter.

## Não é sincronizado automaticamente — mas é **vivo**

Este vault é a **memória de longo prazo** do projeto. Mudanças nos docs raiz não se propagam sozinhas — revise após ondas grandes (ex.: Wave E). E, por regra binding do `CLAUDE.md` ("Research → Obsidian vault"), **toda pesquisa nova a partir de 2026-07-17 deve ser persistida aqui** como nota interligada (não pode terminar só no chat). Nova pesquisa → nova nota na pasta certa (`03-componentes/` / `06-concorrencia/` / `07-metodologia/` / `08-riscos/` / `02-decisoes/`), linkar do `[[Home]]` e relacionados, verificar wikilinks.