# Versioning — Cosmos

Cosmos versioning is **aligned 1:1 with the Apple OS version**. This keeps the library easy to manage: there is no separate major number to maintain — the library major *is* the OS major it targets.

## Major version == OS version

A Cosmos major release targets the matching OS major across all supported platforms:

| Cosmos | iOS | macOS | tvOS | watchOS | visionOS | Era |
|--------|-----|-------|------|---------|----------|-----|
| **26** | 26 | 26 | 26 | 26 | 26 | Liquid Glass |

When a new OS major ships, Cosmos bumps its major to match and may deprecate patterns tied to the prior OS.

## API availability == Cosmos API versioning

Because the SwiftPM deployment target tracks the OS, `@available(iOS 26, *)` is the canonical way to express "available since Cosmos 26". Use `@available(*, deprecated, message:)` with a migration runway before `obsoleted:`. Centralize `if #available` gates for OS-introduced features rather than scattering them through atoms.

Feature → OS gate reference:

| Feature | Gate |
|---|---|
| `.sensoryFeedback`, `symbolEffect`, `ShapeStyle.resolve(in:)`, `listSectionSpacing` | iOS 17 |
| `Tab`, `.sectionActions`, `TabViewStyle.sidebarAdaptable` | iOS 18 |
| Liquid Glass (`.glassEffect`, `.glassProminent`), `listSectionMargins` | iOS 26 |
| `tabViewBottomAccessory(isEnabled:)` | iOS 26.1 — runtime `if #available(iOS 26.1, *)`, degrades to the iOS 26.0 content-only `tabViewBottomAccessory(content:)` form (``cosmosTabViewBottomAccessory(isEnabled:content:)``); no-op on the other 4 platforms. |
| `TabsPickerStyle` (`.tabs`) | iOS 27 / macOS 27 / tvOS 27 / visionOS 27, **watchOS unavailable** — **combined** compile (`#if !os(watchOS)` — the symbol is `@available(watchOS, unavailable)`) + runtime (`if #available(iOS 27, macOS 27, tvOS 27, visionOS 27, *)`) gate in ``CosmosPickerStyleApplier``; degrades to `.automatic` below OS 27 and on watchOS. First above-floor (Cosmos-27) surface. |
| `TabRole.prominent` | `@available(anyAppleOS 27.0, *)` — all 5 platforms at OS 27 — runtime `if #available(iOS 27, macOS 27, tvOS 27, watchOS 27, visionOS 27, *)` in ``CosmosTabRole/nativeRole()``; degrades to `nil` below OS 27. First above-floor (Cosmos-27) surface. |

Motion primitives (`Spring`, `PhaseAnimator`, `KeyframeAnimator`, `BlurReplaceTransition`, `withAnimation(completion)`, the generic `.transition<T>(_:)`, `matchedGeometryEffect`, and the `CosmosMotion*` tokens/modifiers) are all iOS 17/18 ≤ 26 and available on all 5 platforms — **no `if #available` gating is needed** at the Cosmos 26 baseline. `GlassEffectTransition.matchedGeometry` (iOS 26) is the only motion-adjacent API that would need a gate if the floor ever lowers.

**Above-floor gating pattern (PHASE3).** Three surfaces now sit above the Cosmos 26 floor and establish the library's gating conventions for future Cosmos-27 work: (1) a **shallow runtime-only gate** for a same-OS-minor bump (`tabViewBottomAccessory(isEnabled:)`, iOS 26.1 → degrade to the 26.0 form); (2) a **combined compile + runtime gate** for an OS-major-introduced, platform-fragmented style (`.tabs`: `#if !os(watchOS)` for the unavailable symbol + `if #available(...27...)` for the version); (3) a **runtime-only gate in a resolver** for an OS-major-introduced, all-platforms value (`TabRole.prominent` → `nil` below OS 27). The combined gate is the template for future OS-27 `PickerStyle`/`ListStyle`/`TabViewStyle` cases; the resolver is the template for OS-27 value-typed surfaces that have no corresponding `.modifier` (verified: there is no native `.tabRole(_:)` — `TabRole` is a `Tab(role:)` init parameter, so ``CosmosTabRole`` exposes `nativeRole() -> TabRole?` rather than a modifier).

## Runtime design-language pin

`CosmosTheme.version: CosmosVersion` lets an app render an **older Cosmos design language** on a newer OS, mirroring how SwiftUI's appearance adapts per OS but can be pinned. Default is `CosmosVersion.current` (the build's target = `.cosmos26`). New cases are added as the OS evolves; old cases remain supported within the deprecation runway.

## Within a major: semantic minor/patch

- **Patch** (`26.0.x`): bug fixes, no API or behavior change.
- **Minor** (`26.x.0`): additive APIs, new components, non-breaking token additions. Backwards-compatible.
- **Major** (`N+1.0.0`): aligns to a new OS major; may remove APIs deprecated in the prior major (after the runway) and change the design language.

## Deprecation runway

1. Mark `@available(*, deprecated, message: "Use <replacement>; removed in Cosmos <N+1>.")`.
2. Keep working for at least one minor release.
3. Remove (or mark `obsoleted:`) at the next major.

## Changelog

Every release records changes under Keep-a-Changelog-style sections in `CHANGELOG.md`, with the Cosmos/OS version alignment noted at the top of the entry.