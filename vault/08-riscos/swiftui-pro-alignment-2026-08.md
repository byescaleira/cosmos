---
tags: [audit, swiftui-pro, alignment, methodology, deprecated-atoms]
aliases: [swiftui-pro exhaustive sweep 2026-08, Cosmos strict alignment]
related: [cosmos-audit-2026-07-24, swiftpm-no-string-catalog-symbol-codegen, cosmos-card, cosmos-image]
---

# Audit — exhaustive `/swiftui-pro` whole-library sweep (2026-08-03)

## Context

Follow-up to the strict `/swiftui-pro` alignment plan (`nao-eu-quero-fazer-graceful-pillow.md`),
which delivered findings A1–A3 / B / C / D / E / F and was applied across the prior session. This
note covers the **exhaustive whole-library re-sweep** triggered by "is there anything more to
improve based on /swiftui-pro" — a 33-agent Workflow (9-dimension sweep + adversarial verify +
completeness critic, ~1.25M tokens) over all 85 `Sources/` files.

## Method (worth reusing)

- **pipeline** sweep→verify per dimension (no barrier between stages — each finding verified as
  soon as its dimension's review completes). 9 dimensions: api / views / data / navigation /
  design / accessibility / performance / swift / hygiene.
- **Adversarial verify**: each finding gets an independent skeptic prompted to refute (default
  `refuted`). Survivors = `confirmed`.
- **Completeness critic**: a final agent asks "what's missing — modality not run, claim
  unverified?" Its fresh findings get a second adversarial verify pass → `criticConfirmed`.
- **Disagreement handling**: when the first verify pass and the critic verify pass disagreed, the
  tie-breaker was the binding reference text itself (does the reference state the rule?), resolved
  toward strict alignment — see the two contested clusters below.

## Confirmed findings applied (14)

### api (3)
- `CosmosCard.swift:65` — `.overlay(CosmosCardBorder())` → `.overlay { CosmosCardBorder() }`
  (closure-form `overlay(alignment:content:)` over the deprecated View-arg `overlay(_:alignment:)`).
- `CosmosTextField.swift:260` — `.overlay(RoundedRectangle(...).strokeBorder(...))` → closure form.
- `CosmosScrollView.swift:94` — `ScrollView(axes, showsIndicators:)` → drop the arg +
  `.scrollIndicators(showsIndicators ? .visible : .hidden)` (universal-floor modifier; the file's
  own doc comment lists `.scrollIndicators` as floor on all 5 platforms).

### design (2)
- `CosmosToast.swift:63` — hard-coded `.padding(5)` (off the 4-pt grid, the only literal numeric
  padding in the library) → `.padding(CosmosSpacingTokens.small)` (8).
- `CosmosToastModifier.swift:233/240/243` — hard-coded `cornerRadius: 32` magic number ×3, not on
  `CosmosRadiusTokens` → new **`CosmosRadiusTokens.toast` = 32** token (component alias, like
  `.card`); all three sites now read the single source of truth.

### accessibility (1)
- `CosmosRedactedModifier.swift:17` — hard-coded English `.accessibilityLabel("Loading")` → routed
  through `configuration.localization.string(for: "Loading") ?? "Loading"`. The `"Loading"` key
  exists in `Localizable.xcstrings` (en `Loading…` / pt-BR `Carregando…`), so non-English VoiceOver
  users now hear the localized form (and English gets the ellipsis).

### swift (4)
- `CosmosLocalizationConfiguration.swift:129` — `replacingOccurrences(of:with:)` → `replacing(_:with:)`
  (Swift-native; behavior-identical for ASCII `_`→`-`).
- `CosmosTrackingConfiguration.swift:30`, `CosmosLogConfiguration.swift:18`,
  `CosmosErrorConfiguration.swift:14` — `date: Date = Date()` → `Date.now` (swift.md clarity rule).

### hygiene (4)
- `CosmosLocalizedText.swift` (live atom) — added 4 co-located `#Preview(_:traits:)` blocks
  (default / pt-BR locale / dark+Dynamic-Type / RTL) mirroring `CosmosText`.
- `CosmosAsyncImage.swift`, `CosmosCard.swift`, `CosmosIcon.swift` (deprecated atoms) — each gained
  minimal co-located `#Preview` blocks. The deprecation carve-out shields the *mere deprecation*
  but explicitly requires deprecated atoms to keep complying with binding guidelines while
  shipping; missing previews is such a gap.

## Two contested clusters (first-pass refuted, critic confirmed — applied)

1. **`Date()` → `Date.now` (3 sites).** First-pass verifiers refuted as "style preference, no
   behavioral impact"; the critic verifiers confirmed citing `swift.md:11` "Prefer `Date.now` over
   `Date()` for clarity." Tie-breaker: the reference *does* state the preference, and under strict
   alignment the change is safe (functionally identical) and aligns with the documented rule →
   applied. Low-severity clarity, not correctness.

2. **Previews on deprecated atoms (CosmosIcon/Card/AsyncImage).** First-pass refuted
   CosmosIcon's previews as "dev tooling, not a runtime binding guideline; deprecated atoms being
   removed soon don't need them"; critic confirmed via the carve-out's own "must still comply
   with binding guidelines while shipping" clause. Tie-breaker: CLAUDE.md states "Co-located
   `#Preview` blocks at the bottom of each atom file" in binding language, and the carve-out
   agrees → applied (minimal previews).

## The `@available(*, deprecated)` on `#Preview` pattern

A deprecated atom constructed inside a `#Preview` would emit a deprecation warning and break the
zero-warnings build. Solution: annotate the `#Preview` block itself with the matching
`@available(*, deprecated, message:)` passthrough — the preview becomes a deprecated context, so
the deprecated-atom call inside it is warning-free, and the preview runtime invokes it
reflectively (no explicit non-deprecated call site to warn). Verified: host build is warning-free,
iOS cross-build `** BUILD SUCCEEDED **`. This mirrors the `@available(*, deprecated)` passthrough
already used on the deprecated-atom test functions (`CosmosCardTests` / `CosmosIconTests` /
`CosmosAsyncImageTests`).

```swift
@available(*, deprecated, message: "Preview exercises deprecated CosmosCard during the removal runway.")
#Preview("CosmosCard – deprecated", traits: .sizeThatFitsLayout) { … }
```

## Verification (end-to-end)

- `swift build` — zero concurrency/warnings.
- `swift test --enable-code-coverage` — 370 tests / 44 suites pass.
- `swift build -c release` — green (no release type-checker timeout from the new previews/tokens).
- `xcrun xcodebuild -scheme Cosmos -destination 'generic/platform=iOS' build` —
  `** BUILD SUCCEEDED **` (the `.scrollIndicators` universal-floor change compiles off-host).

## What was refuted and correctly dropped

- CosmosCard shadow `y: 4` tokenization (design) — DRY/consistency style preference, not a
  binding rule; `shadowRadius`/`shadowOpacity` are already in `CosmosMotionTokens` and the offset
  is a fixed visual constant. Refuted.
- 3× `if let v = x` → `if let x` shorthand in `CosmosAccessibilityModifiers.swift` (swift) — pure
  style preference, no reference rule mandates shorthand; the file is consistently explicit. Refuted.
- Force-unwrap in `CosmosMock.swift:62` (swift) — provably safe (preceding `guard !pool.isEmpty`);
  no binding rule bans force-unwrap. Refuted.

## Reused utilities

- `CosmosPreviewContainer` + `.cosmosPreviewEnv(...)` / `.cosmosPreviewVariant(_:)` — preview env
  injection (the 7 directly-settable keys compose via `ifLet`; the 5 underscore-SPI accessibility
  keys are on the `AnyView` tail — the documented A3 carve-out, untouched here).
- `@available(*, deprecated)` passthrough — deprecation-warnings-as-failure suppression (tests +
  now previews).
- `CosmosRadiusTokens` component-alias pattern (`.card`, now `.toast`) — single source of truth
  for per-component rounding.

## Outcome

The library is now exhaustively aligned with `/swiftui-pro` across all 9 dimensions. The re-sweep
found only 14 confirmed findings (3 api / 2 design / 1 a11y / 4 swift / 4 hygiene), all applied and
verified — no `AnyView`/`GeometryReader`/computed-`some View` regressions, Sendable/@MainActor
isolation intact. The next sweep dimension to invest in is **none** — the surface is clean; future
work is feature-driven, not alignment-driven.