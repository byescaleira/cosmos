---
tags: [component, atom, image, asyncimage, sf-symbols, imageresource, os27, deprecation]
aliases: [CosmosImage, CosmosImagePlaceholder, CosmosImageFailure, cosmosImageURLSession, unified image atom]
related: [cosmos-async-image, cosmos-icon, cosmos-progress, cosmos-button, cosmos-textheader-pattern, ios-27-swiftui-above-floor-apis, phase4-core-navigation-atoms]
---

# CosmosImage

The unified image atom (0.11.0) — folds the SF Symbol / asset / typed `ImageResource` surface of
`CosmosIcon` and the remote-`AsyncImage` slot architecture of [[cosmos-async-image]] into one atom.
File: `Sources/Cosmos/Atoms/CosmosImage.swift`. Supersedes + deprecates both prior atoms (one minor
of runway); see [[cosmos-async-image]] for the historical Wave-G record.

## Why one atom, not three

`Image` has no style protocol (no `ImageStyle` / `AsyncImageStyle`), so every image atom is a
wrap-`View`. Three atoms (a static icon + a remote async image + a typed-resource shim) forced
consumers to pick by source and lost a single foreground-style / typography / accessibility
surface across them. `CosmosImage` exposes one atom with a private `Source` discriminator, so one
`.cosmosForegroundStyle` / `.cosmosFont` / `.cosmosAccessibilityLabel` override reaches every source.

## The `Source` discriminator (no `AnyView` erasure)

`CosmosImage<Content: View, Placeholder: View, Failure: View>: View` — generic over the async
slots, exactly like `CosmosAsyncImage`. A private enum selects the render path in `body`:

```swift
private enum Source {
    case direct(Content, isDecorativeSymbol: Bool)   // static: SF Symbol / asset / ImageResource / custom
    case remote(url: URL?, scale: CGFloat,
                content: (Image) -> Content,
                placeholder: () -> Placeholder,
                failure: (any Error, @escaping () -> Void) -> Failure)
}
```

