# Cosmos

[![CI](https://github.com/byescaleira/cosmos/actions/workflows/ci.yml/badge.svg)](https://github.com/byescaleira/cosmos/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/byescaleira/cosmos/branch/main/graph/badge.svg)](https://codecov.io/gh/byescaleira/cosmos)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Swift 6.4](https://img.shields.io/badge/Swift-6.4-orange.svg)](https://www.swift.org/)
[![Release](https://img.shields.io/github/v/tag/byescaleira/cosmos?label=release)](https://github.com/byescaleira/cosmos/tags)

> A clean-room SwiftUI design system for iOS, macOS, tvOS, watchOS, and visionOS 26.

## Overview

Cosmos is a SwiftUI design system distributed as a single SwiftPM module — one
`import`, one target, no third-party dependencies. It wraps the native SwiftUI
control set so every component reads the same global behavior and appearance
contracts from the SwiftUI environment, instead of carrying per-component state
and theme structs.

Two `Sendable` value types flow through the environment as `@Entry` values:

- **`CosmosConfiguration`** — nine cross-cutting behavior contracts:
  accessibility, localization, log, error, loading, enable, haptics, motion,
  and tracking.
- **`CosmosTheme`** — visual tokens: colors, typography, padding, radii, and
  the default selector for each component family (`buttonStyle`,
  `toggleStyle`, `pickerStyle`, …) plus motion tokens.

Both default to sensible values, so every atom renders correctly **without any
explicit injection**. Override a contract for a subtree and the change
propagates to every descendant atom.

## Requirements

- Swift 6.4 toolchain, Swift language mode v6, Xcode 26.
- Platforms, all at `.v26`: iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26.

Cosmos is SwiftUI-native. It contains no `UIKit` symbols — haptics use
`.sensoryFeedback`, fonts register through CoreText, and colors resolve through
 SwiftUI `Color`. It builds with zero concurrency warnings under Swift 6.

## Installation

Add Cosmos to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/byescaleira/cosmos.git", from: "0.3.0")
]
```

Then add `Cosmos` to your target dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "Cosmos", package: "cosmos")
    ]
)
```

## Getting started

Import the module and use the atoms directly. No environment setup is required
— defaults are already present:

```swift
import Cosmos
import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            CosmosText("Welcome to Cosmos")
            CosmosButton("Continue") {
                // handle tap
            }
            CosmosDivider()
        }
        .padding()
    }
}
```

## Atoms

Every component is prefixed `Cosmos`. Components with a conformable style
protocol (`ButtonStyle`, `ToggleStyle`, `LabelStyle`, `ProgressViewStyle`,
`GroupBoxStyle`, `MenuStyle`) adopt it and support SE-0299 dot-syntax; the rest
wrap a `View`.

| Atom | Notes |
|---|---|
| `CosmosButton` | `ButtonStyle`-based; glass variant available on iOS 26. |
| `CosmosCard` | Header / body / footer slots. |
| `CosmosDatePicker` | `DatePicker` wrapper; gated on platforms where it exists. |
| `CosmosDivider` | Theme-tinted divider. |
| `CosmosGroupBox` | Custom `GroupBoxStyle` chrome via theme tokens. |
| `CosmosIcon` | SF Symbol wrapper. |
| `CosmosLabel` | `LabelStyle`-based. |
| `CosmosLink` | `Link` wrapper. |
| `CosmosList` | `List` wrapper with theme list style. |
| `CosmosSelectableList` | `List(selection:)` wrapper (single or multi). |
| `CosmosLocalizedText` | Resolves a `LocalizedStringResource`. |
| `CosmosMenu` | `MenuStyle`-based. |
| `CosmosPicker` | `PickerStyle`-based; `.tabs` available since Cosmos 27. |
| `CosmosProgress` | `ProgressViewStyle`-based. |
| `CosmosSection` | `Section` wrapper with parent / content / footer. |
| `CosmosSecureField` | `SecureField` wrapper. |
| `CosmosSlider` | `Slider` wrapper (not available on tvOS). |
| `CosmosStepper` | `Stepper` wrapper (not available on tvOS). |
| `CosmosTabView` | `TabView` wrapper with theme style and roles. |
| `CosmosText` | Localized or verbatim text; optional key/verbatim (renders nothing for `nil`). |
| `CosmosTextField` | `TextFieldStyle`-based. |
| `CosmosTextEditor` | `TextEditor` wrapper (not on tvOS/watchOS). |
| `CosmosToast` | `.cosmosToast(isPresented:)` / `.cosmosToast(item:)` presentation modifier; role conveniences build a `CosmosToastContent` (icon + message). |
| `CosmosToggle` | `ToggleStyle`-based. |

## Behavior and appearance

### Inject a configuration or theme

Inject an environment value to override a contract for an entire subtree:

```swift
struct RootView: View {
    var body: some View {
        ContentView()
            // Disable interaction and opt into tracking for the whole tree:
            .environment(\.cosmosConfiguration, .default
                .withEnable(.init(isEnabled: false))
                .withTracking(.init(isEnabled: true)))
    }
}
```

### Override a single selector

The `.cosmos*` modifiers read the current theme, mutate a copy, and re-inject
it — so the change applies to descendants only:

```swift
VStack {
    CosmosButton("Save") { save() }
    CosmosButton("Cancel") { dismiss() }
}
.cosmosButtonStyle(.glass)      // visual token
.cosmosControlSize(.large)
.cosmosTextStyle(.headline)
.cosmosPadding(.large)
```

`.cosmosPadding(_:)` overrides the default padding selector for descendants. To apply a
token-scaled padding to a specific edge set directly, use the edge form
`.cosmosPadding(_:_:)`:

```swift
CosmosCard { … }
    .cosmosPadding(.horizontal, .large)   // large on leading/trailing only
    .cosmosPadding(.vertical, .medium)    // medium on top/bottom only
```

The edge set (`CosmosPaddingEdges`) mirrors SwiftUI's `Edge.Set` — `.all`, `.horizontal`,
`.vertical`, `.top`, `.bottom`, `.leading`, `.trailing` — and resolves through the 4-pt spacing
grid, so per-edge padding never falls back to raw points.

Available selectors include `.cosmosButtonStyle`, `.cosmosToggleStyle`,
`.cosmosPickerStyle`, `.cosmosListStyle`, `.cosmosTabViewStyle`,
`.cosmosDatePickerStyle`, `.cosmosMenuStyle`, `.cosmosGroupBoxStyle`,
`.cosmosLabelStyle`, `.cosmosProgressStyle`, `.cosmosTextFieldStyle`,
`.cosmosTextEditorStyle`, `.cosmosControlSize`, `.cosmosTextStyle`, and
`.cosmosPadding`.

#### Override a single color token

You don't need to rebuild a whole `CosmosTheme` to re-skin one color. Each
semantic color token has its own subtree-scoped modifier:

```swift
VStack {
    CosmosButton("Delete") { delete() }
}
.cosmosBackground(.black)        // root background token
.cosmosError(.red)              // error/destructive state token
.cosmosAccent(.yellow)          // accent/tint token
```

The nine tokens map to `theme.colors` fields: `.cosmosAccent`, `.cosmosPrimary`,
`.cosmosSecondary`, `.cosmosBackground`, `.cosmosSurface`, `.cosmosSuccess`,
`.cosmosWarning`, `.cosmosError`, `.cosmosOutline`. Each reads the env theme,
mutates one `CosmosColorTokens` field, and re-injects — the same pattern as the
other `.cosmos*` selectors, so the override applies to descendants only and
composes with every other selector.

### Cross-cutting features

Each atom integrates accessibility, haptics, motion, localization, and
tracking where relevant.

```swift
CosmosButton("Delete") { delete() }
    .cosmosLoading(true)
    .cosmosAccessibilityLabel("Delete item")
    .cosmosAccessibilityHint("Removes the item permanently")
    .cosmosAccessibilityIdentifier("delete-button")
    .cosmosTrackingId("delete")   // analytics id; falls back to a11y id
```

Condition modifiers — `.cosmosEnabled`, `.cosmosVisible`, `.cosmosReadOnly`,
`.cosmosLoading` — gate atoms consistently across every component family.

### Motion

Atoms never write raw `Animation.spring(...)` or `.transition(.move...)`.
They call the motion primitives, which resolve springs and transition presets
through `CosmosMotionTokens` and respect Reduce Motion through
`CosmosMotionPolicy` (config-aware, not the bare environment value):

```swift
someView
    .cosmosAnimation(.press, value: isPressed)
    .cosmosTransition(.sheet)
    .cosmosContentTransition(.numericText())
```

Per-instance motion overrides: `.cosmosMotion(_:)` (behavior) and
`.cosmosMotionTokens(_:)` / `.cosmosSpringStyle(_:)` (visual).

### Runtime-mutable theming

For live-switched theming, use `CosmosThemeObservable` — an
`@Observable @MainActor` holder injected through `.environment(_:)` and read
with `@Environment(CosmosThemeObservable.self)`:

```swift
import Cosmos
import SwiftUI

@main
struct MyApp: App {
    @State private var theme = CosmosThemeObservable()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(theme)
        }
    }
}

struct ContentView: View {
    @Environment(CosmosThemeObservable.self) private var theme

    var body: some View {
        CosmosButton("Toggle style") {
            theme.theme = theme.theme.withButtonStyle(.glass)
        }
    }
}
```

## Custom fonts

Cosmos ships no bundled fonts — it defaults to the system font. To use a custom
font, register it in your app and pass its PostScript name to the theme. The
font is resolved through `Font.custom(_:size:relativeTo:)`, so Dynamic Type
still scales it (including accessibility sizes).

Register the font in your app's `Info.plist` (iOS / tvOS / watchOS / visionOS)
under `UIAppFonts`, or register it programmatically with CoreText:

```swift
import CoreText

func registerFont(named name: String, in bundle: Bundle) {
    guard let url = bundle.url(forResource: name, withExtension: "ttf") else { return }
    CTFontManagerRegisterFontsForURL(url, .process, nil)
}
```

Then opt in at the theme level. Pass `nil` to return to the system font:

```swift
// At the root of your view tree:
ContentView()
    .cosmosCustomFont("DMSans-Regular")

// Or on a subtree:
VStack { CosmosText("Headline") }
    .cosmosCustomFont("DMSans-Regular")

// Programmatically on the theme value:
let theme = CosmosTheme.default.withCustomFont("DMSans-Regular")
```

## Localization

Cosmos uses String Catalogs (`.xcstrings`) compiled through `.process("Resources")`
in `Package.swift`. Resolve strings with `LocalizedStringResource`,
`String(localized:)`, and the public string-constant symbols. `CosmosText(_:)`
takes a localization key; `CosmosText(verbatim:)` bypasses localization. The
baseline covers `en` and `pt-BR` and is extensible.

## Platform adaptation

Cosmos targets all five platforms at `.v26` and gates platform-absent
components with `#if os()`. For layout that survives portrait ↔ landscape
reflow, prefer `AnyLayout` and `ViewThatFits` switched by `horizontalSizeClass`,
`verticalSizeClass`, and `dynamicTypeSize` — this preserves view identity
(focus, scroll position, animation state) across rotation. Every atom honors
Dynamic Type, Reduce Motion, Reduce Transparency, increased contrast, and
Differentiate Without Color through the configuration's accessibility contract.

## Development

```bash
swift build
swift test
swift build -c release
```

Tests use Swift Testing (no UI snapshots, no ViewInspector). Cosmos has no
third-party dependencies. Visual verification runs through co-located
`#Preview(_:traits:)` blocks at the bottom of each atom file (default, dark,
Dynamic Type accessibility, landscape, RTL, and per-platform variants).

## Versioning

A Cosmos major version equals the OS major it targets — the current baseline is
**Cosmos 26**. API availability is Cosmos API versioning: "available since
Cosmos 26" corresponds to `@available(iOS 26, *)`. `CosmosTheme.version` is a
runtime design-language pin that lets an app keep an older look on a newer OS.
See [VERSIONING.md](VERSIONING.md) for the policy and
[CHANGELOG.md](CHANGELOG.md) for release history.

## Governance

- [ARCHITECTURE.md](ARCHITECTURE.md) — design goals and conventions
- [DECISIONS.md](DECISIONS.md) — architectural decisions
- [VERSIONING.md](VERSIONING.md) — versioning policy
- [ROADMAP.md](ROADMAP.md) — current and future work
- [CHANGELOG.md](CHANGELOG.md) — release history
- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution guidelines

## License

MIT © Rafael Escaleira

---

Built by [Rafael Escaleira](https://byescaleira.com) · [@byescaleira](https://x.com/bybyescaleira)

If something here helped you, let me know. If something is wrong, tell me louder.