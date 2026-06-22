# ``CosmosBase``

@Metadata {
    @TechnologyRoot
}

The foundation layer of the Cosmos design system.

## Overview

`CosmosBase` separates *behavior* from *appearance*. It gives every Cosmos
component a consistent way to read accessibility, localization, loading,
enablement, and theme values from the SwiftUI environment.

The module is intentionally small and dependency-free. It defines:

- **Configuration** – mutable, value-copy state contracts that describe how a
  component should behave (`CosmosConfiguration`).
- **Theme** – immutable visual tokens that describe how a component should look
  (`CosmosTheme`).
- **Environment integration** – SwiftUI `@Entry` values and focused modifiers
  that replace ad-hoc `EnvironmentKey` plumbing.

## Topics

### Configuration

- ``CosmosConfiguration``
- ``CosmosAccessibilityConfiguration``
- ``CosmosLocalizationConfiguration``
- ``CosmosLogConfiguration``
- ``CosmosErrorConfiguration``
- ``CosmosLoadingConfiguration``
- ``CosmosEnableConfiguration``
- ``CosmosRedactionConfiguration``

### Theme

- ``CosmosTheme``
- ``CosmosColorTokens``
- ``CosmosTypographyTokens``
- ``CosmosSpacingTokens``
- ``CosmosRadiusTokens``
- ``CosmosTextStyle``
- ``CosmosIconScale``
- ``CosmosButtonStyle``
- ``CosmosDividerStyle``
- ``CosmosPadding``
- ``CosmosRadius``
- ``CosmosControlSize``

### Environment

- ``SwiftUI/EnvironmentValues/cosmosConfiguration``
- ``SwiftUI/EnvironmentValues/cosmosTheme``
- <doc:StateModifiers>
- <doc:ThemeModifiers>

### Localization

- <doc:Localization>
