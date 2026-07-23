---
tags: [risk, accessibility, tech-debt, cosmos]
aliases: [unwired accessibility gates, colorSchemeContrast gap, differentiateWithoutColor gap]
related: [[cosmos-org-audit-2026-07]], [[adr-atoms-impose-theme-defaults]]
---

# Unwired accessibility gates — colorSchemeContrast / differentiateWithoutColor / showButtonShapes

**Date:** 2026-07-23 · **Status:** Tracked gap (not wired)

`CLAUDE.md` lists five SwiftUI environment gates every component should honor:
`accessibilityReduceMotion`, `accessibilityReduceTransparency`, `colorSchemeContrast`,
`differentiateWithoutColor`, and `dynamicTypeSize` (plus `accessibilityShowButtonShapes`
elsewhere in the doc).

## What is actually wired

- **`accessibilityReduceMotion`** — wired through `CosmosMotionPolicy.shouldEmit` /
  `transition(_:reduceMotion:policy:)` (every motion atom).
- **`accessibilityReduceTransparency`** — wired through
  `CosmosMotionPolicy.shouldCollapseTransparency` (CosmosCard shadow, CosmosToast
  surface, CosmosProgress track). As of 2026-07-23 this is now **policy-aware** via
  `CosmosMotionConfiguration.reduceTransparencyPolicy` (`.substitute` collapses, `.preserve`
  keeps materials) — previously the enum was declared but read nowhere.
- **`dynamicTypeSize`** — honored indirectly: custom fonts always pass `relativeTo:` so
  Dynamic Type scales; `CosmosAdaptiveStack` switches layout by `dynamicTypeSize`.

## What is NOT wired (the gap)

- **`colorSchemeContrast`** — no atom reads `@Environment(\.colorSchemeContrast)` and no atom
  calls `ShapeStyle.resolve(in:)`. `CosmosColorTokens` and `CosmosAccessibilityConfiguration`
  doc comments previously **falsely claimed** atoms adapt at runtime via this gate; those
  comments are corrected (high-contrast variants come from an app-layer asset catalog, not
  runtime adaptation). Wiring this properly is per-atom semantic work (adaptive surface
  fills, increased-contrast outlines) with visual-regression risk — deferred.
- **`accessibilityDifferentiateWithoutColor`** — no atom reads it. Where color is the sole
  state signal (success/warning/error toasts, destructive buttons), a symbol or text
  differentiator should be added when this is active. Not yet done.
- **`accessibilityShowButtonShapes`** — no atom reads it. Borderless/ghost buttons should
  gain a shape when active. Not yet done.

## Why deferred (not silently dropped)

These are real accessibility behaviors, and `CLAUDE.md` keeps them as a binding goal, so they
are **not** dropped from the guideline — they are tracked here as unfinished work. Wiring each
is a feature with per-atom visual decisions, not a mechanical cleanup, and belongs in a
dedicated accessibility pass (with previews across the gate variants, which `CosmosPreviewEnv`
already supports via the `_colorSchemeContrast` / `_accessibilityDifferentiateWithoutColor` /
`_accessibilityShowButtonShapes` SPI keys). The false in-source claims were corrected so the
docs no longer describe behavior that does not exist.

## Resolution options (future pass)

1. **colorSchemeContrast** — add an adaptive-surface helper that resolves the surface/outline
   token via `ShapeStyle.resolve(in:)` under increased contrast; apply in `CosmosCard`,
   `CosmosGroupBox` chrome, `CosmosToast`.
2. **differentiateWithoutColor** — add a non-color differentiator (symbol or leading text) to
   state-bearing atoms (`CosmosToastContent`, destructive `CosmosButton` variants) gated on
   the env value.
3. **showButtonShapes** — add a subtle shape to `.ghost`/borderless buttons when active.

Each needs its own ADR-sized decision (which atoms, what the non-color signal is) and preview
coverage before shipping.