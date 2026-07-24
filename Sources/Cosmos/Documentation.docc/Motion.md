# Motion

Motion is split like the rest: behavior/policy in `cosmosConfiguration.motion`
(``CosmosMotionConfiguration`` — the 9th cross-cutting contract); visual tokens in
`cosmosTheme.motion` (``CosmosMotionTokens`` — springs, durations, transition presets).

Atoms never write raw `Animation.spring(...)`/`.transition(.move...)`; they call
`.cosmosAnimation(.press, value: x)` / `.cosmosTransition(.sheet)`, which resolve tokens through
``CosmosMotionTokens/animation(for:reduceMotion:policy:)`` (the single source of truth) and gate
reduce-motion through ``CosmosMotionPolicy`` (config-aware, not the bare env value).

## Topics

### Visual tokens
- ``CosmosMotionTokens``
- ``CosmosSpring``
- ``CosmosSpringStyle``
- ``CosmosDuration``
- ``CosmosTransition``
- ``CosmosContentTransitionPreset``
- ``CosmosReduceMotionPolicy``

### Modifiers
- ``View/cosmosAnimation(_:value:)``
- ``View/cosmosTransition(_:)``
- ``View/cosmosContentTransition(_:)``
- ``View/cosmosStagger(_:index:value:step:maxSteps:)``
- ``cosmosWithAnimation(_:configuration:theme:reduceMotion:completionCriteria:body:completion:)``