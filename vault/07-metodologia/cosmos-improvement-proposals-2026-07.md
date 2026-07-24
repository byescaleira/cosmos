---
tags: [methodology, roadmap, improvement-proposals, cosmos, research]
aliases: [cosmos improvement proposals 2026-07, cosmos improvement backlog, cosmos 0.7 candidates]
related: [[cosmos-org-audit-2026-07]], [[unwired-accessibility-gates]], [[adr-atoms-impose-theme-defaults]], [[cosmos-toast]], [[button-shapes-ios26-liquid-glass]]
---

# Cosmos — Improvement proposals (2026-07)

**Date:** 2026-07-23 · **Status:** Proposal backlog (research-grounded, not yet implemented) · **Follows:** [[cosmos-org-audit-2026-07]] (the cleanup that produced the 0.6.0 spine)

This is the "improve what already exists" backlog — **31 concrete, codebase-grounded proposals** synthesized from 5 parallel research passes (accessibility, motion, performance/SwiftUI idioms, testing, docs/localization/layout). Each proposal is grounded in a specific Apple HIG / WWDC / SwiftUI-doc citation and a specific `file:line` in the current Cosmos source. The source of truth stays the root docs; this note is the planning/navigation layer.

> **Two real bugs surfaced during research** (not just improvements): the **toast tint bug** (`role.tint` declared but never applied — toasts are monochrome by accident, see A3) and the **iOS 26 `accessibilityShowButtonShapes` → `accessibilityShowBorders` rename** that CLAUDE.md still references by the old name (see A6). Fix both regardless of which proposals are adopted.

## Master prioritization table

Ranked by **impact ÷ (effort × risk)**, with a recommended wave grouping at the end.

| # | Area | Title | Effort | Impact | Risk | Wave |
|---|---|---|---|---|---|---|
| A1 | A11y | `CosmosAccessibilityPolicy` chokepoint + `respect*` config flags (foundation) | S | high | low | 1 |
| A3 | A11y | Wire `differentiateWithoutColor` + **fix toast tint bug** | M | high | low-med | 1 |
| P1 | Perf | `@ViewBuilder` the 4 motion `ViewModifier` bodies (drop `AnyView`) | S | high | low | 1 |
| P2 | Perf | `@ViewBuilder` the haptic/selection/toast modifiers | S | med | low | 1 |
| T3 | Test | Tests for 3 zero-coverage atoms (SecureField, AdaptiveStack, LocalizedText) | S | high | low | 1 |
| T2 | Test | Behavior tests for 13 uncovered atoms | M | high | low | 1 |
| M4 | Motion | Keep `.blurReplace` active under reduce-motion `.substitute` (vestibular-safe) | S | med | low | 1 |
| A5 | A11y | `.showBorders` preview variant + complete the preview matrix | S | med | low | 2 |
| M3 | Motion | `cosmosWithAnimation(_:body:completion:)` coordinated-transition chokepoint | M | high | low | 2 |
| D1 | DocC | Enable `swift-docc-plugin` + curation catalog | M | high | low | 2 |
| D3 | L10n | Add `comment` keys to every `.xcstrings` entry | S | med | low | 2 |
| D6 | Layout | Replace magic `420` toast width with a theme token | S | low | low | 2 |
| D7 | Layout | Landscape reflow `#Preview` coverage across atoms | S | med | low | 2 |
| T4 | Test | `@Test(arguments: XxxStyle.allCases)` for style appliers | S | med | low | 2 |
| M1 | Motion | Migrate `cosmosInteractive` to `Spring(duration:bounce:)` + velocity gesture spring | S | med | low | 2 |
| A2 | A11y | Wire `accessibilityShowBorders` into `.ghost`/borderless buttons | M | high | low-med | 3 |
| P3 | Perf | `@ViewBuilder` the preview environment accumulator | S | low | low | 3 |
| D2 | DocC | Doc the 5 undocumented public types + `@Tutorial` | S | med | low | 3 |
| D4 | L10n | Pluralization + device variations in the String Catalog | M | med | low | 3 |
| D5 | Layout | `CosmosAdaptiveStack` in Card/Toast + `ViewThatFits` | M | med | med | 3 |
| T6 | Test | `.tags` for cross-cutting test selection | S | med | low | 3 |
| T7 | Test | `.disabled(if:)` traits over `#if os()` guards | S | med | low | 3 |
| A4 | A11y | Wire `colorSchemeContrast` via `ShapeStyle.resolve(in:)` for adaptive surfaces | L | high | med | 4 |
| P6 | Perf | Audit closure-bearing `CosmosConfiguration` for environment-churn | M | med-high | med | 4 |
| M2 | Motion | Liquid Glass motion: `.glassMorph` + zoom-navigation helpers | M | high | med | 4 |
| T1 | Test | Per-atom `@Suite` convention; fold 3 axes | L | high | med | 4 |
| T5 | Test | Parameterized style × platform availability matrices | M | med | med | 4 |
| A6 | A11y/Docs | Update CLAUDE.md + config docs to iOS 26 gate names; remove "tracked gap" notes | S | low | low | 4 |
| M5 | Motion | SF Symbols 6 effect presets (wiggle/rotate/breathe) gated on `isEnabled` only | M | med | low | 4 |
| P4 | Perf | `CosmosAsyncImage`: generic slot inits, stop `AnyView`-wrapping default slots | M | med | med | 5 |
| P5 | Perf | `CosmosProgress.Storage`: drop `AnyView?` label, go generic over `Label` | M | low-med | med | 5 |

**Wave summary:** Wave 1 = high-impact / low-risk foundations + the two bug fixes. Wave 2 = chokepoints, infra (DocC), preview coverage. Wave 3 = atom-level wiring + generics. Wave 4 = the large/risky surfaces (contrast, environment-churn, Liquid Glass motion, test reorg). Wave 5 = public-API-shaping generics (deprecation runway).

---

## Area A — Accessibility (wire the 3 unwired gates)

Mirrors the existing `CosmosMotionPolicy` chokepoint pattern. Closes [[unwired-accessibility-gates]].

### A1 — `CosmosAccessibilityPolicy` chokepoint + `respect*` config flags (foundation)
- **Today:** `CosmosMotionPolicy` (`Base/Environment/CosmosMotionHelpers.swift:5-21`) is the chokepoint for reduce-motion/transparency; **no analogue** for the other 3 gates. `CosmosAccessibilityConfiguration` (`Base/Configuration/CosmosAccessibilityConfiguration.swift:26-59`) holds only label/hint/value/traits — no `respect*` flags, no policy enum. Its doc comment (lines 18-22) admits the gap.
- **Research:** Apple's pattern is a `respect*` knob per gate so apps can override (WWDC20-10020 "Make your app visually accessible"). `CosmosMotionPolicy` is the project-sanctioned shape (CLAUDE.md).
- **Change:** New `CosmosAccessibilityPolicy` (`shouldIncreaseContrast` / `shouldDifferentiateWithoutColor` / `shouldShowBorders`) + 3 `Bool` flags (default `true`) on `CosmosAccessibilityConfiguration` + `.cosmosRespect*(_:)` per-instance overrides mirroring `.cosmosMotion(_:)`. Keep `Sendable`. Update the doc comment to describe wired behavior.
- **E:** S · **I:** high (unblocks A2-A4) · **R:** low. **Verify:** unit tests on the pure functions (template: `CosmosMotionPolicy.shouldEmit` tests).

