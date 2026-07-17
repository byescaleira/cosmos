---
tags: [meta, vault, index]
aliases: [Cosmos Vault, Vault README]
---

# Cosmos Vault — Memória de Pesquisa

Este diretório é um **vault do Obsidian**: uma arquitetura de memória em grafo (notas interligadas por `[[wikilinks]]`, frontmatter, tags e backlinks) que consolida **toda a pesquisa já feita** sobre o Cosmos — concorrência, componentes, documentações e revisões.

> As fontes autoritativas continuam sendo os arquivos `.md` na raiz do repo (`PHASE2.md`, `DECISIONS.md`, `ARCHITECTURE.md`, `VERSIONING.md`, `ROADMAP.md`, `PROPOSAL.md`, `CHANGELOG.md`). Este vault é uma **camada de navegação e síntese** por cima deles — não os substitui. Quando um note do vault e um doc raiz divergirem, o doc raiz vence; atualize o note.

## Como abrir no Obsidian

1. Abra o app **Obsidian**.
2. **Open folder as vault** → selecione esta pasta `vault/`.
3. O Obsidian cria `.obsidian/` automaticamente. O grafo, backlinks e tags já funcionam nativamente — **nenhum plugin é necessário** (foi a escolha: vault no próprio repo, sem instalar nada).

## Plugins opcionais (instale você, se quiser extrair mais)

Estes são plugins de comunidade que turbinam a "memória", mas **não são exigidos**:
- **Dataview** — gera índices dinâmicos por tag/frontmatter (ex.: "todas as notas `#atom` com `tier: high`").
- **Graph Analysis** / **Juggl** — visualização avançada do grafo de dependências.
- **Templater** — se quiser criar templates para novos ADRs/atomos.

## Estrutura

- [[Home]] — Map of Content (MOC) central; comece por aqui.
- `00-meta/` — sobre o vault e como navegar.
- `01-projeto/` — proposta, arquitetura, roadmap, versionamento, changelog.
- `02-decisoes/` — ADRs (architecture decision records).
- `03-componentes/` — os 16 átomos pesquisados (spec, guards, motion, risks).
- `04-motion/` — subsistema de motion, reduce-motion, spring presets.
- `05-cross-cutting/` — 9 contratos cross-cutting + matriz de guards por plataforma.
- `06-concorrencia/` — comparação com outros design systems + concorrência Swift 6.
- `07-metodologia/` — o workflow de pesquisa (research → verify → synthesize).
- `08-riscos/` — TODOs abertos e itens de spec refutados.

## Manutenção

- Notas novas: prefixo `Cosmos` nos componentes, kebab-case nos arquivos.
- Sempre adicione `tags` e `related` no frontmatter para o grafo permanecer conectado.
- Ao mudar uma decisão, crie um novo ADR em `02-decisoes/` e atualize o `[[Home]]`.