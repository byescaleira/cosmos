# Cosmos — Project Guidelines

Cosmos is a SwiftUI design-system SwiftPM library. These guidelines are **binding** for all work in this repository.

## Stack & targets
- Swift **6.4** toolchain, **Swift language mode v6**, Xcode 26.
- Platforms: **iOS / macOS / tvOS / watchOS / visionOS — all at `.v26`**. Every component must compile and behave well on all 5.
- Single target `Cosmos`, no third-party dependencies. Tests in `CosmosTests` (Swift Testing, no UI snapshots, no ViewInspector).

## No UIKit
Never author UIKit symbols: no `import UIKit`, `UIColor`, `UIViewController`, `UIHostingController`, or `#if canImport(UIKit)`.
- `Color(.systemBackground)` and similar that wrap UIKit internally are fine (no UIKit symbols written).
- Font registration uses **CoreText** (`CTFontManagerRegisterFontsForURL`), not UIKit.
- Haptics use **`.sensoryFeedback`** (SwiftUI, iOS 17+), not `UIImpactFeedbackGenerator`.

## State & theme are GLOBAL (not per-component)
Components do **not** own per-component state/theme structs. All cross-cutting concerns flow through the SwiftUI environment via `@Entry`:
- `cosmosConfiguration: CosmosConfiguration` — behavior/state (enable, loading, accessibility, haptics, **motion**, tracking, localization, log, error).
- `cosmosTheme: CosmosTheme` — visual tokens (colors, typography, padding, textStyle, buttonStyle, controlSize, **motion**, version).
- `cosmosTrackingId: String?` — analytics id fallback (defaults to `accessibilityIdentifier`).

Each atom reads its relevant subset explicitly. Per-instance overrides use `.cosmos*` modifiers that read the env, mutate a copy via `.with*`, and re-inject. Runtime-mutable (live-switched) theming uses `CosmosThemeObservable` (`@Observable @MainActor`).

Motion is split like the rest: behavior/policy in `cosmosConfiguration.motion` (`CosmosMotionConfiguration` — the 9th cross-cutting contract); visual tokens in `cosmosTheme.motion` (`CosmosMotionTokens` — springs, durations, transition presets). Atoms never write raw `Animation.spring(...)`/`.transition(.move...)`; they call `.cosmosAnimation(.press, value: x)` / `.cosmosTransition(.sheet)`, which resolve tokens through `CosmosMotionTokens.animation(for:)` (the single source of truth) and gate reduce-motion through `CosmosMotionPolicy` (config-aware, not the bare env value). Per-instance overrides: `.cosmosMotion(_:)` (behavior), `.cosmosMotionTokens(_:)` / `.cosmosSpringStyle(_:)` (visual).

## Modern Swift 6 concurrency — zero warnings
The project must build with **zero concurrency warnings** under Swift 6 mode. Fix isolation/Sendable; do not silence.
- All public value types are `Sendable` (derived conformance; avoid `@unchecked`).
- Handler closures in configurations are `@Sendable`.
- **No `NSLock`, no `DispatchQueue` for synchronization, no `nonisolated(unsafe)` mutable globals.**
- One-time idempotent work (e.g. font registration): the **once-token pattern** — a `static let` whose initializer side-effect runs exactly once, thread-safely, via `swift_once`. No lock primitive needed.
- When a mutable flag is genuinely unavoidable: `Mutex<T>` / `Atomic<T>` from `import Synchronization` (Swift 6.0+). Never raw locks.
- Runtime theme: `@Observable @MainActor`; inject so access stays main-actor-isolated.
- `@Entry` environment values must be `Sendable`.

## Versioning — Cosmos N ↔ OS N
- A Cosmos major version equals the OS major it targets. **Current baseline: Cosmos 26** (OS 26 / Liquid Glass).
- API availability IS Cosmos API versioning: "available since Cosmos 26" == `@available(iOS 26, *)`. Centralize `if #available` gates for OS-introduced features (Liquid Glass/`glassEffect` iOS 26; `.sidebarAdaptable`/`Tab`/`.sectionActions` iOS 18; `listSectionSpacing`/`ShapeStyle.resolve(in:)`/`symbolEffect`/`.sensoryFeedback` iOS 17).
- `CosmosTheme.version: CosmosVersion` is a runtime **design-language pin**; apps may fix it to keep an older look on a newer OS. Default `.cosmos26`.
- Within a Cosmos major: semver minor/patch. Deprecate with `@available(*, deprecated, message:)` + a migration runway before obsoletion. Policy in `VERSIONING.md`; changes in `CHANGELOG.md`.

## Cross-cutting concerns — every component
Every atom/molecule integrates, where relevant: (1) **accessibility** (label/value/hint/identifier/traits/customContent + env gates `reduceMotion`/`reduceTransparency`/`colorSchemeContrast`/`differentiateWithoutColor` + Dynamic Type reflow); (2) **haptics** (`.sensoryFeedback` gated by config + `reduceMotion`; no-op where no hardware); (3) **localization** (strings via `CosmosLocalizationConfiguration`); (4) **tracking** (`CosmosTrackingConfiguration.track(_:)` with `componentId = trackingId ?? accessibilityId`; opt-in, passive, no network/PII); **(5) motion** (`.cosmosAnimation(_ kind:value:)` / `.cosmosTransition(_:)` / `.cosmosContentTransition(_:)` gated by `CosmosMotionConfiguration` + `accessibilityReduceMotion`/`accessibilityReduceTransparency`; tokens from `CosmosMotionTokens` in `CosmosTheme`; coordinated with haptics on press; springs preferred over bezier for velocity preservation).

