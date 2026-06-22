# State Modifiers

Cosmos components read their interactive state from the SwiftUI environment.
Instead of passing `isEnabled`, `isLoading`, or `accessibilityLabel` through
initializers, you apply focused modifiers to any ancestor view.

## Behavior modifiers

- ``SwiftUI/View/cosmosEnabled(_:)`` – enables or disables interactive atoms.
- ``SwiftUI/View/cosmosVisible(_:)`` – controls visibility.
- ``SwiftUI/View/cosmosReadOnly(_:)`` – marks content as non-editable.
- ``SwiftUI/View/cosmosLoading(_:)`` – replaces buttons with a progress view and redacts images during loading.
- ``SwiftUI/View/cosmosRedacted(_:)`` – renders atoms with SwiftUI placeholder redaction.

## Accessibility modifiers

- ``SwiftUI/View/cosmosAccessibilityLabel(_:)``
- ``SwiftUI/View/cosmosAccessibilityHint(_:)``
- ``SwiftUI/View/cosmosAccessibilityHidden(_:)``
- ``SwiftUI/View/cosmosAccessibilitySortPriority(_:)``

All modifiers return a copy of `CosmosConfiguration` with the changed field,
then re-inject it into the environment. This keeps atoms content-only and makes
state easy to override at any level of the view tree.

## Example

```swift
CosmosButton("Continue") { }
    .cosmosLoading(isLoading)
    .cosmosEnabled(!isLoading)
    .cosmosAccessibilityLabel("Continue to dashboard")

CosmosImage(urlString: "https://example.com/avatar.jpg")
    .cosmosLoading(isLoading)
    .cosmosRedacted(isLoading)
```