### A2 — Wire `accessibilityShowBorders` (née `accessibilityShowButtonShapes`) into `.ghost`/borderless buttons
- **Today:** `CosmosButtonChrome.ChromeBody` (`Atoms/CosmosButton.swift:141-203`) renders `.ghost` with `chromeBackground = Color.clear` (lines 189-192) — **no read** of the show-shapes gate (only `accessibilityReduceMotion` at line 149). `.primary`/`.secondary`/`.danger` already have tinted glass; `.glass` routes to native styles (Apple handles it). Only the custom-chrome `.ghost` is truly borderless.
- **Research:** SwiftUI docs — "interactive custom controls such as buttons should be drawn so their edges and borders are clearly visible." WWDC20-10020: "If your default design doesn't include button shapes, provide an alternate appearance when the setting is enabled." **Critical:** a custom `ButtonStyle` can break Apple's default Button Shapes overlay — must read the env and draw the shape yourself (Stack Overflow 77286536). iOS 26 renamed `accessibilityShowButtonShapes` → `accessibilityShowBorders` (`@backDeployed` to iOS 14+; on macOS true when Increased Contrast is on).
- **Change:** Read `@Environment(\.accessibilityShowBorders)` + `cosmosConfiguration.accessibility.respectShowBorders` via `CosmosAccessibilityPolicy.shouldShowBorders(...)`; when true **and** `variant == .ghost`, draw a subtle `Capsule().stroke(theme.colors.outline)`. Shape-consistent with the capsule design rhythm ([[button-shapes-ios26-liquid-glass]]). No `if #available` (back-deployed).
- **E:** M · **I:** high · **R:** low-med. **Verify:** `#Preview` with `.cosmosPreviewEnv(showButtonShapes: true)` across the 4 custom variants; unit test on `shouldShowBorders`; watchOS/tvOS where `.ghost` is common. **⚠ Verify `accessibilityShowBorders` back-deployment against the Xcode 26 SDK header before shipping.**

### A3 — Wire `accessibilityDifferentiateWithoutColor` + **fix the toast tint bug** ⚠
- **Today:** State-bearing atoms using color as the sole state signal: `CosmosToastContent` (success/warning/error, `Atoms/CosmosToast.swift:4-49`) and `CosmosButton` `.danger` (`Atoms/CosmosButton.swift:185-188`). Neither reads `accessibilityDifferentiateWithoutColor`. **Latent bug:** `role.tint` is declared (`Modifiers/CosmosToastModifier.swift:29,34`) but **never applied** — `CosmosToast.swift:42-46` renders `Image(systemName: role.icon)` with no `.foregroundStyle(...)`. The semantic color is dropped entirely; only the SF Symbol shape differentiates roles.
- **Research:** HIG (Convey information with more than color alone); App Store Connect "Differentiate Without Color Alone" criteria (test with the Grayscale filter); SwiftUI `accessibilityDifferentiateWithoutColor` doc — "UI should not convey information using color alone."
- **Change:** (1) **Fix the tint bug regardless of the gate** — apply `role.tint` to the toast icon (resolve `CosmosToastTint` → `theme.colors.success`/`.warning`/`.error`/`.accent`). (2) Gate a guaranteed non-color differentiator through `shouldDifferentiateWithoutColor(...)`: for toasts the symbol already exists (document `CosmosToastRole.icon` as the non-color contract — must not be emptied); for `.danger` buttons add a leading `exclamationmark.triangle` when the gate is active. (3) Add an `accessibilityValue`/`accessibilityLabel` so VoiceOver announces the role (the icon is currently `accessibilityHidden(true)` and the role is never announced).
- **E:** M · **I:** high (color-blind users + fixes a real bug) · **R:** low-med (toast appearance changes once tint is applied — correct, since the current behavior is an accidental bug). **Verify:** `#Preview` with `.cosmosPreviewEnv(differentiateWithoutColor: true)` across the 4 roles; grayscale-filter preview; VoiceOver announces the role.

### A4 — Wire `colorSchemeContrast` via `ShapeStyle.resolve(in:)` for adaptive surfaces/outlines
- **Today:** `CosmosColorTokens` (`Base/Theme/CosmosColorTokens.swift:14-67`) builds semantic colors on system colors (auto-adapt). But **synthetic** low-contrast surfaces — `CosmosCard` 1pt outline (`Atoms/CosmosCard.swift:88-91`), `CosmosToast` material chrome (`Modifiers/CosmosToastModifier.swift:145-158`), `CosmosProgress` 0.4-opacity track (`Atoms/CosmosProgress.swift:149-155`) — **never read `colorSchemeContrast`** and never call `ShapeStyle.resolve(in:)`. So hairline borders / translucent tracks don't strengthen under Increase Contrast. `CosmosColorTokens.swift:10-12` admits the gap.
- **Research:** WWDC20-10020 (system colors auto-adapt; non-system surfaces must be aware); App Store Connect "Sufficient Contrast" (≥4.5:1 text, ≥3:1 non-text/state); Deque recommends adding borders around controls under Increase Contrast. `ShapeStyle.resolve(_:in:)` (iOS 17+, ≤ 26 on all 5 platforms — no `if #available`) is the idiomatic entry point.
- **Change:** Internal `CosmosAdaptiveOutline` helper that, under `shouldIncreaseContrast(...)`, returns a 2pt higher-contrast border (resolved via `ShapeStyle.resolve`) + bumps the progress track opacity to 1.0. Apply in `CosmosCard.cardBorder`, `CosmosProgressChromeBody.trackFillOpacity` (mirrors the existing `shouldCollapseTransparency` pattern), toast chrome border. Targets the synthetic surfaces (system-color tokens already adapt).
- **E:** L · **I:** high (low-vision; hairlines/tracks are the weakest-contrast elements) · **R:** med (visual-regression across 5 platforms × light/dark). **Verify:** `#Preview("… – increased contrast")` via `.cosmosPreviewVariant(.increasedContrast)`; Accessibility Inspector Color Contrast Calculator ≥3:1; light+dark × increased-contrast matrix; watchOS/visionOS where `cosmosSurface` is `Color.gray.opacity(0.2)` (weakest, highest priority).

