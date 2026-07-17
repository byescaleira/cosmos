---
tags: [adr, motion, cross-cutting]
aliases: [ADR Reduce Motion Policy]
related: [[ADR Motion 9th Contract]], [[Reduce Motion Policy]]
---

# ADR — Política reduce-motion: `.substitute` / `.instant` / `.preserve`

> 2026-07-17 · Decided

**Contexto.** Reduce-motion ≠ sem feedback (MDN/MFA11y/Verdigris). Movimento espacial é suprimido, mas crossfades de opacidade e transições de cor são mantidos (vestibular-safe, ainda sinalizam mudança). O anti-pattern "kill switch" remove feedback.

**Decisão.** `CosmosReduceMotionPolicy` enum em `CosmosMotionConfiguration`:
- **`.substitute`** (default) — movimento espacial → crossfade de opacidade (vestibular-safe, mantém feedback).
- **`.instant`** — snap (sem animação).
- **`.preserve`** — só quando o motion **é o único sinal de estado** (WCAG 2.3.3 exempt).

`CosmosMotionPolicy.transition(full:substitute:reduceMotion:policy:)` escolhe a variante.

**Symbol effects** (`.symbolEffect`) já respeitam Reduce Motion automaticamente — gate **só** em `isEnabled`; **não** double-gate em `respectReduceMotion` (silenciaria feedback legítimo).

**Motion contínuo/looping** (`PhaseAnimator`, `symbolEffect` indefinido) suprimido sob reduce-motion a menos que seja o único sinal de progresso (`.preserve`).

> Truth-table e mapeamento → [[Reduce Motion Policy]].