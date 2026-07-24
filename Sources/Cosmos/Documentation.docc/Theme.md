# Theme

The visual half of Cosmos: semantic tokens injected through ``CosmosTheme`` via
`@Environment(\.cosmosTheme)`. Atoms read visual defaults from here and override per-instance
via `.cosmos*` modifiers (which re-inject a mutated copy).

For **runtime-mutable** theming (live theme switching), wrap a `CosmosTheme` in
``CosmosThemeObservable`` (`@Observable @MainActor`) and inject the observable.

## Topics

### Tokens
- ``CosmosColorTokens``
- ``CosmosTypographyTokens``
- ``CosmosTextStyle``
- ``CosmosPadding``
- ``CosmosControlSize``
- ``CosmosMotionTokens``

### Builders
- ``CosmosTheme/withColors(_:)``
- ``CosmosTheme/withTypography(_:)``
- ``CosmosTheme/withTextStyle(_:)``
- ``CosmosTheme/withButtonStyle(_:)``
- ``CosmosTheme/withToastMaxWidth(_:)``

### Runtime theming
- ``CosmosThemeObservable``