### A5 — `.showBorders` preview variant + complete the preview matrix
- **Today:** `CosmosPreviewVariant` (`Base/Preview/CosmosPreview.swift:28-38`) has `.increasedContrast`/`.differentiateWithoutColor` but **no `.showBorders` case**, though the SPI already accepts `showButtonShapes:`. No atom has a `#Preview` exercising any of the 3 gates (grep: only `.reduceMotion`/`.reduceTransparency` previews on `CosmosProgress.swift:219-227`, `CosmosToast.swift:104-112`).
- **Research:** WWDC20-10020 — test all settings together (Light/Dark × Increase Contrast × Reduce Transparency × Button Shapes × Differentiate Without Color × Bold Text). Apple's preview tooling exposes these via the same underscore SPI Cosmos already uses.
- **Change:** Add `case showBorders` to `CosmosPreviewVariant`, wire to `.cosmosPreviewEnv(showButtonShapes: true)`. Add co-located `#Preview` blocks to every atom touched by A2-A4 (default / increasedContrast / differentiateWithoutColor / showBorders × light + dark). One named `#Preview` per variant per atom (CLAUDE.md).
- **E:** S · **I:** med (enables verification for A2-A4) · **R:** low.

### A6 — Update CLAUDE.md + config docs to iOS 26 gate names; remove "tracked gap" notes
- **Today:** CLAUDE.md references the deprecated `accessibilityShowButtonShapes`. `CosmosAccessibilityConfiguration.swift:18-22` and `CosmosColorTokens.swift:10-12` carry "tracked gap" comments that go stale as A1-A4 land.
- **Research:** iOS 26 SDK deprecates `accessibilityShowButtonShapes` → `accessibilityShowBorders` (back-deployed to iOS 14+; on macOS true when Increased Contrast is on). Cosmos versioning: "available since Cosmos 26 == `@available(iOS 26, *)`" — author the new name, rely on back-deployment.
- **Change:** Update CLAUDE.md's gate list to `accessibilityShowBorders` (note back-deployment + macOS equivalence). As each proposal lands, delete the "tracked gap" sentence and replace with the wired-behavior description (mirror `CosmosMotionConfiguration`). Update [[unwired-accessibility-gates]] to mark each gate resolved + add ADRs in `vault/02-decisoes/` (each of A2-A4 "needs its own ADR-sized decision" per the risk note).
- **E:** S · **I:** low (docs) · **R:** low. **Verify:** `grep` confirms no remaining "tracked gap" / deprecated name references after wiring lands.

---

## Area M — Motion (refinements, not a rebuild)

The motion subsystem is sound; these are targeted refinements preserving `CosmosMotionTokens.animation(for:reduceMotion:policy:)` (single source of truth) and `CosmosMotionPolicy`.

### M1 — Migrate `cosmosInteractive` to `Spring(duration:bounce:)` + a velocity-carrying gesture spring
- **Today:** `Base/Theme/CosmosMotionTokens.swift:28` — `cosmosInteractive` is the **only** preset still on the legacy `Spring(response:dampingRatio:)` form; the other 4 already use `Spring(duration:bounce:)`. `CosmosSpring.init(response:dampingRatio:)` is retained solely for it.
- **Research:** WWDC23-10158 "Animate with springs" introduces `Spring(duration:bounce:)` as the recommended simpler form; explicitly notes the velocity-preservation property on retarget. The two forms are mathematically equivalent.
- **Change:** Replace `.init(response: 0.3, dampingRatio: 0.7)` with `.init(duration: 0.3, bounce: 0.3)` (verify via `Spring.value(target:time:)` in a test). Optionally add a `CosmosMotionKind.gesture` backed by a velocity-carrying spring (`Animation.spring(spring)`). Deprecate `CosmosSpring.init(response:dampingRatio:)` with a migration runway (keep for the 26 minor).
- **E:** S · **I:** med · **R:** low (curve mathematically identical). **Verify:** `springPresetsDistinct` still passes; add `springInteractiveEquivalentToLegacy`.

### M2 — Liquid Glass motion: `.glassMorph` transition + zoom-navigation helpers
- **Today:** `glassEffect` is used (`Atoms/CosmosButton.swift:168`, `Modifiers/CosmosToastModifier.swift:149`) but **none** of `glassEffectTransition`, `glassEffectID`, `GlassEffectContainer`, `matchedTransitionSource`, `navigationTransition(.zoom)`, `GlassEffectTransition` appear anywhere. `CosmosTransition` has no glass-aware case. All unconditionally available at `.v26` (CLAUDE.md).
- **Research:** WWDC25-323 "Build a SwiftUI app with the new design" — zoom-navigation: `.matchedTransitionSource(id:in:)` + `.navigationTransition(.zoom(sourceID:in:))`; `GlassEffectContainer` + `.glassEffectID` + `.glassEffectTransition(.matchedGeometry)` for glass-to-glass morphs. WWDC25-356 frames it as "continuity: relationships depicted by how surfaces stay connected to their source."
- **Change:** Add `case glassMorph` to `CosmosTransition` (resolves `nil` sentinel like `.blurReplace`; applied via the generic `.transition<T>`). Add `cosmosZoomTransitionSource(id:in:)` (source marker, no gate) + `cosmosNavigationZoom(sourceID:in:)` (gated through `CosmosMotionPolicy.shouldEmit` so reduce-motion collapses). Keep the resolver intact.
- **E:** M · **I:** high (Liquid Glass is the .v26 identity; currently absent) · **R:** med (new API; `@Namespace` threading; verify zoom kind on watchOS/tvOS). **Verify:** new `@MainActor @Test` mirroring the blurReplace tests; `#Preview` for button→sheet zoom (default/reduceMotion/reduceTransparency/dark/landscape).

### M3 — `cosmosWithAnimation(_:body:completion:)` coordinated-transition chokepoint
- **Today:** No `withAnimation` helper exists. 4 atoms document raw `withAnimation` at call sites — `CosmosGroupBox.swift:22-23`, `CosmosTabView.swift:65-66`, `CosmosSelectableList.swift:54`, `CosmosSection.swift:44` — bypassing `CosmosMotionPolicy.shouldEmit`, not firing the motion `handler`, no completion hook.
- **Research:** `withAnimation(_:completionCriteria:_:completion:)` shipped iOS 17 (fires completion exactly once). CLAUDE.md mandates "one `withAnimation` per coordinated state change." WWDC23-10156 "Explore SwiftUI animation."
- **Change:** Add `cosmosWithAnimation(_:completionCriteria:body:completion:)` to `CosmosMotionHelpers.swift`. Gate via `shouldEmit`; if suppressed, run `body` with no animation + fire `completion` immediately. Fire `configuration.motion.handler(.motion(kind))` once. Wraps `withAnimation(...)`. Replaces the raw-`withAnimation` pattern in 4 atoms — closes the one un-gated motion path.
- **E:** M · **I:** high · **R:** low (additive; existing call sites keep working until migrated). **Verify:** `cosmosWithAnimationFiresHandler`, `cosmosWithAnimationSkipsUnderReduceMotionInstant`, `cosmosWithAnimationCompletionFiresOnce`; `#Preview` in `CosmosTabView` (default + reduceMotion).

