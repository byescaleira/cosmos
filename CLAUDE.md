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
- `cosmosConfiguration: CosmosConfiguration` — behavior/state (enable, loading, accessibility, haptics, tracking, localization, log, error).
- `cosmosTheme: CosmosTheme` — visual tokens (colors, typography, padding, textStyle, buttonStyle, controlSize, version).
- `cosmosTrackingId: String?` — analytics id fallback (defaults to `accessibilityIdentifier`).

Each atom reads its relevant subset explicitly. Per-instance overrides use `.cosmos*` modifiers that read the env, mutate a copy via `.with*`, and re-inject. Runtime-mutable (live-switched) theming uses `CosmosThemeObservable` (`@Observable @MainActor`).

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
Every atom/molecule integrates, where relevant: (1) **accessibility** (label/value/hint/identifier/traits/customContent + env gates `reduceMotion`/`reduceTransparency`/`colorSchemeContrast`/`differentiateWithoutColor` + Dynamic Type reflow); (2) **haptics** (`.sensoryFeedback` gated by config + `reduceMotion`; no-op where no hardware); (3) **localization** (strings via `CosmosLocalizationConfiguration`); (4) **tracking** (`CosmosTrackingConfiguration.track(_:)` with `componentId = trackingId ?? accessibilityId`; opt-in, passive, no network/PII).

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