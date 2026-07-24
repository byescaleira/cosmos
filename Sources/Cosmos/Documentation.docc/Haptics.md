# Haptics

Haptics use SwiftUI `.sensoryFeedback` (iOS 17+), gated by ``CosmosHapticsConfiguration`` +
`accessibilityReduceMotion` through ``CosmosHapticsPolicy`` (config-aware, not the bare env
value). No `UIImpactFeedbackGenerator`. No-op where there is no hardware.

## Topics

- ``CosmosHapticsConfiguration``
- ``CosmosHapticsPolicy``
- ``CosmosHapticsFeedback``
- ``CosmosHapticsWeight``
- ``View/cosmosHaptic(_:trigger:)``