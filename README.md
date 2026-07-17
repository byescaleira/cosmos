# Cosmos

> A single-target SwiftUI design system for iOS, macOS, and tvOS 27.

## What is Cosmos?

Cosmos is a clean-room SwiftUI design system distributed as an SPM package. It is intentionally small: one module, one import, and a single source of truth for behavior and appearance.

Two shared, mutable-by-replacement value types flow through the SwiftUI environment:

- `CosmosConfiguration` carries cross-cutting behavior:
  - **Accessibility** — labels, hints, traits, hidden state
  - **Localization** — locale-aware string resolution
  - **Log** — structured logging events
  - **Error** — centralized error reporting
  - **Loading** — loading state
  - **Enable** — enabled / visible / read-only flags
- `CosmosTheme` carries visual tokens: colors, typography, spacing, radii, and component style selectors.

## Structure

```
Sources/Cosmos/
├── Base/          # Configuration, theme tokens, environment values
├── Atoms/         # Button, Text, Icon, Image, TextField, Toggle, etc.
├── Molecules/     # InputRow, ListRow, FormRow, Card, AlertBanner, etc.
└── Screen/        # Data-driven screen assembly from serializable models
```

Everything is exported from the single `Cosmos` module.

## Platform Support

- iOS 27
- macOS 27
- tvOS 27

Cosmos is SwiftUI-native and contains no explicit UIKit references.

## Installation

Add Cosmos to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/byescaleira/cosmos.git", from: "0.1.0")
]
```

Then add `Cosmos` to your target dependencies.

## Usage

```swift
import Cosmos
import SwiftUI

struct MyView: View {
    @State private var configuration = CosmosConfiguration.default
    @State private var theme = CosmosTheme.default

    var body: some View {
        VStack {
            CosmosText("Hello, Cosmos")
            CosmosButton("Continue") { }
            CosmosButton(action: { }) {
                Label("Delete", systemImage: "trash")
            }
            .cosmosEnabled(false)
            CosmosIcon("checkmark")
            CosmosDivider()
        }
        .cosmosConfiguration(configuration)
        .cosmosTheme(theme)
    }
}
```

Override state and accessibility per component or subtree:

```swift
CosmosButton("Save") { }
    .cosmosLoading(true)
    .cosmosAccessibilityLabel("Save changes")
```

## Data-driven screens

`CosmosScreen` renders a serializable model into the same atoms. The model is `Codable`, so a screen can come from Swift code, a local JSON file, or an API response.

### From Swift

```swift
import Cosmos

let screen = CosmosScreen(
    id: "welcome",
    components: [
        .text(.init(contentKey: "welcome.headline")),
        .spacer,
        .button(.init(titleKey: "welcome.continue", action: .init(id: "continue")))
    ]
)

CosmosScreenRenderer(screen: screen, registry: .init(
    handlers: ["continue": { print("tapped") }]
))
```

### From JSON

```swift
import Cosmos

let json = """
{
    "id": "welcome",
    "title_key": "welcome.title",
    "layout": {
        "root": "vStack",
        "spacing": "medium",
        "padding": "large",
        "alignment": "center"
    },
    "components": [
        { "text": { "content_key": "welcome.headline" } },
        { "text": { "content_key": "welcome.body" } },
        { "spacer": {} },
        {
            "button": {
                "title_key": "welcome.continue",
                "action": { "id": "continue" }
            }
        }
    ]
}
"""

let screen = try CosmosScreenLoader().screen(from: json)
CosmosScreenRenderer(screen: screen, registry: .init(
    handlers: ["continue": { print("tapped") }]
))
```

JSON components are keyed by case name:

| Component | JSON shape |
|---|---|
| Text | `{ "text": { "content_key": "..." } }` |
| Button | `{ "button": { "title_key": "...", "action": { "id": "..." } } }` |
| Icon | `{ "icon": { "system_name": "..." } }` |
| Image | `{ "image": { "source": { "system": { "name": "..." } } } }` |
| Divider | `{ "divider": {} }` |
| Spacer | `{ "spacer": {} }` |
| VStack | `{ "v_stack": { "components": [...], "spacing": "medium", "alignment": "center" } }` |
| HStack | `{ "h_stack": { "components": [...], "spacing": "medium", "alignment": "center" } }` |
| ZStack | `{ "z_stack": { "components": [...], "spacing": "medium", "alignment": "center" } }` |
| List Row | `{ "list_row": { "title_key": "..." } }` |
| Empty State | `{ "empty_state": { "title_key": "..." } }` |

The default `JSONDecoder` uses `convertFromSnakeCase`, matching the Swift-style keys shown above.

## Development

```bash
swift build
swift test
```

Tests run with Swift Testing. Cosmos has no third-party dependencies. Visual validation is done through Xcode Previews and the planned `CosmosPreview` catalog app.

## Governance

- [ARCHITECTURE.md](ARCHITECTURE.md) — design goals and conventions
- [DECISIONS.md](DECISIONS.md) — architectural decisions
- [ROADMAP.md](ROADMAP.md) — current and future work
- [CHANGELOG.md](CHANGELOG.md) — release history
- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution guidelines

## License

MIT © Rafael Escaleira

---

Built by [Rafael Escaleira](https://byescaleira.com) · [@byescaleira](https://x.com/bybyescaleira)

If something here helped you, let me know. If something is wrong, tell me louder.
