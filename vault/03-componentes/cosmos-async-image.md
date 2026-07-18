---
tags: [component, atom, wave-g, asyncimage, swiftui, os27]
aliases: [CosmosAsyncImage, CosmosImageCache]
related: [cosmos-icon, cosmos-scroll-view, cosmos-progress, ios-27-swiftui-above-floor-apis, phase4-core-navigation-atoms]
---

# CosmosAsyncImage

`AsyncImage` wrap-view — Wave G atom (second PHASE4 wave). File:
`Sources/Cosmos/Atoms/CosmosAsyncImage.swift`.

A remote-image atom with an explicit **slot architecture** (placeholder / error / retry),
policy-gated **phase-transition motion**, an OS-27 **cache/performance** surface, and the
cross-cutting error reporting + haptics + tracking. Designed as a clean building block for the
later unified `CosmosImage` (SF Symbols + resource + URL).

## Why a wrap-view, not a style conformance

`AsyncImage` has **no style protocol** (verified in the Xcode 27 `.swiftinterface`: no
`AsyncImageStyle` type). So — like [[cosmos-scroll-view]] — `CosmosAsyncImage` has **no**
`CosmosAsyncImageStyle` enum, no `CosmosTheme` field, and no `.cosmosAsyncImageStyle(_:)` modifier.
Wave G touches `CosmosTheme` not at all.

## Phase model — verified facts (Xcode 27 Beta.3 `.swiftinterface`)

`AsyncImagePhase` is **floor** (iOS 15 / macOS 12 / tvOS 15 / watchOS 8) with three cases:

- `.empty` — in-flight or no URL. **There is no `.loading` case** (in-flight = `.empty`).
- `.success(Image)` — loaded.
- `.failure(any Error)` — failed.

And **no `.content` accessor** — extract the loaded view via `phase.image` (`Image?`). The switch
needs `@unknown default` (non-frozen library enum) → Cosmos routes it to the placeholder slot.

Cosmos maps: `.empty` → placeholder slot, `.success` → the caller's `content` closure, `.failure`
→ failure slot, `@unknown default` → placeholder. The phase is **authoritative** for the slot;
`configuration.loading.isLoading` is **not** consulted (forcing a placeholder over a loaded image
would be wrong).

## Authoritative availability — verified from the Xcode 27 Beta.3 `.swiftinterface`

| Symbol | `@available` | Floor/Above | Gate |
|---|---|---|---|
| `AsyncImage<Content>` + `init(url:scale:)` / `init(url:scale:content:placeholder:)` / `init(url:scale:transaction:content:)` | iOS 15+ | **Floor** | none |
| `AsyncImagePhase` + `.image`/`.error` | iOS 15+ | **Floor** | none |
| `init(request:scale:)` + `request:scale:content:placeholder:` + `request:scale:transaction:content:` | `anyAppleOS 27.0` | **Above 27** | `#if swift(>=6.4)` + `if #available` |
| `View.asyncImageURLSession(_:)` | `anyAppleOS 27.0` (**no carve-out**) | **Above 27** | `#if swift(>=6.4)` + `if #available` |

Key: there is **no SwiftUI `URLCache` symbol** — tune via `URLSessionConfiguration.urlCache` on the
`URLSession` passed to `asyncImageURLSession`. The floor `init(url:scale:transaction:content:)` is
the one CosmosAsyncImage uses (the `transaction` param drives the phase-change animation).

## Inits — content-only; one generic

- **Primary** — `init(url:scale:, content: (Image) -> Content)`. Cosmos default placeholder
  (`CosmosAsyncImagePlaceholder` — indeterminate [[cosmos-progress]] on `theme.colors.surface`) +
  default failure (`CosmosAsyncImageFailure` — `exclamationmark.triangle` in `theme.colors.error`
  + a localized "Retry" [[cosmos-button]]).
- **Custom slots** — `init(url:scale:content:placeholder:failure:)` where
  `placeholder: () -> AnyView` and `failure: (any Error, @escaping () -> Void) -> AnyView`. The
  `retry` closure is handed to the failure slot so a custom retry affordance triggers the same
  re-fetch + haptic path. Slots are `AnyView`-erased so the atom stays **one generic**
  (`Content` = loaded view) — no 3-generic complexity. (The raw `AsyncImagePhase` escape hatch is
  **not** exposed; callers needing it use native `AsyncImage` directly, as [[cosmos-list]] defers
  selection to native.)

## Retry — `.id(retryToken)`, no public retry API

`AsyncImage` has no public retry API, so the atom applies `.id(retryToken)` to the underlying
`AsyncImage`; the retry affordance increments `@State retryToken`, changing the view's identity and
forcing a fresh fetch. `@State failureToken` increments on failure-slot `.onAppear` and drives the
haptic + error reporting + tracking (re-fires on each re-failure).

## Motion — phase transitions

Each slot carries `.cosmosTransition(.blurReplace)` — the plumbed, reduce-motion-safe preset
(substitutes to `.opacity`/`.identity` under Reduce Motion via `CosmosTransitionModifier`'s concrete
`BlurReplaceTransition` path). The phase-change *timing* is driven through the floor init's
`transaction` param with a **motion-policy-gated** animation:

