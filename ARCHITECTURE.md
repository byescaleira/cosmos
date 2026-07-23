# Architecture: Cosmos

## Overview

Cosmos is a multi-platform SwiftUI design system distributed as a single SwiftPM module — one
`import`, one target, no third-party dependencies. It wraps the native SwiftUI control set so every
component reads the same global behavior and appearance contracts from the SwiftUI environment,
instead of carrying per-component state and theme structs.

Three `Sendable` value types flow through the environment as `@Entry` values:

- **`CosmosConfiguration`** — nine cross-cutting **behavior** contracts: accessibility,
  localization, log, error, loading, enable, haptics, **motion**, and tracking.
- **`CosmosTheme`** — visual **tokens**: colors, typography, spacing, radii, **motion**
  (springs/durations/transitions), plus the default selector for each component family
  (`buttonStyle`, `toggleStyle`, `pickerStyle`, …) and a runtime design-language pin (`version`).
- **`cosmosTrackingId: String?`** — analytics id fallback (defaults to `accessibilityIdentifier`).

Every component reads the relevant subset of these in `body`. Both `CosmosConfiguration` and
`CosmosTheme` default to sensible values, so every atom renders correctly without explicit
injection. Override a contract for a subtree and the change propagates to every descendant atom.

## Goals

1. **Shared foundation first:** every component inherits the same base contracts.
2. **Single target, single module:** `Base` (foundation) and `Atoms` (component library) live in
   one `Cosmos` target; import only what you use.
3. **Testability:** value types and plain environment keys are easy to unit-test off the main actor.
4. **Concurrency safety:** Swift 6 strict mode; public types are `Sendable`; zero warnings.
5. **Apple-aligned:** SwiftUI, Accessibility, Localization, and Motion guidelines.

## Non-goals

- Backwards compatibility with pre-v26 Apple platforms (Cosmos major == OS major; baseline Cosmos 26).
- UIKit support or any explicit UIKit dependency.
- Per-component state/theme structs (concerns are global via `@Entry`).
- A data-driven screen engine / JSON renderer (an earlier direction, since discarded — see
  `ROADMAP.md` and `vault/`).
- Atomic-design molecules / organisms / screens (folders removed; atoms compose directly).

## Stack

- Swift 6.4 (language mode v6), Xcode 26
- SwiftUI
- Swift Testing
- DocC

## Structure

One folder per **kind of thing**, so a file's home is predictable by kind, not by name:

```
Sources/Cosmos/
├── Base/
│   ├── Configuration/   # CosmosConfiguration + the 9 behavior contracts
│   ├── Theme/           # CosmosTheme + color/typography/spacing/radius/motion tokens
│   │                    # + style/role selector enums (CosmosButtonStyle, CosmosTabRole, …)
│   │                    # + CosmosThemeObservable / CosmosVersion / CosmosPlatform
│   ├── Environment/     # @Entry definitions + env-reading helpers (a11y/haptics/motion)
│   │                    # + shared runtime singletons (CosmosResources bundle accessor)
│   └── Preview/         # Preview/mock infrastructure (CosmosMock, CosmosPreviewRNG,
│                        # CosmosPreviewModifier, CosmosPreviewContainer/Variant)
├── Atoms/               # Public component Views/Styles (one file per atom;
│                        # atom-specific chrome/applier/availability co-located in that file)
├── Modifiers/           # ViewModifiers + the View extensions that apply them (.cosmos*)
└── Resources/          # Compiled resources (Localizable.xcstrings String Catalog)
```

`Tests/CosmosTests/` holds the Swift Testing suites (no UI snapshots, no ViewInspector).

## Configuration and theme

`CosmosConfiguration` and `CosmosTheme` are `Sendable` `struct` value types. Mutations happen by
replacement:

1. **Replace the whole object** through the environment: `.cosmosConfiguration(newConfig)` or
   `.cosmosTheme(newTheme)`.
2. **Mutate a local copy** inside `@State` and re-inject it.
3. **Apply focused modifiers** to a subtree: `.cosmosEnabled(false)`, `.cosmosLoading(true)`,
   `.cosmosAccessibilityLabel("Dismiss")`, `.cosmosControlSize(.large)`.

```swift
@State private var configuration = CosmosConfiguration.default
@State private var theme = CosmosTheme.default

var body: some View {
    VStack {
        CosmosButton("Save") { }
            .cosmosLoading(true)
        CosmosText("Hello")
    }
    .cosmosConfiguration(configuration)
    .cosmosTheme(theme)
}
```

