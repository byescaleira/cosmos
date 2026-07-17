---
tags: [component, atom, wave-e, tabview, swiftui]
aliases: [CosmosTabView]
related: [cosmos-picker, cosmos-list, cosmos-section]
---

# CosmosTabView

`TabView` wrap-view — Wave E atom ([[PHASE2]] §2.16). File: `Sources/Cosmos/Atoms/CosmosTabView.swift`.

## Why a wrap-view, not a style conformance

`TabViewStyle` is **opaque / native-bridged**: only underscored `_makeView`/`_makeViewList`; no `makeBody`, no `Configuration` associatedtype (compare `TableStyle`, which has them). The underscored requirements take `_GraphValue<_TabViewValue<...>>` / `_ViewInputs` — types internal to SwiftUI — so a Cosmos struct cannot implement them. Cosmos wraps a `View` that configures a native `TabView` and applies a built-in style via `CosmosTabViewStyleApplier`.

`CosmosTabViewStyle` is a **6-case enum** consumed by the applier, which guards each case per platform with `#if os()` and falls back to `.automatic` where unavailable — never blindly forwards a user-chosen style.

## Modern inits only

Exposes the `TabContentBuilder` inits (iOS 18 / macOS 15 / tvOS 18 / watchOS 11 / visionOS 2 — universal at the Cosmos 26 floor):

- `init(selection: Binding<SelectionValue>, @TabContentBuilder<SelectionValue> content:)` — selectable.
- `init(@TabContentBuilder<Never> content:)` — non-selectable (e.g. paged view), `SelectionValue == Never`.

The legacy `init(selection: Binding?, @ViewBuilder content:)` and `.tabItem { }` are `@available(..., deprecated: 100000.0)` → using them would violate zero-warnings; **not** exposed. `.tag(_:)` is **not** deprecated (the spec was wrong), but `Tab(value:)` already supplies selection identity, so it is unneeded. The legacy `init(@ViewBuilder content:)` where `SelectionValue == Int` is superseded and not exposed (its labeling partner `.tabItem` is deprecated).

## Generic shape & the AnyView-in-init trick

`CosmosTabView<SelectionValue: Hashable & Sendable, Content: View>`. `SelectionValue` is `Hashable & Sendable` (native `TabView` needs `Hashable`; the `Sendable` is added to drive `.cosmosHaptic(.selection, trigger:)`). Slightly narrower than native, but every real selection value is `Sendable`.

**Key design constraint:** the selectable init constructs `TabView<SelectionValue, _>` (with a `Binding`); the non-selectable constructs `TabView<Never, _>`. These are structurally different view types that **cannot be unified in a single generic `body`** — the non-selectable `TabView` init pins `SelectionValue == Never`, which a generic body cannot assume (an `if let selection` runtime branch does NOT narrow `SelectionValue` to `Never`).

**Solution:** the native `TabView` is built **in each init** (where the per-init constraints are concrete) and type-erased to `AnyView`; the env-driven modifiers (style applier, tint, accessibility) and the selection haptic are applied in `body`. Building in the init is safe because modifiers read `@Environment` lazily at render, not at construction. The haptic must be in `body` (not the init) so its `trigger: selection.wrappedValue` is re-read each render — a `CosmosTabHapticGate` ViewModifier applies `.cosmosHaptic(.selection, trigger:)` only when `selection != nil` (pass-through for the non-selectable variant).

## Selecting content

Callers use the native `Tab` / `TabSection` primitives directly inside the `@TabContentBuilder` closure (Cosmos does not wrap `Tab`). `Tab` inits (Xcode 27): content-only `Tab(value:content:)` (`Label == EmptyView`), explicit-label `Tab(value:content:label:)`, and `Tab(_ titleKey:, systemImage:, value:, content:)` (title+systemImage). The non-selectable `Tab` inits (`Value == Never`) drop the `value:`. `TabRole.search` is at the iOS 18 floor (safe); `TabRole.prominent` is `@available(anyAppleOS 27.0, *)` — **above** the floor — not surfaced (callers gate it themselves).

`@_disfavoredOverload` makes a string literal prefer the `LocalizedStringKey` Tab init over the `StringProtocol` one.

## TabViewStyle × platform matrix (verified Xcode 27 Beta 3)

All version bounds ≤ the Cosmos 26 floor → `#if os()` only, no runtime `if #available`.

