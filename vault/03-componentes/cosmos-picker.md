---
tags: [component, atom, wave-e, picker, swiftui]
aliases: [CosmosPicker]
related: [cosmos-section, cosmos-date-picker]
---

# CosmosPicker

`Picker` wrap-view — Wave E atom ([[PHASE2]] §2.14). File: `Sources/Cosmos/Atoms/CosmosPicker.swift`.

## Why a wrap-view, not a style conformance

`PickerStyle` is **opaque / native-bridged**: only underscored `_makeView`/`_makeViewList`; no `makeBody`, no `Configuration` associatedtype. A Cosmos struct cannot meaningfully conform. So — like [[cosmos-date-picker]] — Cosmos wraps a `View` that configures a native `Picker` and applies a built-in style via `CosmosPickerStyleApplier`.

`CosmosPickerStyle` is an **enum** (8 cases) consumed by the applier, which guards each case per platform and falls back to `.automatic` — never blindly forwards a user-chosen style.

## Generic shape

`CosmosPicker<Label: View, SelectionValue: Hashable & Sendable, Content: View>`. `SelectionValue` is constrained **`Sendable`** so it can drive `.cosmosHaptic(.selection, trigger: selection.wrappedValue)` (the trigger must be `Equatable & Sendable`; `Hashable` → `Equatable`). This is slightly narrower than native `Picker` (which only needs `Hashable`) but every real selection value is `Sendable`.

### Gotcha: generic param `Label` shadows SwiftUI `Label`

The atom's generic label param is named `Label`, which shadows SwiftUI's `Label` struct. The `systemImage` convenience init's constraint `where Label == SwiftUI.Label<CosmosLocalizedText, Image>` and its `SwiftUI.Label { … } icon: { … }` constructor must be qualified `SwiftUI.Label` or the compiler reads them as specializing the non-generic param. (CosmosDatePicker dodged this — its label fixed-types are `CosmosLocalizedText`/`Text`, never `Label<…>`.)

## PickerStyle × platform matrix (verified Xcode 27 Beta 3)

Derived from the `@available(...)` clauses in the iOS/macOS `.swiftinterface` (they list all platforms, so the tvOS/watchOS/visionOS interfaces don't need separate greps). All version bounds ≤ the Cosmos 26 floor → **no runtime `if #available`**; only `#if os()` compile guards. `.menu`'s tvOS 17 bound is below the floor.

| Style | iOS | macOS | tvOS | watchOS | visionOS |
|---|---|---|---|---|---|
| `.automatic` (Default) | ✓ | ✓ | ✓ | ✓ | ✓ |
| `.menu` (Menu) | ✓14 | ✓11 | ✓17 | ✗ | ✓ |
| `.segmented` (Segmented) | ✓ | ✓ | ✓ | ✗ | ✓ |
| `.wheel` (Wheel) | ✓ | ✗ | ✗ | ✓ | ✓ |
| `.inline` (Inline) | ✓ | ✓ | ✓ | ✓ | ✓ |
| `.palette` (Palette) | ✓17 | ✓14 | ✗ | ✗ | ✓ (via `*`) |
| `.navigationLink` | ✓16 | ✗ | ✓16 | ✓9 | ✓ |
| `.radioGroup` (RadioGroup) | ✗ | ✓ | ✗ | ✗ | ✗ |

`TabsPickerStyle` (`.tabs`) is `@available(iOS 27 / macOS 27 / tvOS 27 / visionOS 27, *)` — **above** the floor — deliberately not exposed.

## Cross-cutting

- **Haptics:** `.selection` on `selection.wrappedValue` change via `.cosmosHaptic(_:trigger:)` (gated by `CosmosHapticsPolicy`; no-op without hardware). Picker emits no native selection haptic → additive.
- **Motion:** `valueChange` kind, but **NOT** applied to the Picker itself (native wheel/segment/menu animation is system-driven; a differing curve desyncs — same rule as [[cosmos-date-picker]]). Callers add `.cosmosAnimation(.valueChange, value:)` to dependent content. `tabSwitch` reserved for CosmosTabView.
- **Tracking:** `appear` + `valueChange` (on selection).
- **Accessibility:** label → VoiceOver label; selection announced as value. For an explicit value the caller sets `.cosmosAccessibilityValue` (the atom cannot inspect the opaque content closure).

## Tests

`CosmosWaveEAtomsTests` (13 cases): full style×platform availability matrix + `resolve` fallback + theme default/`withPickerStyle` fluent builder / non-mutation.