# Architecture: Cosmos

## Overview

Cosmos is a multi-platform SwiftUI design system distributed as an SPM package. It starts with two shared, mutable-by-replacement value types distributed through the SwiftUI `Environment`:

- `CosmosConfiguration` — cross-cutting **behavior** contracts: accessibility, localization, log, error, loading, and enablement.
- `CosmosTheme` — visual **tokens**: colors, typography, spacing, radii, plus component style selectors.

Every component — atom, molecule, or organism — reads both values via the environment.

## Goals

1. **Shared foundation first:** every component inherits the same base contract.
2. **Modularity:** import `CosmosBase` alone for the foundation, or `Cosmos` for the full component library.
3. **Testability:** value types and plain environment keys are easy to unit-test.
4. **Maintainability:** atomic design keeps component scope small and composable.
5. **Concurrency safety:** Swift 6 strict mode; public types are `Sendable`.
6. **Apple-aligned:** follow SwiftUI, Accessibility, and Localization guidelines.

## Non-goals

- Backwards compatibility with pre-v26 Apple platforms.
- UIKit support.
- Runtime theming engine (static bundles only for now).
- Component library without a finished base.

## Stack

- Swift 6.2
- SwiftUI
- Swift Testing
- DocC

## Structure

```
Cosmos/
├── Sources/
│   ├── CosmosBase/          # Foundation
│   │   ├── Configuration/   # CosmosConfiguration + six contracts
│   │   ├── Theme/           # CosmosTheme + color/typography/spacing/radius tokens
│   │   └── Environment/     # @Entry definitions and focused modifiers
│   ├── Cosmos/              # Design system components
│   │   ├── Atoms/           # Flat folder: Button, Text, Icon, Image, Label, Link, TextField, Toggle, Progress, Slider, Picker, Stepper, DatePicker, Menu, Badge, Divider, Spacer, Section, List, TabView
│   │   └── Molecules/       # InputRow, ListRow, FormRow, EmptyState, ButtonRow, SearchBar, StatusRow, Card, AlertBanner, LoadingState
│   └── CosmosScreen/        # Data-driven screen assembly
│       ├── Model/           # CosmosScreen, CosmosComponent
│       ├── Renderer/        # CosmosScreenRenderer
│       └── Registry/        # CosmosActionRegistry
└── Tests/
    ├── CosmosTests/         # Base + atom unit tests
```

## Configuration and theme

Both `CosmosConfiguration` and `CosmosTheme` are `Sendable` `struct` value types. Mutations happen by replacement:

1. **Replace the whole object** through the environment: `.cosmosConfiguration(newConfig)` or `.cosmosTheme(newTheme)`.
2. **Mutate a local copy** inside `@State` and re-inject it.
3. **Apply focused modifiers** to a subtree: `.cosmosEnabled(false)`, `.cosmosLoading(true)`, `.cosmosRedacted(true)`, `.cosmosAccessibilityLabel("Dismiss")`, `.cosmosControlSize(.large)`.

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

This avoids `@Observable` + `@MainActor` friction and keeps the objects testable off the main actor. Atoms have minimal, content-only initializers; state and configuration come from the environment.

`@Entry` (SwiftUI v26) generates the `EnvironmentKey`, `EnvironmentValues` accessor, and view modifier from a single declaration:

```swift
extension EnvironmentValues {
    @Entry public var cosmosConfiguration: CosmosConfiguration = .default
    @Entry public var cosmosTheme: CosmosTheme = .default
}
```

Focused modifiers (`.cosmosEnabled`, `.cosmosLoading`, etc.) are implemented as `ViewModifier`s that read the current value from the environment, mutate a copy, and re-inject it with `.environment(_:_:)`. This preserves the upstream configuration while overriding a single field for the subtree.

## Base contracts

All contracts live in `CosmosBase/Configuration` and are owned by `CosmosConfiguration`:

| Contract | Responsibility |
|---|---|
| `CosmosAccessibilityConfiguration` | labels, hints, traits, hidden state, sort priority |
| `CosmosLocalizationConfiguration` | locale, bundle, string/plural resolution |
| `CosmosLogConfiguration` | log level, category, event handler |
| `CosmosErrorConfiguration` | error source, metadata, handler |
| `CosmosLoadingConfiguration` | loading flag, delay, minimum display time |
| `CosmosEnableConfiguration` | enabled, visible, read-only flags |
| `CosmosRedactionConfiguration` | placeholder redaction flag |

## Theme tokens

`CosmosBase/Theme` defines semantic token collections:

| Token | Responsibility |
|---|---|
| `CosmosColorTokens` | primary, secondary, accent, background, surface, success, warning, error |
| `CosmosTypographyTokens` | largeTitle, title, body, caption, etc. |
| `CosmosSpacingTokens` | none, xs, small, medium, large, xl, xxl |
| `CosmosRadiusTokens` | none, small, medium, large, full |

Selectors (`CosmosTextStyle`, `CosmosButtonStyle`, `CosmosIconScale`, `CosmosDividerStyle`, `CosmosPadding`, `CosmosControlSize`) remain on `CosmosTheme` so atoms can pick a default look without exposing raw points.

## Data-driven screens

