# Cosmos

> A multi-platform SwiftUI design system for Apple's v26 platforms.

## What is Cosmos?

Cosmos is a clean-room design system built as an SPM package. It starts from two shared, mutable-by-replacement value types distributed through the SwiftUI environment:

- `CosmosConfiguration` carries cross-cutting behavior:
  - **Accessibility** — labels, hints, traits, hidden state
  - **Localization** — locale-aware string resolution
  - **Log** — structured logging events
  - **Error** — centralized error reporting
  - **Loading** — loading state with delay and minimum display time
  - **Enable** — enabled / visible / read-only flags
- `CosmosTheme` carries visual tokens: colors, typography, spacing, radii, and component style selectors.

## Structure

```
Cosmos/
├── CosmosBase/          # Shared configuration and theme tokens
├── Cosmos/              # Design system components (atoms, molecules, organisms)
└── CosmosScreen/        # Data-driven screen assembly from serializable models
```

## Platform Support

- iOS 26
- macOS 26
- tvOS 26
- watchOS 26
- Mac Catalyst 26
- visionOS 26

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/byescaleira/cosmos.git", from: "0.1.0")
]
```

## Usage

```swift
import Cosmos
import CosmosBase

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
import CosmosScreen

let screen = CosmosScreen(
    id: "welcome",
    components: [
        .text(.init(contentKey: "Welcome")),
        .spacer,
        .button(.init(titleKey: "Continue", action: .init(id: "continue")))
    ]
)

CosmosScreenRenderer(screen: screen, registry: .init(
    handlers: ["continue": { print("tapped") }]
))
```

### From JSON

```swift
import CosmosScreen

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
| Divider | `{ "divider": {} }` |
| Spacer | `{ "spacer": {} }` |
| VStack | `{ "v_stack": { "components": [...], "spacing": "medium", "alignment": "center" } }` |
| HStack | `{ "h_stack": { "components": [...], "spacing": "medium", "alignment": "center" } }` |
| ZStack | `{ "z_stack": { "components": [...], "spacing": "medium", "alignment": "center" } }` |

The default `JSONDecoder` uses `convertFromSnakeCase`, matching the Swift-style keys shown above.

## Development

```bash
swift build
swift test
```

The `CosmosUITests` target combines **ViewInspector** structural tests with **SnapshotTesting** visual regression on iOS. Snapshot baselines live in `Tests/CosmosUITests/Snapshot/__Snapshots__/`. Run iOS simulator tests to record or assert against them.

## License

MIT © Rafael Escaleira

---

Built by [Rafael Escaleira](https://byescaleira.com) · [@byescaleira](https://x.com/byescaleira)

If something here helped you, let me know. If something is wrong, tell me louder.
