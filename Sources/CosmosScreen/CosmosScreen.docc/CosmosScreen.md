# ``CosmosScreen``

@Metadata {
    @TechnologyRoot
}

Build SwiftUI screens from data.

## Overview

`CosmosScreen` turns a JSON payload into a rendered SwiftUI view tree. It is
designed for remote configuration, A/B tests, and onboarding flows where the
layout needs to change without an app update.

The module contains:

- **Models** – ``CosmosScreen``, ``CosmosComponent``, ``CosmosLayout``, and
  small value types for text, button, icon, divider, spacer, and stack atoms.
- **Renderer** – ``CosmosScreenRenderer`` walks the model and produces Cosmos
  atoms and SwiftUI containers.
- **Actions** – ``CosmosActionRegistry`` maps button taps to named actions so
  the screen stays decoupled from business logic.
- **Loader** – ``CosmosScreenLoader`` decodes JSON using a snake-case strategy
  and readable keyed envelopes.

## Topics

### Models

- ``CosmosScreen``
- ``CosmosComponent``
- ``CosmosLayout``
- ``CosmosStackLayout``
- ``CosmosAction``

### Rendering and actions

- ``CosmosScreenRenderer``
- ``CosmosActionRegistry``

### JSON loading

- ``CosmosScreenLoader``
- ``CosmosScreenLoaderError``
- ``JSONDecoder/cosmos``
- ``JSONEncoder/cosmos``

### JSON guide

- <doc:WritingScreenJSON>
