# ``Cosmos``

A SwiftUI design-system SwiftPM library for iOS, macOS, tvOS, watchOS, and visionOS —
all at the OS 26 / Liquid Glass baseline. One target, no third-party dependencies.

Cosmos is organized around **nine cross-cutting contracts** that flow through the SwiftUI
environment via `@Entry` rather than per-component structs: every atom reads its relevant
subset and overrides per-instance via `.cosmos*` modifiers (which read the environment,
mutate a copy via a `with*` builder, and re-inject). State and theme are **global**, not
per-component.

- ``CosmosTheme`` — visual tokens (colors, typography, padding, control size, motion, version).
- ``CosmosConfiguration`` — behavior/state (enable, loading, accessibility, haptics, motion,
  tracking, localization, log, error).
- ``cosmosTrackingId`` — analytics id fallback.

## Topics

### Cross-cutting contracts
- <doc:Theme>
- <doc:Configuration>
- <doc:Motion>
- <doc:Haptics>
- <doc:Accessibility>
- <doc:Localization>
- <doc:Tracking>

### Overriding per subtree
- ``View/cosmosTheme(_:)``
- ``View/cosmosConfiguration(_:)``
- ``View/cosmosMotion(_:)``
- ``View/cosmosMotionTokens(_:)``
- ``View/cosmosFont(_:weight:design:)``
- ``View/cosmosTint(_:)``
- ``View/cosmosForegroundStyle(_:)``

### Coordinated motion
- ``cosmosWithAnimation(_:configuration:theme:reduceMotion:completionCriteria:body:completion:)``