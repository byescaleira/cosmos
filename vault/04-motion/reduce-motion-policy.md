---
tags: [motion, cross-cutting, risk]
aliases: [Reduce Motion Policy, CosmosReduceMotionPolicy]
related: [[ADR Reduce Motion Policy]], [[Motion Subsystem]]
---

# Reduce Motion Policy

> Reduce-motion ≠ sem feedback. Movimento espacial é suprimido; crossfades de opacidade e transições de cor são mantidos (vestibular-safe, ainda sinalizam mudança). O anti-pattern "kill switch" remove feedback. Fontes: MDN, MFA11y, Verdigris.

## `CosmosReduceMotionPolicy` (em `CosmosMotionConfiguration`)

| Caso | Comportamento |
|---|---|
| **`.substitute`** (default) | Movimento espacial → crossfade de opacidade (vestibular-safe, mantém feedback) |
| **`.instant`** | Snap (sem animação) |
| **`.preserve`** | Só quando o motion **é o único sinal de estado** (WCAG 2.3.3 exempt) |

`CosmosMotionPolicy.transition(full:substitute:reduceMotion:policy:)` escolhe a variante. `CosmosMotionPolicy.shouldEmit(isEnabled:respectReduceMotion:reduceMotion:)` é a truth-table de gating (espelha `CosmosHapticsPolicy`).

## Regras por tipo de motion

- **Symbol effects** (`.symbolEffect`) — auto-respeitam Reduce Motion. Gate **só** em `isEnabled`; **não** double-gate em `respectReduceMotion` (silenciaria feedback legítimo).
- **Motion contínuo/looping** (`PhaseAnimator`, `symbolEffect` indefinido) — suprimido sob reduce-motion a menos que seja o único sinal de progresso (`.preserve`). Ex.: spinner indeterminate de [[Cosmos Progress]].
- **Motion como único sinal** (`.preserve`) — ex.: thumb tracking do [[Cosmos Slider]] (WCAG 2.3.3 exempt); drag é gesture-tracked, não Cosmos-driven — não animar o binding por frame.
- **Native system-controlled** (popover de [[Cosmos Menu]], swipe de [[Cosmos DatePicker]] wheel/graphical, paging de [[Cosmos TabView]] PageTabViewStyle, spinner `.refreshable` de [[Cosmos List]]) — auto-respeita RM; **não** double-gate do Cosmos.
- **Delegação a style nativo** — ex.: [[Cosmos Toggle]] delegando a `.switch` (thumb nativo não é SwiftUI-driven) — suprimir Cosmos motion para evitar double anim.

## Truth-table (`shouldEmit`)

Testado por `CosmosMotionTests`: cada `CosmosReduceMotionPolicy` (`.substitute`/`.instant`/`.preserve`) × (`isEnabled` true/false) × (`respectReduceMotion` true/false) × (`reduceMotion` true/false). → [[Phase 2 Research Workflow]] test plan.