This avoids `AnyView` (preserves slot structural identity across phase swaps — WWDC21-10022) and
avoids internal references to the deprecated `CosmosIcon` / `CosmosAsyncImage` (which would emit
deprecation warnings, breaking the zero-warnings binding). `CosmosImage` re-implements the two
short render chains itself rather than forwarding. Static inits constrain
`where Placeholder == EmptyView, Failure == EmptyView` (SwiftUI's public `EmptyView` as the no-slot
marker — a private marker would be unreachable from the public inits' `where` clauses); URL inits
keep the slots generic. The shared outer gate is `if configuration.enable.isVisible { … } else { EmptyView() }`.

Two private inner views split the static vs. remote **state altitude** so static icons carry zero
unused `@State`:

- `CosmosImageDirect<Content>` — the hot static path. **No `@State`**. Renders
  `.foregroundStyle(theme.colors.primary)` → `.font(theme.typography.font(for: theme.textStyle))`
  → `.accessibilityHiddenIf(isDecorativeSymbol)` → `.applyCosmosAccessibility(configuration.accessibility)`
  → `.onAppear { trackImageAppear() }`. The same chain `CosmosIcon` used.
- `CosmosImageRemote<Content, Placeholder, Failure>` — mirrors `CosmosAsyncImage`: `@State
  retryToken` / `failureToken`, `AsyncImage(url:scale:transaction:)` phase switch with
  `.cosmosTransition(.blurReplace)` per phase, the motion-policy-gated
  `Transaction(animation: resolvedAnimation)`, `.id(retryToken)` identity-reset retry,
  `CosmosAsyncImageSessionApplier`, `.cosmosHaptic(.error, trigger: failureToken)`,
  `applyCosmosAccessibility`, `reportFailure` (error report + tracking + haptic token bump).

## Inits — full superset (loses no capability vs. the two deprecated atoms)

**SF Symbols** (mirror `CosmosIcon`)
- `init(systemName: String)`
- `init(systemName: String, variableValue: Double)`
- `init(decorativeSystemName name: String)` — `isDecorativeSymbol = true` (SwiftUI has no
  `Image(decorativeSystemName:)`; the atom hides it via the accessibility config).

**Typed resource + asset images** (the typed `ImageResource` source is the new one)
- `init(_ resource: ImageResource)` — `Image(resource)` (the unlabeled init). **Typed, non-string.**
- `init(_ name: String, bundle: Bundle? = nil)`
- `init(decorative name: String, bundle: Bundle? = nil)`

**Custom content** (mirror `CosmosIcon` primary init)
- `init(@ViewBuilder content: @escaping () -> Content)`

**Remote (URL)** (mirror `CosmosAsyncImage`)
- `init(url: URL?, scale: CGFloat = 1, @ViewBuilder content:)` — default slots
  (`where Placeholder == CosmosAsyncImagePlaceholder, Failure == CosmosAsyncImageFailure`).
- `init(url: URL?, scale: CGFloat = 1, content:, placeholder:, failure:)` — typed generic slots.
- `@available(*, deprecated) init(url:scale:content:placeholder:failure:) where Placeholder == AnyView,
  Failure == AnyView` — the deprecated `AnyView` overload carried over (the more-constrained one,
  so legacy `AnyView` call sites resolve here and emit the migration warning).

**String-URL convenience** (NEW)
- `init(url: String, scale: CGFloat = 1, @ViewBuilder content:)` (+ typed-slot + deprecated-`AnyView`
  overloads) — parses `URL(string: url)`; nil → the placeholder path (matching `AsyncImage(url: nil)`).

**Ergonomic aliases** (the OS-27 surface stays in `CosmosAsyncImage.swift` this minor)
- `public typealias CosmosImagePlaceholder = CosmosAsyncImagePlaceholder`
- `public typealias CosmosImageFailure = CosmosAsyncImageFailure`
- `public func cosmosImageURLSession(_ session: URLSession?) -> some View` — delegates to
  `.cosmosAsyncImageURLSession(session)`.

## `ImageResource` — floor on all 5 platforms, no gate

Verified via PHASE2 §2.5: codegen present on iOS 17 / macOS 14 / tvOS 17 / watchOS 10 / visionOS 1,
all ≤ the `.v26` floor. **No `#if os()` or `@available` gate** for `ImageResource` or
`Image(resource:)`. Instances require codegen'd constants from an asset catalog; **Cosmos ships no
image assets** (only a String Catalog), so the `imageResource` init is **compile-verified only** in
the test suite (with an explanatory note) rather than runtime-constructed — preserving the library's
minimal-resource philosophy. Consumers with asset catalogs construct it at runtime.

## Decorative asymmetry (preserved from `CosmosIcon`)

- SF-Symbol decorative (`decorativeSystemName:`) needs the atom to hide it — no native
  `Image(decorativeSystemName:)` exists; done via `accessibilityHiddenIf(isDecorativeSymbol)`.
- Asset decorative (`decorative:bundle:`) is already hidden by `Image(decorative:bundle:)` native.

Stored as a `Bool` flag on the `.direct` case.

## Motion / haptics / tracking (unified under `CosmosImage`)

- **Motion:** static path = `none` (`.symbolEffect` is caller-driven and auto-respects Reduce
  Motion — gate on `isEnabled` only, never double-gate). Remote path = `.cosmosTransition(.blurReplace)`
  per phase + the motion-policy-gated `Transaction` (replicates the `.cosmosAnimation` chokepoint;
  nil → instant swap under Reduce Motion instant policy or motion disabled). All via
  `CosmosMotionPolicy.shouldEmit` (config-aware, not the bare env value) and
  `CosmosMotionTokens.animation(for:reduceMotion:policy:)`.
- **Haptics:** `.error` on remote failure appear (via `failureToken`), not on retry tap — the
  default retry `CosmosButton` fires its own `.impact(.light)`; no double haptic.
- **Tracking:** `"image_appear"` (static + url success) and `"image_failure"` (url failure),
  `component: "CosmosImage"`, `componentId = trackingId ?? accessibilityId`. Passive, opt-in, no
  success-appear spam on a list of images.

## Deprecation runway (mirrors `CosmosCard` 0.9.0)

`CosmosIcon` and `CosmosAsyncImage` are `@available(*, deprecated, message:)` on the struct + every
`public init`, with `- Deprecated:` doc bullets pointing here. **Inert in-place**: implementations
compile untouched (only the annotation is added); previews + dedicated `*Tests.swift` were removed
(constructing a deprecated type emits warnings → incompatible with the zero-warnings binding).
`CosmosImage` is a fresh parallel implementation, not a forwarder. One minor of runway before
obsoletion in a future Cosmos major; `CHANGELOG.md` `[0.11.0]` records the migration notes. The
shared OS-27 surface stays in `CosmosAsyncImage.swift` and is referenced directly by `CosmosImage`;
physical relocation to a non-deprecated home is **deferred to the obsoletion major** (noted in the
deprecation record + `CosmosAsyncImageSessionApplier`'s doc comment).

## Testing

`Tests/CosmosTests/CosmosImageTests.swift` — `@MainActor @Suite("CosmosImage")`, 16 tests:
construction (systemName, variableValue, decorativeSystemName, bundledAssetName,
decorativeBundledAsset, customContent, urlAndContent, nilUrl, stringUrl, invalidStringUrl,
customPlaceholderAndFailure) + the re-homed shared-machinery tests (`imageCacheDefaultSession*`,
`imageCacheCustomSizingHonored`, `imageCacheDefaultSessionIsStableOnceToken`,
`urlSessionInjectionAvailableOnAllPlatforms`). The `imageResource` init is compile-verified only
(no asset catalog → no runtime construction). 356 tests green (354 − 9 deleted + 16 new − 5 net
re-homed counted once). Retry/haptic/transition are behavioral — not unit-tested, per the
no-ViewInspector rule; covered by co-located `#Preview` blocks.

## Open risks / TODOs

- Relocate the OS-27 cache / `urlSession` machinery out of `CosmosAsyncImage.swift` at obsoletion.
- `.allowedDynamicRange` / `Image.DynamicRange` watchOS guard (PHASE2 §2.5) — not part of this atom's
  surface; a future `cosmosImageDynamicRange` modifier if needed.
- Full obsoletion (file deletion) of `CosmosIcon` / `CosmosAsyncImage` — future Cosmos major.