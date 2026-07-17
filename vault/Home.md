---
tags: [moc, index]
aliases: [Home, Map of Content, Índice]
---

# 🌌 Cosmos — Map of Content

Ponto de entrada do vault. Tudo parte daqui.

## 🎯 O que é o Cosmos

[[Cosmos Proposta]] — problema, solução, metas, não-metas.
[[Arquitetura Cosmos]] — `CosmosConfiguration` + `CosmosTheme` via `@Entry`; atomic design; data-driven screens.
[[Versionamento]] — Cosmos N ↔ OS N; baseline **Cosmos 26** (Liquid Glass).
[[Roadmap]] — Now / Next / Later.
[[Changelog Resumo]] — ondas já entregues (B, C, D) + subsistemas.

## 🧱 Componentes (a pesquisa de átomos)

[[Átomos Overview]] — ondas A→E, ordem de build por risco, tiers.
[[Motion Intent Matrix]] — átomo → `CosmosMotionKind` → reduce-motion.
[[Checklist de Integração]] — 11 itens por átomo (9 contratos + layout + multiplatform).
Notas por átomo → ver [[Átomos Overview]] (16 notas individuais).

## 🎞️ Motion

[[Motion Subsystem]] — motion como 9º contrato cross-cutting; tokens visuais no theme.
[[Reduce Motion Policy]] — `.substitute` / `.instant` / `.preserve`.
[[Spring Presets]] — 5 presets + escala de duração (Carbon-hybrid).

## 🔁 Cross-cutting

[[Contratos Cross-cutting]] — accessibility, haptics, localization, tracking, motion, enable, loading, log, error.
[[Plataforma Guards]] — matriz `#if os()` + `#available` + fallback por átomo.

## 🏁 Concorrência

[[Design Systems Comparison]] — Material 3, Carbon, Polaris, Lightning, Atlassian (referência de motion).
[[Swift 6 Concurrency]] — zero warnings, Mutex/Atomic, once-token, Sendable, `@Observable @MainActor`.

## 📋 Decisões

[[Decisões de Arquitetura]] — índice de ADRs (rebuild, multiplatform, UIKit-free, estado global, motion, versionamento, …).

## 🔬 Metodologia

[[Phase 2 Research Workflow]] — research → adversarial verify → synthesize.
[[Verificação Adversarial]] — o padrão de refutar cada claim contra a SDK interface.

## ⚠️ Riscos

[[Riscos Abertos]] — TODOs a re-verificar por plataforma (iOS/macOS/tvOS/watchOS/visionOS).
[[Itens Refutados]] — correções de spec já aplicadas (não recair nelas).

## 🗂️ Navegação por tag

- `#atom` — notas de átomos
- `#adr` — decisões
- `#motion` — subsistema de motion
- `#cross-cutting` — contratos horizontais
- `#platform` — guards e disponibilidade
- `#risk` — riscos e TODOs
- `#meta` — sobre o próprio vault