The `CosmosScreen` target renders a serializable screen model into SwiftUI:

- `CosmosScreen` — identifier + array of `CosmosComponent`.
- `CosmosComponent` — `Sendable`, `Codable`, `Equatable` enum covering text, button, icon, image, label, link, textField, toggle, progress, slider, picker, stepper, datePicker, menu, badge, divider, spacer, the three stack axes, list, section, tabView, inputRow, listRow, formRow, emptyState, buttonRow, searchBar, statusRow, card, alertBanner, and loadingState.
- `CosmosScreenRenderer` — recursive renderer that maps each component case to its atom, wrapped in `AnyView` to break recursive opaque-type inference.
- `CosmosActionRegistry` — decouples serializable action identifiers from runtime closures.
- `CosmosScreenLoader` — decodes `CosmosScreen` from JSON using a snake-case decoder.

This layer lets screens be defined as JSON or server payloads and rendered with the same atoms used by hand-written UI.

## UI testing strategy

Cosmos ships without third-party UI testing dependencies. Visual and structural validation happens through:

- **Swift Testing** — unit tests for models, configuration, theme, and JSON round-trips.
- **Xcode Previews** — visual regression and state inspection during development.
- **Catalog app** (planned) — a dedicated `CosmosPreview` executable target that renders every atom and molecule in default, disabled, loading, redacted, dark mode, and dynamic-type states.

The project intentionally avoids snapshot and inspection libraries because none are provided by Apple. A future native alternative, if Apple introduces one, will be evaluated without breaking the public API.

## Conventions

- All public types are prefixed with `Cosmos`.
- Base contracts live in `CosmosBase`; components live in `Cosmos`.
- Components read configuration and theme from the environment; they do not own it.
- Atom initializers accept only content (text, label view, icon name). State, configuration, and theme are environment-driven.
- Previews are co-located with components using `#Preview`.
- Every public component has a Swift Testing unit test or a visible preview in the catalog app.

## Image loading

`CosmosImage` is the most complex atom because it supports multiple sources:

- **Resource bundle assets** via `Image(_:bundle:)`.
- **SF Symbols** via `Image(systemName:)`.
- **Remote URLs** via `AsyncImage`, accepting both `URL` and `String` forms.

Remote images use SwiftUI's shared URL cache by default; the component exposes
a `contentShape` placeholder for loading and failure states, and automatically
applies redaction when the environment reports `isLoading` or `isRedacted`.

## Input atoms

`CosmosTextField`, `CosmosToggle`, `CosmosSlider`, and `CosmosPicker` require
`Binding` values because their state is inherently owned by the caller. They
still read their enabled/visible/redacted state from `CosmosConfiguration`,
keeping behavioral overrides environment-driven while acknowledging that
editable controls cannot be fully content-only.

## Container atoms

Three atoms manage child layout and selection:

- `CosmosSection<Header, Footer, Content>` — wraps SwiftUI `Section` with optional header and footer.
- `CosmosList` — wraps SwiftUI `List`, supports multi-selection via `Binding<Set<String>>`, and maps `CosmosListStyle` to native `ListStyle` values. The `.grouped` and `.insetGrouped` styles are unavailable on macOS, so they fall back to `.automatic` at compile time.
- `CosmosTabView` — adaptive tab container. On `.compact` horizontal size classes it renders a `TabView`; on `.regular` it renders a `NavigationSplitView` sidebar. The adaptive behavior can be overridden via the `.cosmosTabAdaptiveStrategy(_:)` environment value.

These atoms stay native-first: they use SwiftUI primitives and size classes rather than orientation or idiom checks, aligning with the iOS 27 resizable-app guidance.

## Molecules

Molecules are small, recognizable combinations of atoms:

- `CosmosInputRow` — `CosmosLabel` + `CosmosTextField` for labeled form inputs.
- `CosmosListRow` — icon + title/subtitle + trailing element (`none`, `badge`, `chevron`, `text`) for list content.
- `CosmosFormRow` — `CosmosLabel` + trailing control (`toggle`, `picker`, `stepper`, `slider`, `value`) for settings rows.
- `CosmosEmptyState` — image + title + subtitle + button for empty/error/onboarding placeholders.
- `CosmosButtonRow` — full-width icon + text button for primary CTAs and list-style actions.
- `CosmosSearchBar` — search icon + text field + clear button with rounded surface background.
- `CosmosStatusRow` — icon/image + title/subtitle + optional badge for status and notification rows.
- `CosmosCard` — optional image + title + subtitle + badge + button for content cards.
- `CosmosAlertBanner` — icon + title + optional action button with info/success/warning/error variants.
- `CosmosLoadingState` — progress indicator + optional title/subtitle for loading placeholders.

Interactive molecules accept `Binding` values in Swift code. In `CosmosScreen` JSON the renderer creates a local `@State` wrapper initialized from the model's `initialValue` and dispatches actions through `CosmosActionRegistry` when the value changes. This keeps JSON declarative while supporting live controls. Non-interactive molecules such as `CosmosStatusRow`, `CosmosCard`, `CosmosAlertBanner`, and `CosmosLoadingState` are rendered directly from their models.

## Dependencies

- None at runtime.
- Swift Testing is part of the Swift toolchain.