### Motion — reduce-motion + reduce-transparency
- Detect via `@Environment(\.accessibilityReduceMotion)`, `@Environment(\.accessibilityReduceTransparency)`, `@Environment(\.colorSchemeContrast)`, `@Environment(\.accessibilityDifferentiateWithoutColor)` — the same gates already named above.
- Gate through `CosmosMotionPolicy.shouldEmit(isEnabled:respectReduceMotion:reduceMotion:)` (mirrors `CosmosHapticsPolicy`), NOT the bare env value, so `configuration.motion.respectReduceMotion = false` can intentionally override.
- `CosmosReduceMotionPolicy`: `.substitute` (default — spatial → opacity crossfade, vestibular-safe, keeps feedback), `.instant` (snap), `.preserve` (only when motion is the sole state signal — WCAG 2.3.3 exempt).
- **Symbol effects (`.symbolEffect`) already auto-respect Reduce Motion — gate them on `isEnabled` only; do NOT double-gate on `respectReduceMotion`.**
- Continuous/looping motion (`PhaseAnimator`, indefinite `symbolEffect`) suppressed under reduce-motion unless the sole progress signal (`.preserve`).
- Synchronize via one `withAnimation(theme.motion.spring(for: .containerTransform).animation) { … }` per coordinated state change; avoid per-view `.animation(_:value:)` with differing curves (desyncs). `matchedGeometryEffect` uses one `@Namespace`, single `isSource: true`, driven by one `withAnimation`.
- **No `if #available` gating is needed for any motion primitive** at the Cosmos 26 baseline (Spring/PhaseAnimator/KeyframeAnimator/blurReplace/symbolEffect/withAnimation(completion)/transition<T>/matchedGeometryEffect are all iOS 17/18 ≤ 26 on all 5 platforms). Gate `GlassEffectTransition.matchedGeometry` (iOS 26) only if the floor ever lowers.

## Layout — portrait ↔ landscape
Prefer `AnyLayout` / `ViewThatFits` switched by `horizontalSizeClass` / `verticalSizeClass` / `dynamicTypeSize` so view identity (focus/scroll/animation state) survives reflow. No `if/else` that recreates view identity on rotation.

## Localization — modern stack (no plugin)
String Catalogs (`.xcstrings`) compiled via `.process("Resources")` in `Package.swift`. Resolve with `LocalizedStringResource` / `#bundle` / `String(localized:)` and public string-constant symbols. Baseline `en` + `pt-BR`, extensible. No `Bundle.module` string-table plumbing, no build plugin.

## Atom conventions
- Prefix everything `Cosmos`.
- Atoms expose inits of **content only**; state/theme come from the environment and `.cosmos*` modifiers.
- Components with a conformable style protocol (`ButtonStyle`, `ToggleStyle`, `LabelStyle`, `ProgressViewStyle`, `GroupBoxStyle`, `MenuStyle`) use it + SE-0299 dot-syntax (`where Self ==`). Components without one (Slider, Stepper, TextField/SecureField/TextEditor, DatePicker, Picker, List, Section, TabView, Divider, Image, Link, Spacer) wrap a `View`.
- Honor each component's customization limitations (see `DECISIONS.md`). Gate platform-absent components with `#if os()`.
- Custom fonts use `Font.custom(_:size:relativeTo:)` — **always pass `relativeTo:`** so Dynamic Type scales (including accessibility sizes).

## Build & verify
`swift build && swift test && swift build -c release`. Build for **each** target platform to confirm `#if os()` coverage. Visual verification via co-located `#Preview` (default / disabled-loading / dark / Dynamic Type accessibility / landscape / per-platform).

Motion and preview helpers compile on all 5 platforms at `.v26` with zero concurrency warnings. Mock RNG shared state uses `Mutex<CosmosPreviewRNG>` (`import Synchronization`) — never a raw `static var` mutable global.

### Preview infrastructure
- Co-located `#Preview` blocks at the bottom of each atom file (default / disabled-loading / dark / Dynamic Type accessibility / landscape / RTL / per-variant). One named block per variant; the display name is the `#Preview("…")` first positional arg.
- **Do NOT use the deprecated view modifiers** `.previewDevice` / `.previewLayout` / `.previewDisplayName` / `.previewInterfaceOrientation` / `.previewContext` (all `@available(anyAppleOS, deprecated: 27.0)`). Use `#Preview(_:traits:)` — `.sizeThatFitsLayout`, `.fixedLayout(width:height:)`, `.landscapeLeft`/`.portrait`/etc.
- Inject environment overrides via `.cosmosPreviewEnv(...)` / `.cosmosPreviewVariant(_:)`. Accessibility env keys (`accessibilityReduceMotion`/`accessibilityReduceTransparency`/`accessibilityDifferentiateWithoutColor`/`colorSchemeContrast`) are **get-only public** — inject via the underscore SPI (`._accessibilityReduceMotion`, `._accessibilityReduceTransparency`, `._accessibilityDifferentiateWithoutColor`, `._accessibilityShowButtonShapes`, `._colorSchemeContrast`); these are stable and used by Apple's own preview tooling. `colorScheme`/`dynamicTypeSize`/`locale`/`layoutDirection`/size classes are directly settable.
- Shared preview setup (font registration, default theme/config) via `CosmosPreviewModifier: PreviewModifier` (iOS 18+, available at `.v26`): `#Preview("…", traits: .modifier(CosmosPreviewModifier()))`. `makeSharedContext()` is `@MainActor async throws`.
- Deterministic mock data via `CosmosMock` (seeded `CosmosPreviewRNG` SplitMix64); primary generators take `inout CosmosPreviewRNG` (zero shared state), convenience overloads use `CosmosMock.shared` (`Mutex`-protected). No third-party deps; no UIKit; `Color(hue:saturation:brightness:opacity:)` for mock colors.