### M4 — Keep `.blurReplace` active under reduce-motion `.substitute` (it is vestibular-safe)
- **Today:** `Base/Environment/CosmosMotionHelpers.swift:76-78` — `.blurReplace` only applies when `!shouldReduce`; under reduce-motion `.substitute` it falls through to `.opacity`. A vestibular-safe content crossfade is collapsed to plain opacity whenever Reduce Motion is on.
- **Research:** WWDC23-10157 "Wind your way through advanced animations" — `BlurReplaceTransition` has **no spatial component** (blurs out, resolves in place). HIG Motion distinguishes spatial motion (vestibular risk) from non-spatial opacity/blur crossfades (the recommended substitute). `symbolEffect` already auto-respects Reduce Motion by the same principle (WWDC23-10258). `.blurReplace` is the closest non-symbol equivalent and should be treated the same — gate on `isEnabled` only.
- **Change:** Guard so `.blurReplace` applies whenever `configuration.motion.isEnabled` (regardless of reduceMotion/respectReduceMotion), matching the `symbolReplace` treatment at lines 98-100. Keep `.instant` → `.identity` winning (the explicit no-transition override).
- **E:** S · **I:** med (better Reduce Motion UX — content swap stays legible) · **R:** low (only enriches under Reduce Motion + `.substitute`). **Verify:** update `transitionBlurReplaceSubstitutesUnderReduceMotion`; `#Preview` for `CosmosAsyncImage` (heaviest blurReplace user) under reduceMotion shows blur crossfade, not hard opacity cut.

### M5 — SF Symbols 6 effect presets (wiggle/rotate/breathe) gated on `isEnabled` only
- **Today:** `CosmosContentTransitionPreset` (`CosmosMotionTokens.swift:150-165`) has 4 cases; only `.symbolReplace` is a symbol effect. The WWDC24 SF Symbols 6 effects (wiggle/rotate/breathe) aren't represented; consumers write raw `.symbolEffect(...)` which bypasses the `isEnabled`-only gate. `CosmosIcon.swift:24` and `CosmosLink.swift:23` tell callers to manage `.symbolEffect` themselves.
- **Research:** WWDC24-10188 "What's new in SF Symbols 6" — Wiggle/Rotate/Breathe universal presets. All are symbol effects → auto-respect Reduce Motion (WWDC23-10258) → gate on `isEnabled` only, never double-gate on `respectReduceMotion` (CLAUDE.md states this rule but the codebase only enforces it for `.replace`).
- **Change:** New `CosmosSymbolEffectPreset` enum (bounce/pulse/scale/variableColor/wiggle/rotate/breathe/replace) + `cosmosSymbolEffect(_:options:isActive:value:)` `View` extension gated on `configuration.motion.isEnabled` only.
- **E:** M · **I:** med · **R:** low (additive; all iOS 17/18 ≤ 26, no availability gates). **Verify:** `symbolEffectPresetsAllAreSymbolEffects`, `symbolEffectGatedOnIsEnabledOnly`; `#Preview` in `CosmosIcon` (default/reduceMotion/disabled).

---

## Area P — Performance & SwiftUI idioms (drop gratuitous `AnyView`)

86 `AnyView` hits total. The wrap-View atoms (`CosmosSlider`/`CosmosSelectableList`/`CosmosTabView`) legitimately type-erase in inits (structurally-different concrete native types per init — documented, **keep**). The gratuitous sites are all in `ViewModifier.body` early-returns and the preview accumulator, where `@ViewBuilder` + `some View` preserves identity at zero cost.

### P1 — `@ViewBuilder` the 4 motion `ViewModifier` bodies
- **Today:** `Base/Environment/CosmosMotionHelpers.swift` — `CosmosAnimationModifier.body` (46-57), `CosmosTransitionModifier.body` (67-84), `CosmosContentTransitionModifier.body` (95-110), `CosmosStaggerModifier.body` (127-142) each early-return `AnyView(content)` / `AnyView(content.<mod>)`. The comment on line 37-38 says the only rationale is "consistency" with another gratuitous site. These attach to **every atom** (motion is cross-cutting) — the cost is paid app-wide.
- **Research:** Apple `AnyView` docs — "Whenever the type of view used with an AnyView changes, the old hierarchy is destroyed and a new one is created." WWDC21-10022 "Demystify SwiftUI" — use `@ViewBuilder` so `if`/`switch` compile to `_ConditionalContent`, preserving structural identity. WWDC23-10160 — "avoid `AnyView` and conditional views inside ForEach."
- **Change:** Mark each `body` `@ViewBuilder`, drop every `AnyView`. E.g. `guard … else { return content }; return content.animation(animation, value: value)`. The `BlurReplaceTransition` concrete-`Transition` path works under `@ViewBuilder` via the generic `.transition<T>(_:)`. All modifiers are `private` — no public API change.
- **E:** S · **I:** high (attach to every atom) · **R:** low. **Verify:** `swift build && swift test && swift build -c release`; per-platform; motion tests cover gating.

### P2 — `@ViewBuilder` the haptic / selection / toast modifiers
- **Today:** `Base/Environment/CosmosHapticsHelpers.swift` `CosmosHapticFeedbackModifier.body` (43-58), `Atoms/CosmosToggle.swift` `CosmosToggleSelectionHapticModifier.body` (177-180), `Modifiers/CosmosToastModifier.swift` `OptionalHapticModifier.body` (201-204) — all `guard … else { return AnyView(content) }; return AnyView(content.cosmosHaptic(...))`. This is the "existing pattern" P1 cites as its rationale — fix together.
- **Research:** same as P1.
- **Change:** `@ViewBuilder` each body; replace `AnyView` returns with `return content` / `return content.cosmosHaptic(...)`. All `private` — no public API impact.
- **E:** S · **I:** med (haptic modifiers attach to most interactive atoms) · **R:** low.

### P3 — `@ViewBuilder` the preview environment accumulator
- **Today:** `Base/Preview/CosmosPreview.swift` — `CosmosPreviewContainer.body` (61-73), `View.cosmosPreviewEnv(...)` (99-114, up to 12 `if let` reassignments through `AnyView`), `View.cosmosPreviewVariant(_:)` (117-138). The largest `AnyView` cluster (16 hits in one file); every site is a conditional `@ViewBuilder` handles natively. Preview path is not a shipping hot path, so perf impact is low.
- **Research:** WWDC21-10022 — `@ViewBuilder` is the prescribed tool for conditional composition; preserves the full `_ConditionalContent` tree.
- **Change:** `@ViewBuilder` `cosmosPreviewEnv` (12 `if let`s collapse into one `_ConditionalContent` tree), `cosmosPreviewVariant`, `CosmosPreviewContainer.body`. Public signatures stay `some View`; behavior identical.
- **E:** S (M if the 12-branch chain needs careful nesting) · **I:** low (preview-only) · **R:** low. **Verify:** preview matrix (default/dark/largestText/boldText/rtl/reduceMotion/reduceTransparency/increasedContrast/differentiateWithoutColor) still renders.

