---
tags: [adr, decision, atoms, theming, overrides, cosmos]
aliases: [ADR atoms impose theme defaults, de-styling policy, Cosmos pass-through decision]
related: [[cosmos-org-audit-2026-07]], [[cosmos-toast]]
---

# ADR — Atoms impose theme defaults; `.cosmos*` are subtree overrides (not pass-through)

**Date:** 2026-07-23 · **Status:** Decided · **Supersedes:** nothing (clarifies the 0.5.0
"Defaults + overrides SwiftUI" decision under tension from an interrupted refactor).

## Context

The 0.5.0 typography/override work shipped `.cosmosFont(_:weight:design:)`, `.cosmosFont(_:for:)`,
`.cosmosTint`, and `.cosmosForegroundStyle` as **subtree overrides** that mutate a copy of
`cosmosTheme` and re-inject it. For an override to take effect on an atom, the atom must **read the
token** it overrides — `.cosmosFont` only reaches atoms that call
`theme.typography.font(for: theme.textStyle)` in `body`.

An interrupted de-styling refactor stripped those reads from three atoms:

- `CosmosText` — removed `.font(theme.typography.font(for: theme.textStyle))`,
  `.foregroundStyle(theme.colors.primary)`, `.multilineTextAlignment(.leading)`,
  `.cosmosContentTransition(.numeric)`, `.cosmosAnimation(.valueChange, value: resolvedText)`.
  The `onAppear` still fired `motion.handler(.motion(.valueChange))` → **vestigial motion event**
  with no animated value.
- `CosmosTextEditor` — removed the `@Environment(\.cosmosTheme)` read, the
  `CosmosTextEditorStyleApplier` modifier, and `.tint/.font/.foregroundStyle`. The
  `.cosmosTextEditorStyle(_:)` modifier + `CosmosTextEditorStyle` enum + availability stayed
  **public but became a silent no-op** (applier deleted) — a `VERSIONING.md` deprecation-runway
  violation.
- `CosmosTextField` — removed `.tint/.font/.foregroundStyle` + `.submitLabel(.done)`, diverging
  from `CosmosSecureField` (same family, still imposes all of them) with no justification.

The result: `.cosmosFont`/`.cosmosForegroundStyle`/`.cosmosTint` were **no-ops** on exactly the atoms
they most target (a `CosmosText` is the prime candidate for `.cosmosFont(.headline)`). See
[[cosmos-org-audit-2026-07]] P0.

## Decision

**Atoms impose their theme-driven visual defaults and read the relevant tokens.** The de-styling is
reverted. An atom is never pass-through for the tokens its override surface promises.

- Every atom applies `theme.typography.font(for: theme.textStyle)`, the relevant
  `theme.colors.*` token, and the motion/content-transition primitives it owned before.
- `CosmosTextEditorStyleApplier` is restored → `.cosmosTextEditorStyle(_:)` is live again (no-op
  resolved).
- `CosmosText` motion restored → the `onAppear` `valueChange` event has its animated value back.
- `CosmosTextField` realigned with `CosmosSecureField`.

Callers override per-subtree via `.cosmos*` modifiers (which re-inject a mutated `cosmosTheme`) or by
building a `CosmosTheme`/`CosmosThemeObservable`. Raw SwiftUI `.font`/`.foregroundStyle`/`.tint`
remain available as **escape hatches** for one-off cases that should not flow through tokens.

## Why not pass-through

A "pass-through atom" that does not read `theme.typography`/`theme.colors` makes `.cosmosFont`/
`.cosmosForegroundStyle`/`.cosmosTint` **no-ops on that atom** — the modifier mutates the
environment, but the atom ignores it. The override system only works when atoms participate by
reading the tokens. Pass-through is therefore incompatible with the override ergonomics that are
the whole point of the 0.5.0 surface. (Pass-through *can* still be achieved ad-hoc by a caller using
raw SwiftUI modifiers on a Cosmos atom — that path is unaffected and kept.)

## Consequences

- `.cosmosFont`/`.cosmosForegroundStyle`/`.cosmosTint`/`.cosmosControlSize` reach **every** atom
  consistently — the override surface is uniform.
- The 14 atoms that already imposed defaults are unchanged; the 3 de-styled atoms are restored to
  parity.
- The `.cosmosTextEditorStyle` surface stays public and functional (no deprecation needed — the
  no-op was the bug, not the API).
- No `@available(*, deprecated)` runway is consumed.
- Recorded as a `DECISIONS.md` row (2026-07-23) so the rationale survives outside chat.

## What this does NOT decide

- Whether `CosmosTextField.submitLabel(.done)` is too opinionated for a search field (a future,
  separate call — out of scope here; the revert restores the prior behavior for parity with
  `CosmosSecureField`).
- GroupBox title literal `.headline` / AsyncImage glyph `.font(.system(size:))` token bypasses —
  known gaps deferred from the 0.5.0 plan (intentional glyph sizing / layout-regression risk).