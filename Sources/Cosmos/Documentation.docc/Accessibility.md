# Accessibility

Every atom integrates accessibility (label/value/hint/identifier/traits/customContent + the env
gates `reduceMotion`/`reduceTransparency`/`colorSchemeContrast`/`differentiateWithoutColor`/
`showBorders` + Dynamic Type reflow). Gates are read config-aware through ``CosmosAccessibilityPolicy``,
mirroring ``CosmosMotionPolicy``.

## Topics

### Configuration & policy
- ``CosmosAccessibilityConfiguration``
- ``CosmosAccessibilityPolicy``

### Preview variants
- ``CosmosPreviewVariant``
- ``View/cosmosPreviewVariant(_:)``
- ``View/cosmosPreviewEnv(_:colorScheme:dynamicTypeSize:locale:layoutDirection:horizontalSizeClass:verticalSizeClass:legibilityWeight:reduceMotion:reduceTransparency:differentiateWithoutColor:showButtonShapes:colorSchemeContrast:)``