### P4 — `CosmosAsyncImage`: generic slot inits, stop `AnyView`-wrapping default slots
- **Today:** `Atoms/CosmosAsyncImage.swift` — stored closures `placeholder: () -> AnyView` (66), `failure: (...) -> AnyView` (67). Default init wraps concrete defaults (`AnyView(CosmosAsyncImagePlaceholder())`, etc.). Custom-slot inits force callers to hand-wrap (`AnyView(Color.gray.opacity(0.15))`). The default path erases a *known concrete* type — unnecessary. Design trade-off (single-generic) but the default path is gratuitous.
- **Research:** WWDC21-10022 — `AnyView` is fine when you actually want to erase; prefer generics when you don't.
- **Change:** Make the atom generic over `Placeholder: View` and `Failure: View` (`CosmosAsyncImage<Content, Placeholder, Failure>`). Default init constrains to the concrete Cosmos types (no `AnyView`). Custom-slot inits take `@ViewBuilder` typed closures. Keep one deprecated `AnyView`-based init as an escape hatch or drop if the 3-generic surface is acceptable. **Public API change → deprecation runway** (`VERSIONING.md`).
- **E:** M · **I:** med (every `CosmosAsyncImage` sheds per-phase erasure; phase swaps under `blurReplace` keep identity) · **R:** med (init signatures change; `failure` slot needs `error`+`retry` params as a generic view built in init). **Verify:** async-image tests + previews (303-379) render identically; update the custom-slot preview to drop `AnyView(...)`.

### P5 — `CosmosProgress.Storage`: drop `AnyView?` label, go generic over `Label`
- **Today:** `Atoms/CosmosProgress.swift` — `private enum Storage { case indeterminate(label: AnyView?); case determinate(..., label: AnyView?) }` (24-27). Every init erases (`AnyView(label())`, `AnyView(CosmosLocalizedText(key:))`). Borderline — unlike the wrap-View atoms, there's no structural-type incompatibility forcing erasure (the label is a single view).
- **Research:** WWDC21-10022 — prefer parameterized views over `AnyView` when the type varies but isn't structurally incompatible.
- **Change:** `CosmosProgress<Label: View>` with `where Label == EmptyView` (no-label) / `where Label == CosmosLocalizedText` (title-key) / generic custom-`@ViewBuilder` init. Remove `Storage`'s `AnyView?`. Lowest priority of the six — **fallback:** keep `Storage` as-is (most defensible erasure site) if the team prefers a simpler public surface.
- **E:** M · **I:** low-med · **R:** med (init signatures shift; `CosmosProgressChrome.makeBody` reads `configuration.label` unchanged). **Verify:** progress previews + chrome branch compile; deprecation runway.

