---
tags: [component, atom, wave-e, phase3, list, selection, swiftui]
aliases: [CosmosSelectableList]
related: [cosmos-list, cosmos-tabview, cosmos-picker, above-floor-gating-pattern, Home]
---

# CosmosSelectableList

Selectable `List` wrap-view — PHASE3 Wave E refinement ([[ROADMAP]] / `PHASE3.md` §2.1). File:
`Sources/Cosmos/Atoms/CosmosSelectableList.swift`. Resolves the `List(selection:)` platform
fragmentation that [[cosmos-list]] deliberately deferred (its no-selection primary).

## Why a separate atom

`List(selection:)` inits fragment across platforms in ways one clean API cannot hide (verified in
the Xcode 27 `.swiftinterface`):

| Selection shape | Availability |
|---|---|
| `Binding<SelectionValue?>` (optional-single) | all 5 (watchOS 10+ ≤ floor; iOS 13 / macOS 10.15 / tvOS 13 / visionOS 1) |
| `Binding<Set<SelectionValue>>` (Set multi) | iOS / macOS / tvOS / visionOS; **watchOS unavailable** (`@available(watchOS, unavailable)`) |
| `Binding<SelectionValue>` (non-optional single) | macOS 13 only (data-bearing adds tvOS 18) — **dropped** (too narrow) |

Resolution: **optional-single is the universal primary**; **Set** inits are `#if !os(watchOS)`
compile-time-excluded; **non-optional-single is dropped** (callers use a native `List(selection:)`
directly). No runtime `if #available` — all bounds ≤ floor.

## Generic shape — one `Selection` unifies both shapes

`CosmosSelectableList<Selection: Hashable & Sendable>`, **inferred from the binding**:
`Binding<Element?>` → `Selection == Element?`; `Binding<Set<Element>>` → `Selection == Set<Element>`.
Each init pins the shape with a **mutually-exclusive** `where Selection == E?` / `where Selection ==
Set<E>` constraint, so the overloads resolve unambiguously from the binding (the constraints can't
both hold). `Sendable` is added so the selection drives `.cosmosHaptic(.selection, trigger:)`.

### AnyView-in-init (cf. [[cosmos-tabview]])

The optional-single and Set inits construct structurally different native `List` types (different
`Content`), so the native `List` is built in each init — where the per-init constraints are concrete
— and type-erased to `AnyView`; env-driven modifiers + the haptic/tracking are applied in `body`.
Six inits: 3 optional-single (content / `Identifiable` data / keyed-id data) + 3 Set (same forms,
`#if !os(watchOS)`).

### Gotcha: `AnyHashable` is not `Sendable

The first draft bridged the trigger through `AnyHashable` for a unified `body`. **`AnyHashable`'s
`Sendable` conformance is explicitly `@available(*, unavailable)`** — so `.cosmosHaptic<T: Equatable
& Sendable>` rejects it (zero-concurrency-warnings violation). Fix: make the atom generic over the
**concrete** selection state `Selection` (not the element), so `body`'s trigger is the concrete
`Selection` (`Optional<E>` / `Set<E>`, both `Equatable & Sendable`). No type erasure of the trigger.
`.onChange(of:)` for tracking needs only `Equatable` (AnyHashable would do there), but sharing one
concrete trigger for both haptic + tracking is cleanest.

## Reused infrastructure

Reuses `CosmosListStyleApplier` + `CosmosListAvailability` from [[cosmos-list]] — the applier was
promoted `private` → `internal` so both atoms share one `ListStyle` × platform matrix (single source
of truth). `CosmosSelectableListAvailability` is the new pure selection-init table (optional-single
all 5; Set 4-not-watchOS).

## Cross-cutting

- **Haptics:** `.selection` on `selection.wrappedValue` change via `.cosmosHaptic(_:trigger:)`
  (gated by `CosmosHapticsPolicy`).
- **Motion:** the List's native selection animation is system-driven — **no**
  `.cosmosAnimation(.valueChange, value:)` on the List (differing curve desyncs — same rule as
  [[cosmos-picker]]/[[cosmos-tabview]]). Callers wrap a programmatic write in one `withAnimation`.
- **Tracking:** `.valueChange` on selection change (`componentId = trackingId ?? accessibilityId`).
- **Accessibility:** selectable list with navigable rows; per-row labels caller-driven.

## Tests

`CosmosWaveERefinementsTests`: optional-single available all 5; Set 4-not-watchOS; shared
`CosmosListAvailability.resolve` fallback (`.bordered`→`.automatic` on iOS, etc.). Builds clean on
all 5 platforms (watchOS excludes the Set inits via `#if !os(watchOS)`).