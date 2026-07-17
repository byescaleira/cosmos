---
tags: [concorrencia, reference]
aliases: [Design Systems Comparison, Concorrência Design Systems]
related: [[ADR Motion 9th Contract]], [[ADR Spring Presets]], [[ADR Reduce Motion Policy]]
---

# Concorrência — Design Systems (referência)

> "Concorrência" aqui = **análise comparativa de outros design systems**, usada como referência para as decisões de motion. (Para "concorrência" no sentido de Swift 6 concurrency → [[Swift 6 Concurrency]].)

Design systems maduros tratam motion como concern cross-cutting **tokenizado** — base da [[ADR Motion 9th Contract]].

| Sistema | Insight usado no Cosmos |
|---|---|
| **Material 3** (Google) | Motion tokenizado, cross-cutting; spring-first, purposeful. Referência para "motion como contrato". |
| **Carbon** (IBM) | Escala de duração estruturada — base da escala `CosmosDuration` (Carbon-hybrid, 6 tiers). |
| **Polaris** (Shopify) | **Removeu overshoot/anticipate** para uso minimalista em produção — anti-pattern de over-shippar presets. Base de [[ADR Spring Presets]] (só 5 presets, sem exageros). |
| **Lightning** (Salesforce) | Motion tokenizado cross-cutting. |
| **Atlassian Design System** | Motion tokenizado cross-cutting. |

## Referências de acessibilidade (reduce-motion)

- **MDN** (Mozilla) — reduce-motion ≠ no feedback.
- **MFA11y** — movimento espacial suprimido, crossfades de opacidade e cor mantidos (vestibular-safe).
- **Verdigris** — anti-pattern "kill switch" remove feedback legítimo.
- **WCAG 2.3.3** — exempt clause para motion como único sinal de estado (`.preserve`).

→ Base de [[Reduce Motion Policy]] (`.substitute` default / `.instant` / `.preserve`).

## Apple (autoritativo p/ o Cosmos)

- **Apple HIG** + **WWDC23** — spring-first, purposeful, optional, reduce-motion-aware. Base direta da split behavior↔visual e dos chokepoints. Avisa contra motion gratuito.

> Nenhum design system externo é dependência do Cosmos (zero-terceiros). São só referência conceitual.