### P6 — Audit closure-bearing `CosmosConfiguration` for environment-churn
- **Today:** Not an `AnyView` issue — it's the WWDC26-flagged environment-churn pattern. `CosmosConfiguration` carries `@Sendable` handler closures (`haptics.handler`, `tracking.track`, `error.report`). `@Sendable` closures don't conform to `Equatable`, so a config carrying them can't be cheaply compared; `.cosmos*` overrides (`.withHaptics`/`.withMotion`/`.withAccessibility`) re-inject a new config on every override — any parent re-evaluation that reconstructs a closure literal invalidates **every atom** reading `cosmosConfiguration`.
- **Research:** WWDC26 UI Frameworks Group Lab (session 8003) — "Reading the environment is cheap; environment churn is not. Every environment change invalidates all views that read that environment value." WWDC25-306. [philz.blog](https://philz.blog/closures-in-swiftui-environment-are-killing-your-apps-performance/) — closures don't support equality → spurious invalidations; prefer stable callable handler types (the `DismissAction` pattern).
- **Change:** (1) Audit whether `CosmosConfiguration` + nested configs can conform to `Equatable` (drop the closure from equality, or wrap handlers in a stable struct) — lets SwiftUI short-circuit re-invalidation. (2) Consider splitting volatile handler closures into a stable `Sendable` call-only struct, or route through a single `@Observable @MainActor` registry read only where needed, so `.cosmosEnabled(...)`/`.cosmosHaptics(...)` overrides (which change *behavior flags*, not handlers) don't drag closures through a new struct each render.
- **E:** M · **I:** med-high (every atom reads `cosmosConfiguration`; churn invalidates the whole subtree) · **R:** med (handler storage touches `@Sendable` isolation; must keep zero concurrency warnings). **Verify:** zero warnings; Instruments 26 SwiftUI instrument on a preview hosting many atoms with a `.cosmosEnabled(...)` toggle — confirm no cascade invalidation; handler-routing refactor is a public change → gate per `VERSIONING.md`.

### Legitimate — keep
- `CosmosSlider` (inits build structurally-different `Slider<…>` concrete types — documented).
- `CosmosSelectableList` (unifies `List(selection:)` / `List(data, selection:)` / `List(data, id:, selection:)` / watchOS-unavailable `Set` variants).
- `CosmosTabView` (unifies `TabView<SelectionValue, _>` vs `TabView<Never, _>`).
- `CosmosAccessibilityHelpers.accessibilityCustomContentIfPresent` — `AnyView` fold over a *runtime-dynamic* array (count unknown at compile time; `@ViewBuilder` can't express a variable-length fold). The one defensible `AnyView` in a modifier. Optional: document why.

---

## Area T — Testing (consolidate the 3 axes, close the gaps)

Test contract: Swift Testing only, no `XCTestCase`/`XCTAssert`, no UI snapshots, no `ViewInspector`, value-level construction (`_ = CosmosX(...)`), `@MainActor` on suites touching `View` inits.

**Inventory:** 3 axes — (1) selector/token tests (`CosmosTokensTests` + per-Wave availability matrices), (2) per-Wave component files (`CosmosWaveA…G` + `CosmosWaveERefinements`), (3) behavior tests (`CosmosAtomsBehaviorTests`, 9 atoms). Cross-cutting suites: Configuration, Environment, Haptics, Localization, Mock/Preview, Motion, Stacks, Theme, Toast, Tracking. **13 atoms have no construction smoke** (DatePicker, GroupBox, Menu, Label, List, Picker, TabView, TextField, TextEditor, SelectableList + partial-only Toggle/Progress/Slider/Stepper); **3 have no tests at all** (SecureField, AdaptiveStack, LocalizedText). Low actual redundancy — the axes are mostly complementary; the problem is organizational inconsistency + the gaps.

### T1 — Per-atom `@Suite` convention; fold 3 axes
- **Today:** Behavior tests centralized in one 173-line `@MainActor @Suite`; selector/availability for the same atoms scattered across Wave files. An atom's tests live in 2-3 files with no single source of truth.
- **Research:** WWDC24-10179 "Meet Swift Testing" — `@Suite` grouped by subject with nested sub-suites; a fresh suite instance per `@Test` gives cheap per-test setup. Apple "Organizing tests."
- **Change:** Replace the Wave-axis + behavior-file split with one `@Suite` per atom (or atom family), each with nested `@Suite struct Construction` / `Selector` / `Availability`. Create `Tests/CosmosTests/Atoms/Cosmos<Button>Tests.swift` × every atom. Delete `CosmosAtomsBehaviorTests.swift` + `CosmosWaveA…GAtomsTests.swift` + `CosmosWaveERefinementsTests.swift` after migration. `CosmosStacksTests` folds into `CosmosHStackTests` + `CosmosVStackTests`.
- **E:** L · **I:** high (discoverability, regression locality) · **R:** med (large mechanical move; `swift test` must stay green). **Verify:** `swift test` green pre/post; `swift test --filter "CosmosButtonTests"` runs only Button tests; test count unchanged.

### T2 — Behavior tests for the 13 uncovered atoms
- **Today:** `CosmosAtomsBehaviorTests` covers only 9 atoms. 10 have selector/availability but no init-construction smoke (DatePicker, GroupBox, Menu, Label, List, Picker, TabView, TextField, TextEditor, SelectableList); 4 are partial-only (Toggle, Progress, Slider, Stepper).
- **Research:** WWDC24-10179 — value-level deterministic tests over UI snapshots; construction smoke = `_ = CosmosX(...)` builds without crashing for every public init shape. `@MainActor` required (View body access is main-actor-isolated in Swift 6).
- **Change:** Add a `@Suite("Cosmos<Atom> — construction") struct Construction` per gap atom. One `@Test` per public init variant (e.g. DatePicker graphical/wheel/field; Menu localized/verbatim/custom-label/primary-action; Label icon+title/system-name/custom-view × `CosmosLabelStyle.allCases`; TextField localized/verbatim/prompt × `CosmosTextFieldStyle.allCases`; TextEditor `text:` binding with `#if !os(tvOS) !os(watchOS)`; SelectableList single + set selection). Add per-init smoke for the 4 partial-only atoms.
- **E:** M · **I:** high (closes the audit gap) · **R:** low (additive; value-level). **Verify:** `swift test` green; +35-45 tests.

### T3 — Tests for the 3 zero-coverage atoms (SecureField, AdaptiveStack, LocalizedText)
- **Today:** `grep` for these 3 in `Tests/` returns zero hits. `CosmosSecureField` documents a `CosmosSecureFieldStyle` selector (`Atoms/CosmosSecureField.swift:8`) but **the type does not exist**. `CosmosAdaptiveStack` and `CosmosLocalizedText` are public with zero coverage.
- **Research:** WWDC24-10179 (every public API surface needs ≥1 `@Test`); WWDC24-10195 "Go further with Swift Testing" — `withKnownIssue` for known gaps.
- **Change:** Create 3 new files: `CosmosSecureFieldTests` (construction smoke for all 3 public inits; `@State` binding round-trip; if `CosmosSecureFieldStyle` is intended, file a follow-up or `withKnownIssue`), `CosmosAdaptiveStackTests` (construction; `.cosmosAdaptiveStack(...)` modifier resolves; builds under `.compact` + `.regular`), `CosmosLocalizedTextTests` (key / `LocalizedStringResource` / verbatim; `Text`-equivalent init parity).
- **E:** S · **I:** high (closes zero-coverage holes; 26/29 → 29/29) · **R:** low.

### T4 — `@Test(arguments: XxxStyle.allCases)` for style appliers
- **Today:** `CosmosAtomsBehaviorTests.swift:23-29` uses a `for style in CosmosButtonStyle.allCases` loop — one test, one failure point, no per-style isolation. Same pattern across Wave files.
- **Research:** Apple "Implementing parameterized tests" + WWDC24-10179 — `@Test(arguments:)` makes each argument a separate, independently re-runnable test with parallel execution; per-argument failure diagnostics.
- **Change:** Convert every style-applier smoke to `@Test(arguments: CosmosXxxStyle.allCases) func ...(_ style:)`. Apply to all 12 style enums.
- **E:** S (mechanical) · **I:** med (diagnostics, parallelism) · **R:** low. **Verify:** test count rises (one per style × atom); Test Navigator shows per-style rows.

### T5 — Parameterized style × platform availability matrices
- **Today:** `CosmosWaveCAtomsTests.swift:77-117` hand-codes `isAvailable(.wheel, on: .ios)` across 5 platforms × N styles (~30 hand-written `#expect` per atom). Repeated for Picker/List/TabView. Brittle; adding a style touches many lines.
- **Research:** Apple parameterized testing — two-argument Cartesian `@Test(arguments: A.allCases, B.allCases)` and `zip(...)` for paired elements.
- **Change:** One parameterized test per atom: `@Test(arguments: CosmosXStyle.allCases, CosmosPlatform.allCases) func availabilityIsConsistentWithResolve(_ style, _ platform)` asserting `available == !resolve(...).isFallback`. Apply to DatePicker/Picker/List/TabView/TextEditor/GroupBox/Menu/SelectableList. Delete the per-Wave matrix tests.
- **E:** M · **I:** med (cuts ~200 lines; auto-coverage for new styles) · **R:** med (some atoms have asymmetric availability/resolve rules — verify per-atom before converting). **Verify:** coverage unchanged; new styles auto-tested.

### T6 — `.tags` for cross-cutting test selection
- **Today:** No `Tag` declarations anywhere; selection is by file/suite name string matching.
- **Research:** Apple "Adding tags to tests" + WWDC24-10179 — tags over test names for test-plan inclusion/exclusion; `swift test --filter "tag:smoke"`.
- **Change:** Add `Tests/CosmosTests/CosmosTestTags.swift` with `@Tag static var smoke / selector / availability / themeBuilder / motion`. Tag per-atom `Construction` with `.smoke`, `Selector` with `.selector`, `Availability` with `.availability`. CI fast-path: `swift test --filter "tag:smoke"` (~50 tests, <10s).
- **E:** S · **I:** med (CI ergonomics) · **R:** low.

### T7 — `.disabled(if:)` traits over `#if os()` guards
- **Today:** `CosmosWaveDAtomsTests.swift:20-44` guards TextEditor availability tests with `#if os(iOS)`/`#if os(macOS)`/`#if os(visionOS)` — a test simply doesn't exist on other platforms (silent coverage holes; test count varies per host).
- **Research:** WWDC24-10179 — `.enabled(if:)`/`.disabled(if:)` traits over `#if` guards so a test is always registered and reported as skipped with a reason. `@available(iOS 26, *)` on a `@Test` preferred over in-body `if #available`.
- **Change:** In the per-atom `Availability` suites, replace `#if os(iOS) func …AvailabilityIOS()` with a single parameterized test + `.disabled(if: CosmosPlatform.current != .ios, comment: "iOS host only")`. Apply to TextEditor/DatePicker/Picker/List/TabView/SelectableList. Keeps the test visible as "skipped" on non-host platforms.
- **E:** S · **I:** med (no silent holes) · **R:** low. **Verify:** `swift test` on each host shows skipped (not absent); `-v` lists skip reasons.

**Recommended order:** T3 → T2 → T4 → T1 → T5 → T6 → T7.

---

## Area D — Documentation (DocC), Localization, Layout reflow

### D1 — Enable `swift-docc-plugin` + curation catalog
- **Today:** DocC is declared in `ARCHITECTURE.md`/`CONTRIBUTING.md` but `Package.swift` has **no** `swift-docc-plugin` dependency, no `swiftDocumentation` target setting, no `Documentation.docc` catalog (`find . -name "*.docc*"` returns nothing). `ROADMAP.md:149` carries the open todo. `CHANGELOG.md:296` references "DocC catalogs for CosmosBase/CosmosScreen" — **stale** (those targets were removed in the reset). Doc-comment coverage is actually strong (1355 `///` lines / 126 public decls) but none is extracted/curated.
- **Research:** `swift-docc-plugin` (v1.4.3) — a SwiftPM command plugin; add `.package(url:..., from: "1.4.3")`, no per-target setting (auto-discovers). Curation in `Sources/<Module>/Documentation.docc` (WWDC22-110368 "What's new in Swift-DocC"; Apple "Adding structure to your documentation pages"; Swift Forums — single-module: `Sources/Cosmos/Documentation.docc`).
- **Change:** Add the dependency. Create `Sources/Cosmos/Documentation.docc/` with `Cosmos.md` landing (`# ``Cosmos```) + an `@Article` per cross-cutting contract (Theme/Configuration/Motion/Haptics/Localization/Tracking/Accessibility/Preview). CI step: `swift package --allow-writing-to-directory ./docs generate-documentation --target Cosmos`. Close `ROADMAP.md:149`.
- **E:** M · **I:** high · **R:** low. **Verify:** `generate-documentation` builds a `.doccarchive` with zero warnings (treat unresolved links as build-breaking); the 9-contract Topic graph is navigable; every public atom appears under its article.

### D2 — Doc the 5 undocumented public types + `@Tutorial`
- **Today:** Exactly **5** public type decls lack a `///` doc comment: `CosmosSlider.swift:59`, `CosmosTextEditor.swift:32`, `CosmosToast.swift:4`, `CosmosDatePicker.swift:33`, `Base/Theme/CosmosThemeObservable.swift:25`. DocC will flag them as missing abstracts.
- **Research:** DocC renders "No abstract available" for undocumented public symbols. WWDC22-110368 — `@Tutorial`/`@TutorialReference` for workflow docs (multi-step).
- **Change:** Add a one-paragraph `///` abstract to each (match `CosmosAdaptiveStack.swift:3-11`). Add `Documentation.docc/Tutorials/ThemeAndConfig.tutorial` walking define `CosmosTheme` → `.cosmosTheme(_:)` → live-switch with `CosmosThemeObservable` → `.cosmosMotion(_:)`/`.cosmosSpringStyle(_:)` overrides. Cross-link from the landing page + `CosmosThemeObservable` doc.
- **E:** S · **I:** med · **R:** low. **Verify:** zero "No abstract" warnings; tutorial steps/sections resolve; code listings compile as Snippets.

### D3 — Add `comment` keys to every `.xcstrings` entry
- **Today:** `Sources/Cosmos/Resources/Localizable.xcstrings` — 6 real keys + an empty `"Loading" : {}` stub. **Every** entry is `extractionState: "manual"`; **none** has a `comment` field (`grep -c "\"comment\""` → `0`). Translators have no context. `CosmosLocalizationConfiguration.string(for:)` uses `NSLocalizedString(key, ..., comment: "")` with an **empty** comment (`Base/Configuration/CosmosLocalizationConfiguration.swift:41,54`).
- **Research:** WWDC23-10155 "Discover String Catalogs" — `comment` is one of the four components of a localizable string; `String(localized:, comment:)` is canonical. The `comment` field exports into XLIFF `<note>` so translators see context.
- **Change:** Add a `comment` to each of the 6 keys (e.g. `cosmos.asyncimage.retry` → "Button label on a failed async image load; retries the download."). Delete or fill the empty `"Loading" : {}` stub. Thread an optional `comment:` through `CosmosLocalizedText.init(key:comment:)` and `string(for:comment:)`.
- **E:** S · **I:** med · **R:** low. **Verify:** String Catalog editor shows comments; exports to XLIFF `<note>`; `swift build && swift test` green (pt-BR "Tentar novamente" still resolves); `grep -c "\"comment\""` ≥ 6.

### D4 — Pluralization + device variations in the String Catalog
- **Today:** The catalog has **zero** `variations` blocks (all flat `stringUnit` pairs). No pluralized strings; no device-specific variants — despite targeting **5** platforms where the same action may need different copy ("Tap"/"Click"/"Select"/"Press"). `CosmosLocalizedText.swift:10` only offers `init(key: String)`.
- **Research:** WWDC23-10155 — "Vary by Plural" (`variations.plural`, CLDR categories per language: en `one`/`other`; pt-BR `one`/`many`/`other`) and "Vary by Device" (`variations.device`: iphone/ipad/mac/watch/tv/other). Compiles back to `.strings`/`.stringsdict` — backward-compatible, no deployment-target bump.
- **Change:** (1) Introduce a plural-bearing key (`cosmos.selection.count` with en + pt-BR plural variations). (2) Add device variations for a cross-platform action (`cosmos.action.continue`: iphone/ipad/vision/mac → "Continue"; tv → "Select"; watch → "Continue") — makes the catalog a demonstration of the variations Cosmos's own atoms should support. (3) Extend `CosmosLocalizedText` with `init(key:count:)`; add `variations.plural` lookup to `CosmosLocalizationConfiguration.xcstringsValue(for:)` (`:76` — currently only reads `stringUnit`). Mirror with a `LocalizedStringResource`-based init.
- **E:** M · **I:** med · **R:** low. **Verify:** `swift build && swift test` green; plural test asserts `one` for count=1, `other` for 0/5; device variant picked on watch/tv builds; `swift build -c release` compiles the catalog.

### D5 — `CosmosAdaptiveStack` in Card/Toast + `ViewThatFits`
- **Today:** `CosmosAdaptiveStack.swift:39-44` is the **only** atom implementing the `AnyLayout` reflow pattern CLAUDE.md mandates (`grep -rn "AnyLayout"` → 5 hits, 3 here). `ViewThatFits` is **not used anywhere** in production. `CosmosCard.swift:133` builds the body with a **fixed** `VStack(alignment: .leading, spacing: 6)` — no reflow. `CosmosToastContent` likewise has no adaptive layout.
- **Research:** WWDC22 SwiftUI Lounge + WWDC26 SwiftUI Group Lab — "Use `AnyLayout` to maintain structural view identity when switching layouts — explicitly recommended over `if` statements that swap entire view trees"; "Use `ViewThatFits` to pick the best layout variant; size classes define broad experiences — pair with `AnyLayout`." WWDC23-10160 — changing structural identity forces teardown/rebuild and resets state.
- **Change:** (1) `CosmosCard.swift:133` — replace the fixed `VStack` with `CosmosAdaptiveStack(...)` so header/body/footer reflows in landscape regular width (the landscape preview at `CosmosCard.swift:125` injects `.regular`, so it'll be exercised). (2) Add a `ViewThatFits`-based atom/modifier for button/action rows where the binary compact/regular split is too coarse (intermediate widths / accessibility Dynamic Type sizes). (3) Add `#Preview("AdaptiveStack – landscape reflow", traits: .landscapeLeft)` to `CosmosAdaptiveStack.swift` (currently none — the claim at `:3-8` is unverifiable).
- **E:** M · **I:** med · **R:** med (visual change in Card across 5 platforms). **Verify:** `swift build` all 5; landscape preview — focus/scroll/animation state survives rotation; test asserting `HStackLayout` under `.regular` / `VStackLayout` under `.compact`.

### D6 — Replace magic `420` toast width with a theme token
- **Today:** `Modifiers/CosmosToastModifier.swift:96-99` — `horizontalSizeClass == .regular ? 420 : .infinity`. The `420` is a hard-coded magic number (only `420` literal in the codebase), not a `CosmosTheme` token. Violates the "prefer semantic tokens over raw points" rule.
- **Research:** WWDC26 SwiftUI Group Lab — "avoid hardcoding window sizes"; express adaptive dimensions through the design system.
- **Change:** Add `toastMaxWidth: CGFloat` to `CosmosTheme` (default `420`) + `.cosmosToastMaxWidth(_:)` per-instance override. `CosmosToastModifier` reads `@Environment(\.cosmosTheme).toastMaxWidth`. Keep the `regular ? <token> : .infinity` shape.
- **E:** S · **I:** low · **R:** low. **Verify:** `swift build && swift test`; test asserting default `420` + `.cosmosToastMaxWidth(600)` propagates; no remaining bare `420`.

### D7 — Landscape reflow `#Preview` coverage across atoms
- **Today:** Only **2** atoms ship a landscape preview: `CosmosVStack.swift:102` (`.landscapeLeft`) and `CosmosCard.swift:116` (which uses `.environment(\.horizontalSizeClass, .regular)` rather than the `.landscapeLeft` trait). The flagship `CosmosAdaptiveStack` has none. `CosmosHStack`/`Section`/`Toast`/`TabView`/`ScrollView` + the form atoms have none — all use `.sizeThatFitsLayout`/`.cosmosPreviewEnv(dynamicTypeSize:)` only.
- **Research:** `#Preview(_:traits:)` (iOS 18+) supports `.landscapeLeft`/`.portrait` natively — the modern replacement for deprecated `.previewInterfaceOrientation`. WWDC26 Group Lab — reflow should be visually verified at every size-class transition; previews are the cheapest surface. CLAUDE.md mandates the deprecated modifiers must not be used.
- **Change:** Add `#Preview("<Atom> – landscape reflow", traits: .landscapeLeft)` to every reflow/orientation-sensitive atom, prioritizing `CosmosAdaptiveStack` (canonical), HStack, Section, Toast, ScrollView, TabView, List, SelectableList, form atoms. Use the `.landscapeLeft` trait (flips both size classes), not `.environment(\.horizontalSizeClass, .regular)`. Inject `CosmosPreviewModifier()` + a Dynamic Type accessibility size in the same block (worst case: landscape + accessibility size).
- **E:** S · **I:** med · **R:** low. **Verify:** `grep` returns ≥ one landscape block per reflow-relevant atom; open each in Xcode 26 — confirm no view-identity loss; `swift build -c release` type-checks previews.

---

## Recommended waves

- **Wave 1 — foundations + bug fixes (high impact, low risk):** A1, A3 (incl. toast tint bug fix), P1, P2, T3, T2, M4. ~7 items, all S/M, all low-risk. Closes the two real bugs and the documented audit gaps; sets up the chokepoints.
- **Wave 2 — chokepoints + infra + preview coverage:** A5, M3, D1, D3, D6, D7, T4, M1. ~8 items. Adds the `cosmosWithAnimation` chokepoint, DocC infra, localization comments, the `420` token, landscape previews, parameterized style tests, the spring migration.
- **Wave 3 — atom-level wiring + generics:** A2, P3, D2, D4, D5, T6, T7. ~7 items. Wires `showBorders` on ghost buttons, the preview accumulator cleanup, the 5 type docs + tutorial, plural/device variations, `CosmosAdaptiveStack` in Card/Toast, test tags + traits.
- **Wave 4 — large/risky surfaces:** A4, P6, M2, T1, T5, A6, M5. ~7 items. Increased-contrast adaptive surfaces, environment-churn audit, Liquid Glass motion, the big test reorg, parameterized availability matrices, the doc/gate-name update, SF Symbols 6 presets.
- **Wave 5 — public-API-shaping generics:** P4, P5. 2 items. `CosmosAsyncImage` and `CosmosProgress` generics — gated by a deprecation runway (`VERSIONING.md`).

Each wave is independently shippable as a minor release. Waves 1-2 are the highest-value "improve what exists" work with negligible regression risk; Waves 4-5 carry real visual/API risk and warrant their own ADRs in `vault/02-decisoes/`.

## Cross-links
- Closes most of [[unwired-accessibility-gates]] (A1-A6); update that note as each lands.
- Builds on [[cosmos-org-audit-2026-07]] (the cleanup this follows).
- Motion proposals extend the contract documented in [[adr-atoms-impose-theme-defaults]].
- A2 reuses [[button-shapes-ios26-liquid-glass]] (capsule is already the design rhythm).
- M2 (Liquid Glass motion) pairs with [[apple-ios26-sample-code-patterns]] (matchedTransitionSource + navigationTransition(.zoom) catalog).
- P6 (environment-churn) is the runtime perf counterpart to the compile-time Swift 6 work in [[cosmos-org-audit-2026-07]].