`@Entry` (SwiftUI v26) generates the `EnvironmentKey`, `EnvironmentValues` accessor, and view
modifier from a single declaration:

```swift
extension EnvironmentValues {
    @Entry public var cosmosConfiguration: CosmosConfiguration = .default
    @Entry public var cosmosTheme: CosmosTheme = .default
    @Entry public var cosmosTrackingId: String? = nil
}
```

Focused modifiers (`.cosmosEnabled`, `.cosmosLoading`, `.cosmosFont`, …) are `ViewModifier`s that read
the current value from the environment, mutate a copy, and re-inject it with `.environment(\.…, …)`.
This preserves the upstream value while overriding a single field for the subtree — so overrides are
**subtree-scoped** and compose with every other selector.

## Base contracts

All contracts live in `Base/Configuration` and are aggregated by `CosmosConfiguration`:

| Contract | Responsibility |
|---|---|
| `CosmosAccessibilityConfiguration` | labels, hints, value, traits, custom content, hidden, sort priority, responds-to-user-interaction |
| `CosmosLocalizationConfiguration` | locale, bundle, string / plural resolution |
| `CosmosLogConfiguration` | log level, category, event handler |
| `CosmosErrorConfiguration` | error source, metadata, handler |
| `CosmosLoadingConfiguration` | loading flag, delay, minimum display time |
| `CosmosEnableConfiguration` | enabled, visible, read-only flags |
| `CosmosHapticsConfiguration` | isEnabled, respectReduceMotion, handler (`.sensoryFeedback`) |
| `CosmosMotionConfiguration` | isEnabled, respectReduceMotion, reduceMotionPolicy, respectReduceTransparency, handler |
| `CosmosTrackingConfiguration` | isEnabled, track(_:) (componentId = trackingId ?? accessibilityId) |

All `Sendable`; handlers `@Sendable`. Motion is split behavior (`CosmosConfiguration.motion`) /
visual (`CosmosTheme.motion`) — see `DECISIONS.md` (2026-07-17).

## Theme tokens

`Base/Theme` defines semantic token collections + the style/role selectors atoms pick a default
look from:

| Token / selector | Responsibility |
|---|---|
| `CosmosColorTokens` | primary, secondary, accent, background, surface, success, warning, error, outline |
| `CosmosTypographyTokens` | text-style scale + optional weight/design + optional custom font (system by default) |
| `CosmosSpacingTokens` | none, xs, small, medium, large, xl, xxl (4-pt grid) |
| `CosmosRadiusTokens` | none, small, medium, large, full |
| `CosmosMotionTokens` | spring presets, duration scale, transition / content-transition presets + the `animation(for:reduceMotion:policy:)` resolver |
| `CosmosTextStyle`, `CosmosButtonStyle`, `CosmosToggleStyle`, `CosmosLabelStyle`, `CosmosProgressStyle`, `CosmosGroupBoxStyle`, `CosmosMenuStyle`, `CosmosPickerStyle`, `CosmosListStyle`, `CosmosTabViewStyle`, `CosmosDatePickerStyle`, `CosmosTextFieldStyle`, `CosmosTextEditorStyle`, `CosmosPadding`, `CosmosControlSize`, `CosmosSpringStyle`, `CosmosTabRole` | default selector per component family, on `CosmosTheme` |

## Atoms

Two shapes, by what the underlying SwiftUI component allows:

- **Style-protocol atoms** (`ButtonStyle`, `ToggleStyle`, `LabelStyle`, `ProgressViewStyle`,
  `GroupBoxStyle`, `MenuStyle`) adopt the protocol + SE-0299 dot-syntax: `CosmosButton`,
  `CosmosToggle`, `CosmosLabel`, `CosmosProgress`, `CosmosGroupBox`, `CosmosMenu`.
- **Wrap-`View` atoms** for the components with no conformable style protocol: `CosmosText`,
  `CosmosLocalizedText`, `CosmosIcon`, `CosmosAsyncImage`, `CosmosLink`, `CosmosDivider`,
  `CosmosHStack`, `CosmosVStack`, `CosmosAdaptiveStack`, `CosmosScrollView`, `CosmosSection`,
  `CosmosList`, `CosmosSelectableList`, `CosmosTabView`, `CosmosTextField`, `CosmosSecureField`,
  `CosmosTextEditor`, `CosmosSlider`, `CosmosStepper`, `CosmosDatePicker`, `CosmosPicker`,
  `CosmosCard`, `CosmosToast`.

