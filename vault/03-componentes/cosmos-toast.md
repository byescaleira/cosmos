---
tags: [component, atom, toast, presentation, swiftui, wave-h]
aliases: [CosmosToast, cosmosToast, CosmosToastPlacement]
related: [cosmos-card, cosmos-async-image, ios-27-swiftui-above-floor-apis, above-floor-gating-pattern]
---

# CosmosToast

`cosmosToast` — a presentation modifier for transient toast notifications, with the same binding
API as `.sheet` / `.alert`: `.cosmosToast(isPresented:)` and `.cosmosToast(item:)`, each with an
optional `onDismiss`. Wave H.

## The native-API question (research finding)

**There is no first-party SwiftUI `.toast` API in iOS 26 / 27.** Searched Apple's WWDC25 / iOS 26
material: SwiftUI ships `.alert`, `.confirmationDialog`, `.sheet`, `.fullScreenCover`, `.popover`
and the `.presentationDetents` family — all of which **automatically adopt Liquid Glass** on the
Xcode 26 SDK — but no toast. Apple's transient-feedback primitives are `Alert` / `Dialog`
(centered, modal) and the system `ProgressView`; a non-modal, auto-dismissing, floating toast is
conspicuously absent.

So "use a native Apple example" resolves to **two native primitives composed**:

1. **Binding/presentation pattern** — mirror `.alert(_:isPresented:)` / `.alert(item:)` and
   `.sheet(isPresented:)` / `.sheet(item:)`. These are the canonical Apple presentation-modifier-
   with-binding shapes. Every community toast lib (ToastUI, UnionToast, SwiftToasts, ToastSwiftUI)
   copies exactly this convention — that convergence is itself the strongest signal that it is
   the right shape.
2. **Visual layer** — the toast is a custom overlay (not a system presentation) rendered in a
   `ZStack`/`.overlay` aligned to the top or bottom safe area, styled with the native material
   surface (`.regularMaterial` / `.ultraThinMaterial`; `.glassEffect()` is reserved for the
   navigation/controls layer per Apple's Liquid Glass guidance — glass-on-glass is discouraged, so
   a toast uses material, not glass), entering/leaving via `.transition` gated through
   `CosmosMotionPolicy`.

This is the same "wrap + compose native primitives, don't fight the framework" stance Cosmos
takes for every atom: `.sheet` has no `SheetStyle`, so CosmosScrollView/CosmosSection compose
native pass-throughs; `.toast` has no native surface, so CosmosToast composes overlay + material +
transition.

## API surface

```swift
extension View {
    func cosmosToast<Content: View>(
        isPresented: Binding<Bool>,
        placement: CosmosToastPlacement = .top,
        dismissAfter: CosmosDuration? = .moderate2,   // ~0.24s? no — see note
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View

    func cosmosToast<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        placement: CosmosToastPlacement = .top,
        dismissAfter: CosmosDuration? = nil,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View
}
```

`CosmosToastPlacement` is `.top` / `.bottom` (aligned to the safe area). `dismissAfter` opts into
auto-dismiss; `nil` = manual dismiss (parity with `.sheet`, which is manual). The `item` form drives
a re-present when the item's identity changes (same identity-changes-dismiss-represent trick
CosmosAsyncImage uses for retry via `.id(retryToken)`).

## Cross-cutting integration (per CLAUDE.md)

- **Motion**: `.cosmosTransition(.slide)` (top) / `.cosmosTransition(.sheet)` (bottom) — both
  already in `CosmosTransition` (`.slide` = move(top)+opacity, `.sheet` = move(bottom)+opacity).
  Reused, **no new token added**. Gated through `CosmosMotionPolicy` (config-aware, not the bare
  `accessibilityReduceMotion` env value). No raw `Animation.spring` / `.transition(.move...)`.
- **Haptics**: `.cosmosHaptic(_:trigger:)` on present, gated by `CosmosHapticsPolicy` +
  `accessibilityReduceMotion`. Trigger = the item's identity (nil→value fires once).
