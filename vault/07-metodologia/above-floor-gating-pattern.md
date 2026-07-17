---
tags: [methodology, gating, availability, versioning, phase3, cosmos-27, swiftui]
aliases: [above-floor gating, combined compile runtime gate, OS-27 gating]
related: [cosmos-picker, cosmos-tabview, cosmos-selectable-list, phase4-core-navigation-atoms, Home]
---

# Above-floor gating pattern (PHASE3)

How Cosmos wraps APIs that sit **above the Cosmos 26 floor** (OS 27 / Cosmos 27). Established in
PHASE3 with three surfaces, each a template for future Cosmos-27 work. Source of truth =
`VERSIONING.md` (Feature → OS gate reference); this note is the synthesis. On conflict, the root
doc wins.

## The three gate shapes

1. **Shallow runtime-only gate** — same-OS-minor bump. `tabViewBottomAccessory(isEnabled:)` is
   iOS 26.1 (floor is 26.0): `#if os(iOS)` + `if #available(iOS 26.1, *)` → native
   `tabViewBottomAccessory(isEnabled:content:)`, else degrade to the iOS 26.0 content-only
   `tabViewBottomAccessory(content:)` form. No-op on the other 4 platforms. Template for a
   same-minor additive overload.

2. **Combined compile + runtime gate** — OS-major-introduced, **platform-fragmented** style.
   `TabsPickerStyle` (`.tabs`): `@available(iOS/macOS/tvOS/visionOS 27, *) @available(watchOS,
   unavailable)`. In `CosmosPickerStyleApplier`:
   ```swift
   case .tabs:
   #if os(watchOS)
       content.pickerStyle(.automatic)
   #else
       if #available(iOS 27, macOS 27, tvOS 27, visionOS 27, *) {
           content.pickerStyle(.tabs)
       } else { content.pickerStyle(.automatic) }
   #endif
   ```
   The `#if !os(watchOS)` is **mandatory** — the `TabsPickerStyle` *symbol* is
   `@available(watchOS, unavailable)`, so even referencing it on watchOS fails to compile (a
   body-only `if #available` is insufficient). Template for future OS-27 `PickerStyle` /
   `ListStyle` / `TabViewStyle` cases that drop a platform.

3. **Runtime-only gate in a resolver** — OS-major-introduced, **all-platforms** value with **no
   corresponding modifier**. `TabRole.prominent` is `@available(anyAppleOS 27, *)` (all 5, no
   platform exclusion). `CosmosTabRole.nativeRole() -> TabRole?`:
   ```swift
   case .prominent:
       if #available(iOS 27, macOS 27, tvOS 27, watchOS 27, visionOS 27, *) {
           return .prominent
       } else { return nil }   // degrade: no prominent role below OS 27
   ```
   Template for OS-27 value-typed surfaces.

## Pure availability table vs runtime gate — separation of concerns

The pure `Cosmos*Availability` tables (`CosmosPlatform`-keyed, host-agnostic, testable anywhere)
report the **platform** gate only — they cannot know the OS version. The **version** gate lives in
the applier / resolver (runtime). So `CosmosPickerAvailability.isAvailable(.tabs, on: .ios) == true`
means "usable on iOS *at all* (on OS 27+)", and `resolve(.tabs, on: .ios) == .tabs`; the applier
then degrades to `.automatic` below OS 27. Tests assert the platform table; the runtime gate is
covered by per-platform builds (the `#if os()` compile guard) and co-located `#Preview`.

## Spec deviation recorded: `TabRole` has no modifier

The PHASE3 blueprint called for a `.cosmosTabRole(_:)` **modifier**. Verified in the Xcode 27
`.swiftinterface`: there is **no `.tabRole(_:)` View modifier** and no `tabRole` environment key —
`TabRole` is a `Tab(role:)` **init parameter**, set at construction. So the correct exposure is the
`nativeRole() -> TabRole?` resolver (callers pass it to `Tab(role:)`), not a modifier. Recording
this so future "wrap a role/property" surfaces check for an existing modifier before assuming one.
(See [[cosmos-tabview]].)

## Reused for PHASE4+

Any OS-27 surface in PHASE4 (scroll geometry/visibility APIs, new nav transitions) picks the
matching shape above: platform-fragmented style → combined gate (shape 2); all-platform value →
resolver (shape 3); same-minor overload → shallow gate (shape 1). Re-verify every `@available`
clause against the Xcode `.swiftinterface` before writing — availability is the #1 historical
rework source (see [[header-prominence-not-a-real-api]]).