Atoms have minimal, content-only initializers; state and configuration come from the environment.
Input atoms that require `Binding` (`CosmosTextField`, `CosmosToggle`, `CosmosSlider`,
`CosmosPicker`, …) accept the binding from the caller while still reading enabled/visible/loading
from `CosmosConfiguration` — behavioral overrides stay environment-driven even where editable
controls cannot be fully content-only.

**Atoms impose theme-driven visual defaults and read the relevant tokens in `body`** so the
`.cosmosFont` / `.cosmosForegroundStyle` / `.cosmosTint` / `.cosmosControlSize` subtree overrides
reach them. An atom is never pass-through for a token its override surface promises
(`DECISIONS.md`, 2026-07-23). Raw SwiftUI `.font` / `.foregroundStyle` / `.tint` remain available as
one-off escape hatches.

## Cross-cutting integration

Every atom integrates, where relevant: **accessibility** (label/value/hint/identifier/traits/
custom content + env gates reduceMotion/reduceTransparency/colorSchemeContrast/
differentiateWithoutColor + Dynamic Type reflow), **haptics** (`.sensoryFeedback` gated by config +
reduceMotion), **motion** (`.cosmosAnimation` / `.cosmosTransition` / `.cosmosContentTransition`
gated by `CosmosMotionPolicy`, never raw `Animation.spring`/`.transition`; symbol effects
auto-respect Reduce Motion — gated on `isEnabled` only), **localization** (String Catalogs), and
**tracking** (`CosmosTrackingConfiguration.track(_:)`, opt-in, passive, no network/PII).

## Localization

Cosmos uses String Catalogs (`.xcstrings`) compiled via `.process("Resources")` in `Package.swift`
and resolved with `LocalizedStringResource` / `String(localized:)` / public string-constant symbols.
`CosmosResources.bundle` (`Bundle.module`) is the compiled resource bundle accessor. Baseline `en`
+ `pt-BR`, extensible. Cosmos ships **no bundled fonts** — it defaults to the system font;
consumers register custom fonts in their app and pass the PostScript name via `.cosmosFont(_:for:)`.

## Runtime theming

For live-switched theming, `CosmosThemeObservable` is an `@Observable @MainActor` holder injected
through `.environment(_:)` and read with `@Environment(CosmosThemeObservable.self)` — so mutable
theme access stays main-actor-isolated (see `DECISIONS.md`).

## UI validation

No third-party UI testing dependencies (none provided by Apple). Validation runs through:

- **Swift Testing** — unit tests for tokens, configuration, theme, motion policy, and atom
  construction/behavior (`Tests/CosmosTests/`).
- **Co-located `#Preview(_:traits:)`** — visual + state inspection at the bottom of each atom file
  (default / dark / Dynamic Type accessibility / landscape / RTL / per-platform), using
  `.cosmosPreviewEnv(…)` / `.cosmosPreviewVariant(…)` / `CosmosPreviewModifier`. The deprecated
  `.previewDevice` / `.previewLayout` / `.previewDisplayName` / `.previewInterfaceOrientation` /
  `.previewContext` modifiers are not used.
- **`CosmosMock`** — deterministic mock data (seeded `CosmosPreviewRNG` SplitMix64) for previews/tests.

## Conventions

- All public types are prefixed with `Cosmos`.
- Components read configuration and theme from the environment; they do not own it.
- Atom initializers accept only content; state, configuration, and theme are environment-driven.
- Custom fonts use `Font.custom(_:size:relativeTo:)` — always `relativeTo:` so Dynamic Type scales.
- No `UIKit` symbols are authored (haptics via `.sensoryFeedback`; fonts via CoreText; colors via
  SwiftUI `Color`). SwiftUI APIs that wrap UIKit internally are acceptable.
- `#if os()` gates platform-absent components; `if #available` for above-floor features is
  centralized and mirrors the SDK `@available` it guards.
- Deprecate with `@available(*, deprecated, message:)` + a migration runway before obsoletion
  (`VERSIONING.md`); record changes in `CHANGELOG.md`.

## Targets

`Cosmos` ships as a single SPM target on iOS / macOS / tvOS / watchOS / visionOS — all at `.v26`.
Consumers import one module:

```swift
import Cosmos
```

See `DECISIONS.md` for the architectural decisions, `VERSIONING.md` for the versioning policy, and
`vault/` for the research / decision synthesis layer.