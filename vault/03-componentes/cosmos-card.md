---
tags: [component, deprecated, card]
aliases: [cosmos card, CosmosCard]
related: [[Home]], [[cosmos-audit-2026-07-24]], [[unwired-accessibility-gates]]
---

# CosmosCard — deprecated (0.9.0)

> **Status: `@available(*, deprecated)` since Cosmos 0.9.0 (2026-07-24).** Slated
> for full removal in a future Cosmos major. The source of truth is the code
> (`Sources/Cosmos/Atoms/CosmosCard.swift`); this note is the deprecation record.

## What it was

A reference atom rendering a card container (header / body / footer slots) with
token-driven chrome, adaptive layout, accessibility combination, and tracking.
Implemented as a plain `View` (not `GroupBoxStyle`) because `GroupBox` is absent
on tvOS / watchOS and `GroupBoxStyle` exposes no footer in its configuration — a
plain view works on all 5 platforms. Internally it wraps `CosmosAdaptiveStack`
+ the theme's background / border / shadow tokens (`CosmosRadiusTokens.card`,
`theme.colors.surface` / `.outline`, `theme.motion.shadowOpacity` /
`shadowRadius`).

## Why deprecated

There is no single native counterpart that works on all 5 platforms, but the
atom adds little over its own primitives: the same layout composes directly from
`CosmosAdaptiveStack` + the background / border / shadow tokens. Keeping a thin
wrapper atom that duplicates compose-able primitives works against the
"atoms expose content-only inits; compose with tokens" direction. Deprecation
runs one minor (0.9.0) of migration runway before obsoletion in a future major
(per `VERSIONING.md` / `CLAUDE.md`).

## Migration

Compose the primitives the atom wrapped — `CosmosAdaptiveStack` for the
header / body / footer reflow, plus the theme's surface / outline / shadow
tokens and `CosmosRadiusTokens.card`:

```swift
// Before (deprecated)
CosmosCard {
    CosmosText("title")
} body: {
    CosmosText("body")
} footer: {
    CosmosButton("Continue") {}
}

// After — compose directly
CosmosAdaptiveStack(horizontalAlignment: .top, verticalAlignment: .leading) {
    CosmosText("title")
    CosmosText("body")
    CosmosButton("Continue") {}
}
.padding(CosmosSpacingTokens.value(for: theme.padding))
.background(RoundedRectangle(cornerRadius: CosmosRadiusTokens.card, style: .continuous).fill(theme.colors.surface))
.clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.card, style: .continuous))
.overlay(RoundedRectangle(cornerRadius: CosmosRadiusTokens.card, style: .continuous).stroke(theme.colors.outline, lineWidth: 1))
.accessibilityElement(children: .combine)
```

Access the theme/config tokens via `@Environment(\.cosmosTheme)` /
`@Environment(\.cosmosConfiguration)` as any custom view would.

## What is NOT deprecated

- `CosmosRadiusTokens.card` — a generic, reusable public radius token; kept
  (removing a public token is its own breaking change, unwarranted here).

## Audit context

The post-0.8.0 audit ([[cosmos-audit-2026-07-24]]) flagged a chokepoint bypass in
`CosmosCard.shadowHidden` (`|| reduceMotion`, bare env). That half of finding
W1.2 was intentionally **not** fixed — fixing a chokepoint inside an atom being
deprecated is wasted churn on departing code. The Toast half of W1.2 was fixed.
See [[unwired-accessibility-gates]] for the gate-wiring history.