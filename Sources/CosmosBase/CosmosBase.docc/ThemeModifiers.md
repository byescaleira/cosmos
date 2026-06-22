# Theme Modifiers

Theme modifiers let you override visual tokens for a subtree without rebuilding
atom initializers. They work the same way as state modifiers: they read the
current `CosmosTheme` from the environment, create a mutated copy, and re-inject
it.

## Available modifiers

- ``SwiftUI/View/cosmosTextStyle(_:)`` – override ``CosmosTextStyle``.
- ``SwiftUI/View/cosmosButtonStyle(_:)`` – override ``CosmosButtonStyle``.
- ``SwiftUI/View/cosmosIconScale(_:)`` – override ``CosmosIconScale``.
- ``SwiftUI/View/cosmosDividerStyle(_:)`` – override ``CosmosDividerStyle``.
- ``SwiftUI/View/cosmosDividerThickness(_:)`` – override ``CosmosPadding`` for divider thickness.
- ``SwiftUI/View/cosmosPadding(_:)`` – override ``CosmosPadding``.
- ``SwiftUI/View/cosmosControlSize(_:)`` – override ``CosmosControlSize`` for buttons and other platform-native controls.

## Example

```swift
VStack {
    CosmosText("Headline")
        .cosmosTextStyle(.title)

    CosmosButton("Submit") { }
        .cosmosButtonStyle(.primary)
        .cosmosControlSize(.large)
}
.cosmosPadding(.large)
```
