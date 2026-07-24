---
tags: [risk, audit, concurrency, swiftui, environment, cosmos]
aliases: [P6, environment-churn audit, CosmosConfiguration closure churn]
related: [[Home]], [[cosmos-org-audit-2026-07]], [[unwired-accessibility-gates]]
---

# Risk: environment churn from `CosmosConfiguration` closures — refuted (P6 audit)

**Status:** refuted — audited 2026-07-23, no Cosmos-side defect found. Recorded as a closed risk.

## The hypothesized risk

A `@Sendable` closure stored on a `Cosmos*Configuration` value (`handler` on
`CosmosTrackingConfiguration`, `CosmosMotionConfiguration`, `CosmosLogConfiguration`,
`CosmosErrorConfiguration`, `CosmosHapticsConfiguration`) could **capture environment-derived
state**. Since the whole `cosmosConfiguration` is injected via `@Environment`, a handler that
closes over changing state would force a new config value on every change, identity-diffing as
unequal and churning the entire subtree that reads `cosmosConfiguration` — the classic SwiftUI
"build a config in `body`" footgun.

## What the audit checked

1. **Handler declarations** — all five are `@Sendable @escaping` and default to `{ _ in }`
   (no-capture no-ops). Consumers opt in by supplying their own.
2. **Handler assignment sites** — no Cosmos source *assigns* a config `handler` field outside the
   config's own `init` (the defaults). `grep -rn '\.handler =\|handler:' Sources/Cosmos/` returns
   nothing in atoms/modifiers except SwiftUI's own `OpenURLAction(handler:)`.
3. **Body construction** — `grep -rn 'CosmosConfiguration(' Sources/Cosmos/` outside
   `Base/Configuration/` and `Modifiers/` returns **nothing**: no atom constructs a
   `CosmosConfiguration` literal in `body`. Atoms read `@Environment(\.cosmosConfiguration)` and
   invoke `configuration.*.handler(...)` (a read of the stored closure); they never rebuild the
   config.
4. **Override path** — every `.cosmos*` config modifier uses `configuration.with*()` (copy) +
   `.environment(\.cosmosConfiguration, …)` (reinject). Verified in
   `Sources/Cosmos/Modifiers/CosmosHapticsAndTrackingModifiers.swift`:
   `content.environment(\.cosmosConfiguration, configuration.withHaptics(haptics))` /
   `…withMotion(motion)`. This is the sanctioned copy-and-reinject path; it only re-injects when
   the modifier is actually applied to a subtree, not on every body recompute.

## Conclusion

The Cosmos side is clean: handlers are consumer-supplied no-ops by default, atoms only read them,
and no config is constructed in a `body`. The **only** remaining churn vector is a *consumer*
passing a closure that captures env-derived state — that is a documented consumer responsibility,
not a Cosmos defect. No code change warranted.

## Related

- [[cosmos-org-audit-2026-07]] — the broader org/audit pass this fed into.
- [[unwired-accessibility-gates]] — another recently-closed risk (a11y gates now wired through
  policy chokepoints).