```swift
CosmosMotionPolicy.shouldEmit(isEnabled:respectReduceMotion:reduceMotion:)
  ? theme.motion.animation(for: .appear, reduceMotion:policy:)
  : nil
```

— the `.cosmosAnimation` chokepoint replicated via `Transaction` (the phase swap is driven by the
init's `transaction`, not a `.animation` modifier). Nil → instant swap (Reduce Motion instant).

## Haptics — `.error` on failure, not on retry

`.error` fires **on failure appear** (via `failureToken`), not on the retry tap — semantically
correct (the error occurred). The default retry `CosmosButton` fires its own `.impact(.light)` on
tap; **no double haptic**. Resolves the [[phase4-core-navigation-atoms]] risk TODO "Haptic kind for
AsyncImage retry/error" — `CosmosHapticsFeedback.error`/`.warning` both exist
(`Sources/Cosmos/Base/Configuration/CosmosHapticsConfiguration.swift`).

## Error reporting / tracking

On failure appear: `configuration.error.report(error.localizedDescription, code: nil)` (atoms
describe failures as `message`+`code`, not `any Error` — `any Error` is not `Sendable`) + a passive
`track(.appear)` event (`componentId = trackingId ?? accessibilityIdentifier`). No appear-tracking
on success (a list of many images would be noisy); opt-in tracking belongs on interactive content,
per the structural discipline.

## Cache / performance — OS-27 surface

- `CosmosImageCache` — `public enum` (namespace), `Sendable`. `static let defaultSession` (once-token
  `static let` — no lock; `URLSession` is `Sendable`) built from a `URLSessionConfiguration` whose
  `urlCache` is a tuned `URLCache(memoryCapacity: 16 MB, diskCapacity: 128 MB, diskPath:
  "cosmos-async-image")` + 30 s request / 60 s resource timeouts. Plus
  `session(memoryCapacity:diskCapacity:)` for custom sizing. No custom network code — native
  `AsyncImage` fetches; Cosmos only configures the transport/cache.
- `@Entry cosmosAsyncImageURLSession: URLSession? = nil` (new env value; `URLSession` is `Sendable`
  → satisfies the `@Entry`-must-be-`Sendable` rule, zero warnings).
- `View.cosmosAsyncImageURLSession(_:)` → `.environment(\.cosmosAsyncImageURLSession, session)`.
  Applied at a container to share one session/cache across many images.
- `CosmosAsyncImageSessionApplier: ViewModifier` — dual-gated like the `CosmosTextField` `.bordered`
  applier: `#if swift(>=6.4)` compiles the OS-27 SDK symbol in under Xcode 27 / Swift 6.4 and out
  on Xcode 26 / Swift 6.3; `if #available(iOS 27, macOS 27, watchOS 27, tvOS 27, visionOS 27, *)`
  degrades to passthrough on an OS-26 device. `asyncImageURLSession` is `@available(anyAppleOS 27.0,
  *)` with **no platform carve-out** (verified) — resoves the [[phase4-core-navigation-atoms]] risk
  TODO "AsyncImage watchOS cache/phase limits".
- `CosmosAsyncImageAvailability.urlSessionInjectionAvailable(on:) -> Bool` — `true` on all 5 (the
  OS-27 version gate is runtime, in the applier; the table reports the platform gate only). Mirrors
  `CosmosTabRoleAvailability` (uniform OS-27, no carve).

## Deferred — flicker-avoidance timer (Wave-G refinement)

`AsyncImagePhase` has no `.loading` case, and no atom today consumes
`configuration.loading.delay` / `minimumDisplayTime` (fields declared, unused — no helper to copy).
The delay/minimumDisplayTime placeholder-flicker gate is a documented **Wave-G refinement**, not
Wave G itself — matches the low-risk-first wave ordering. The phase is authoritative for the slot.

## Forward compatibility — the later `CosmosImage`

`content: (Image) -> Content` takes the loaded `Image` and returns a view, so this atom is a clean
building block. The later unified `CosmosImage` (future wave) will be
`enum CosmosImageSource { case system(String); case resource(String, Bundle?); case url(URL?) }` —
`.system`/`.resource` delegate to [[cosmos-icon]] (already covers `systemName` /
`Image(_:bundle:)` / `Image(decorative:bundle:)`); `.url` delegates to `CosmosAsyncImage`. No
`CosmosImage` work in Wave G. `CosmosMock.imageURL(seed:width:height:)` + `badImageURL()` were added
for previews and the future `CosmosImage`.

## Testing

`Tests/CosmosTests/CosmosWaveGAtomsTests.swift` — `CosmosImageCache.defaultSession` has a non-nil
`urlCache` with the expected 16 MB / 128 MB capacities + configured timeouts; custom sizing honored;
the `static let defaultSession` is a stable once-token (identity-equal across calls);
`CosmosAsyncImageAvailability.urlSessionInjectionAvailable(on:)` true on all 5. (Retry/haptic/
transition are behavioral — not unit-tested, per the no-ViewInspector rule; covered by `#Preview`.)
198 tests passing; builds clean on all 5 platforms.