# Configuration

The behavior/state half of Cosmos: injected through ``CosmosConfiguration`` via
`@Environment(\.cosmosConfiguration)`. Nine cross-cutting contracts compose into it.

## Topics

### Contracts
- ``CosmosEnableConfiguration``
- ``CosmosLoadingConfiguration``
- ``CosmosAccessibilityConfiguration``
- ``CosmosHapticsConfiguration``
- ``CosmosMotionConfiguration``
- ``CosmosTrackingConfiguration``
- ``CosmosLocalizationConfiguration``
- ``CosmosLogConfiguration``
- ``CosmosErrorConfiguration``

### Policies (config-aware gates, not bare env values)
- ``CosmosMotionPolicy``
- ``CosmosHapticsPolicy``
- ``CosmosAccessibilityPolicy``