| Style | iOS | macOS | tvOS | watchOS | visionOS |
|---|---|---|---|---|---|
| `.automatic` (Default) | ✓14 | ✓11 | ✓14 | ✓7 | ✓ |
| `.page` (Page) | ✓14 | ✗ | ✓14 | ✓7 | ✓ |
| `.sidebarAdaptable` (SidebarAdaptable) | ✓18 | ✓15 | ✓18 | ✗ | ✓2 |
| `.tabBarOnly` (TabBarOnly) | ✓18 | ✓15 | ✓18 | ✗ | ✓2 |
| `.verticalPage` (VerticalPage) | ✗ | ✗ | ✗ | ✓10 | ✗ |
| `.grouped` (Grouped) | ✗ | ✓15 | ✗ | ✗ | ✗ |

`CarouselTabViewStyle` (`.carousel`) is `@available(... deprecated: 100000.0, renamed: "VerticalTabViewStyle")` — **never** referenced; `.verticalPage` (`VerticalPageTabViewStyle`) is its replacement.

## Per-instance chrome (platform-guarded)

- `.cosmosTabViewCustomization(_:)` — wraps `.tabViewCustomization(_:)`. `TabViewCustomization` is unavailable on tvOS/watchOS → the **whole modifier** is `#if !os(tvOS) && !os(watchOS)`-guarded (the parameter *type* is unavailable, so a body-only guard is insufficient — same lesson as `ListSectionSpacing` in [[cosmos-section]]). Available iOS 18/macOS 15/visionOS 2.
- `.cosmosTabBarMinimizeBehavior(_:)` — all 5 platforms at iOS 26 (the floor) → no guard. Only `.automatic` is portable; `.onScrollDown`/`.onScrollUp`/`.never` are iOS-only (enforced by the type system).
- `.cosmosTabViewBottomAccessory(_:)` — `#if os(iOS)` (iOS 26). The `isEnabled:` overload is iOS 26.1 (above floor) — not wrapped, to avoid a runtime gate.

## Cross-cutting

- **Haptics:** `.selection` on `selection.wrappedValue` change via `.cosmosHaptic(_:trigger:)`, gated through `CosmosHapticsPolicy` (config + Reduce Motion). Non-selectable variant emits none (no binding).
- **Motion:** `tabSwitch` is the mapped kind, but the atom does **not** layer `.cosmosAnimation(.tabSwitch, value:)` on the `TabView` — native tab switching (and `PageTabViewStyle` swipe) is system-driven; a differing curve desyncs (same rule as [[cosmos-picker]]/[[cosmos-section]]). Callers coordinate a switch with a single `withAnimation(theme.motion.spring(for: .containerTransform).animation) { selection = newValue }` around the binding write, or `.cosmosContentTransition(.tabSwitch)` on per-tab content — never per-view `.animation(_:value:)` with differing curves.
- **Tracking:** none at the container — tracking is per-tab via caller-set `.accessibilityIdentifier` (structural-container rule, like [[cosmos-list]]/[[cosmos-section]]).
- **Accessibility:** each `Tab`/`TabSection` label auto-exposes its accessibility label; tab bar items get a button trait natively; VoiceOver announces focused tab + selection changes. Per-tab `.accessibilityIdentifier` is caller-driven. Dynamic Type scales tab labels; page-index dots do not.

## Sendable / concurrency (Xcode 27)

`TabView` is `nonisolated ~Swift.Sendable`; `Tab` is `~Swift.Sendable` (its `body` is `@MainActor @preconcurrency`); `TabContent` and `TabViewStyle` protocols are `@MainActor @preconcurrency`. The built-in style structs are `nonisolated ~Swift.Sendable`; `TabRole`/`TabBarMinimizeBehavior`/`TabViewCustomization` are full `Sendable`. CosmosTabView is a plain `struct : View` storing an `AnyView` + an optional `Binding` — no isolation concerns, zero concurrency warnings.

## Tests

`CosmosWaveEAtomsTests`: `tabViewStyleAllCases`; full style×platform availability matrix (per style); `resolve` fallback; theme default/`withTabViewStyle` fluent builder/non-mutation.

## Gotchas hit during implementation

1. **`@Previewable` must be at root scope** of a `#Preview` block — nesting it inside `CosmosPreviewContainer { }` fails. Declare it before the container, reference `$selected` inside.
2. **`TabViewCustomization` unavailable on tvOS/watchOS** — the `cosmosTabViewCustomization` modifier references it in its *signature*, so the whole function is `#if`-guarded; a `#Preview` using it is likewise `#if`-guarded out on those platforms.