- **Accessibility**: `.accessibilityElement(children: .combine)` + `.isStaticText` trait; the
  toast is in the layout so VoiceOver reads it. Announcement routing (UIAccessibility
  `UIAccessibility.post(.announcement)`) is UIKit — out of scope (no UIKit rule). Tracked as a
  refinement: a SwiftUI-only announce path (if one ships) would plug in here.
- **Localization**: content is caller-provided (already localized via `CosmosText` /
  `LocalizedStringResource`). No new String Catalog keys for the bare modifier.
- **Tracking**: `track(.appear)` on present, `track(.dismiss)` on dismiss; `componentId =
  trackingId ?? accessibilityIdentifier`. Passive, opt-in via `configuration.tracking.isEnabled`.
- **Reduce-transparency**: material → solid `theme.colors.surface` when
  `accessibilityReduceTransparency` is active and `configuration.motion.respectReduceTransparency`;
  shadow suppressed (mirrors `CosmosCard`).

## Chrome (token-driven)

- Background: `RoundedRectangle(cornerRadius: CosmosRadiusTokens.large, style: .continuous)`
  filled with `.regularMaterial` (reduce-transparency → `theme.colors.surface`).
- Padding: `CosmosSpacingTokens.value(for: theme.padding)`; max width capped (toast shouldn't
  span the screen on regular size classes).
- Shadow: `theme.motion.shadowOpacity` / `shadowRadius`, suppressed under reduce-transparency /
  reduce-motion (same rule as `CosmosCard`).
- `CosmosToastContent` convenience view (optional): icon (`CosmosIcon`) + title + message row,
  themed by a `CosmosToastRole` (`.info`/`.success`/`.warning`/`.error`) that tints the icon and
  picks the appear haptic. Additive; callers can also pass fully custom content.

## Concurrency (Swift 6, zero warnings)

- The modifier struct is `Sendable` (ViewModifier body is MainActor-isolated; closures stored
  `@ViewBuilder` like `CosmosCard` — no `@unchecked`).
- Auto-dismiss: a cancellable `Task` scheduled on present, sleeping `dismissAfter.rawValue` then
  flipping the binding on the main actor; cancelled on dismiss/re-present. No `DispatchQueue`,
  no `NSLock`. The `@Namespace` is unnecessary here (no `matchedGeometryEffect`).
- `Binding` is Sendable for Sendable values; `Item: Identifiable` (and the content closure's captures
  stay MainActor).

## File layout

- `Sources/Cosmos/Modifiers/CosmosToastModifier.swift` — the `ViewModifier`, the two `cosmosToast`
  `View` extensions, `CosmosToastPlacement`, and `CosmosToastRole`.
- `Sources/Cosmos/Atoms/CosmosToast.swift` — the optional `CosmosToastContent` convenience view
  (icon + title + message, role-tinted). Lives in `Atoms/` because it is a `View`, not a modifier.
- `Tests/CosmosTests/CosmosToastTests.swift` — Swift Testing: present/dismiss via both bindings,
  `onDismiss` fires, item re-present on identity change, auto-dismiss after duration,
  reduce-motion does not crash (no ViewInspector, no UI snapshots).
- Co-located `#Preview(_:traits:)` blocks (default / dark / Dynamic Type / reduce-motion /
  reduce-transparency / top / bottom / `item` form / role variants).

## Open / deferred

- Auto-dismiss default value (proposed `nil` = manual, parity with `.sheet`; a `dismissAfter` of
  ~3s is the community default — see [[cosmos-toast]] decision in plan).
- VoiceOver announcement routing without UIKit (refinement).
- Queueing / FIFO when a new toast replaces a visible one (UnionToast's "replacement
  choreography") — deferred; first version is single-toast-per-modifier (a second presentation
  site composes naturally by stacking two `.cosmosToast` modifiers).

## Sources

- WWDC25 Session 323 — "Build a SwiftUI app with the new design" (Liquid Glass + presentation
  detents): https://developer.apple.com/videos/play/wwdc2025/323/
- ToastUI (binding-pattern reference): https://github.com/quanshousio/ToastUI
- UnionToast (iOS 26 liquid-glass toast, `isPresented`/`item` + `onDismiss`):
  https://github.com/unionst/union-toast
- SwiftToasts (cross-platform, trigger variants): https://github.com/athankefalas/swift-toasts