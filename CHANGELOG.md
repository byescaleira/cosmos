# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `CosmosBase` target with shared configuration object `CosmosConfiguration`.
- Base contracts: `CosmosAccessibilityConfiguration`, `CosmosLocalizationConfiguration`, `CosmosLogConfiguration`, `CosmosErrorConfiguration`, `CosmosLoadingConfiguration`, `CosmosEnableConfiguration`.
- SwiftUI `@Entry` environment values: `.cosmosConfiguration(_:)` and `.cosmosTheme(_:)` view modifiers.
- Semantic theme token layer: `CosmosColorTokens`, `CosmosTypographyTokens`, `CosmosSpacingTokens`, `CosmosRadiusTokens`.
- Unit tests for all base contracts and theme tokens using Swift Testing.
- `CosmosScreen` target with `CosmosComponent`, `CosmosScreenRenderer`, `CosmosActionRegistry`, and `CosmosScreenLoader` for data-driven screen assembly.
- Custom `Codable` conformance for `CosmosComponent` with readable keyed JSON envelopes and snake_case keys.
- `CosmosUITests` target with ViewInspector structural tests and SnapshotTesting visual regression tests on iOS.
- Snapshot baselines for `CosmosButton`, `CosmosText`, and `CosmosScreenRenderer`.
- Fluent value-copy mutation helpers on `CosmosConfiguration` and `CosmosTheme`.
- `CosmosAccessibilityHelpers.swift` with conditional accessibility label/hint modifiers.
- Project governance files: `README.md`, `ARCHITECTURE.md`, `ROADMAP.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `DECISIONS.md`, `LICENSE`.

### Changed
- Replaced premature atoms/molecules/organisms scaffolding with foundation-first approach.
- Refactored `CosmosTheme` to carry only visual tokens and selectors; behavior moved to `CosmosConfiguration`.
- Refactored existing atoms (`CosmosButton`, `CosmosText`, `CosmosIcon`, `CosmosDivider`) to read both `cosmosConfiguration` and `cosmosTheme` from the environment.
- Reduced atom initializers to content-only: `CosmosButton(_:action:)`, `CosmosButton(action:label:)`, `CosmosText(_:)`, `CosmosIcon(_:)`, `CosmosDivider()`.
- Flattened atom files into `Sources/Cosmos/Atoms/`.
- Re-implemented focused modifiers as `ViewModifier`s that re-inject a mutated `CosmosConfiguration` via `.environment(_:_:)`.
- Removed hand-written `EnvironmentKey` plumbing in favor of `@Entry`.
- Removed local state/config parameters from atoms in favor of environment modifiers:
  - `.cosmosEnabled(_:)`, `.cosmosVisible(_:)`, `.cosmosReadOnly(_:)`, `.cosmosLoading(_:)`
  - `.cosmosAccessibilityLabel(_:)`, `.cosmosAccessibilityHint(_:)`, `.cosmosAccessibilityHidden(_:)`, `.cosmosAccessibilitySortPriority(_:)`

### Removed
- Legacy `CosmosStyles`, `CosmosModifiers`, and incomplete component files.
- Empty `Sources/Cosmos/Resources` folder and `.process("Resources")` build configuration.

### Fixed
- Resolved iOS simulator codesign failure caused by empty resource bundle.
- Resolved recursive opaque-type inference error in `CosmosScreenRenderer` by wrapping recursive branches in `AnyView`.
- Resolved ViewInspector navigation through custom atom views by unwrapping `CosmosText` and `CosmosButton` before inspecting inner SwiftUI primitives.
- Wired `CosmosLocalizationConfiguration` into `CosmosText` so keys resolve through the configured bundle/locale/table.
- Prevented `CosmosButton` from applying an empty `.accessibilityLabel` when no override is configured, preserving VoiceOver fallback to visible text.
- Excluded snapshot PNG baselines from the `CosmosUITests` target to silence SwiftPM unhandled-resource warnings.
- Decoupled `CosmosScreen` models from the `Cosmos` target; they now depend only on `CosmosBase`.
- Added `JSONEncoder.cosmos`, `encode(screen:)`, and `jsonString(for:)` to `CosmosScreenLoader` for symmetric JSON round-trips.
- Added a bundled `.strings` catalog (`en` and `pt-BR`) to `CosmosBase` and exposed `CosmosResources.bundle` for public access.
- Implemented locale-aware string resolution in `CosmosLocalizationConfiguration`, selecting language-specific `.lproj` bundles when available.
- Added DocC documentation catalogs for `CosmosBase` and `CosmosScreen` with overviews and articles.
- Added `CosmosRedactionConfiguration` and `.cosmosRedacted(_:)` modifier for placeholder redaction.
- Added `CosmosControlSize` selector and `.cosmosControlSize(_:)` theme modifier, mapped to SwiftUI `ControlSize` on supported platforms.
- Added `CosmosDividerThickness` to `CosmosTheme` and `.cosmosDividerThickness(_:)` modifier.
- Hardened `CosmosText` with `lineLimit`, `multilineTextAlignment`, `truncationMode`, and a `verbatim` initializer.
- Hardened `CosmosButton` with `controlSize` support and redaction.
- Hardened `CosmosIcon` with `resizable`, `aspectRatio`, `contentMode`, and `renderingMode` options.
- Hardened `CosmosDivider` with a configurable thickness token and redaction.
- Added ViewInspector tests for `CosmosIcon` and `CosmosDivider`; expanded `CosmosText` and `CosmosButton` coverage.
- Added `CosmosImage` atom with support for resource bundles, SF Symbols, and remote URLs (`URL` and `String`), plus placeholder shapes and automatic redaction on loading.
- Added `CosmosLabel` atom pairing an SF Symbol with localized text.
- Added `CosmosSpacer` atom with optional minimum length.
- Extended `CosmosComponent`, `CosmosScreenRenderer`, and screen JSON models to support image, label, spacer, link, textField, toggle, progress, slider, picker, and badge components.
- Added `CosmosLink` atom wrapping SwiftUI `Link` with URL and URL-string initializers, accent color, and underline control.
- Added `CosmosTextField` atom with `TextField`/`SecureField`, prompt localization, disabled state, control size, and redaction.
- Added `CosmosToggle` atom with `Toggle`, optional icon+text label, disabled state, control size, and redaction.
- Added `CosmosProgress` atom supporting indeterminate spinner and determinate linear progress.
- Added `CosmosSlider` atom with configurable bounds, step, disabled state, and redaction.
- Added `CosmosPicker` atom as a segmented control with `String` selection and labeled options.
- Added `CosmosBadge` atom with text pill and dot variants (primary, secondary, success, warning, error).
- Added `CosmosStepper` atom with `Int` and `Double` bindings, bounds, step, and label.
- Added `CosmosDatePicker` atom with `Date` binding and cross-platform displayed-components model.
- Added `CosmosMenu` atom wrapping SwiftUI `Menu` with custom label/content and a JSON-serializable action menu variant.
- Added `CosmosSection`, `CosmosList`, and `CosmosTabView` container atoms with environment-driven visibility and selection.
- Added `CosmosListStyle`, `CosmosTabRole`, and `CosmosTabAdaptiveStrategy` theme tokens.
- Implemented adaptive `CosmosTabView` that switches between `TabView` (compact) and `NavigationSplitView` sidebar (regular) via `horizontalSizeClass`.
- Wired `CosmosSection`, `CosmosList`, and `CosmosTabView` into `CosmosScreen` JSON models and renderer.

### Changed
- `CosmosLocalizationConfiguration` now defaults to `CosmosResources.bundle` instead of `Bundle.main`, letting the library ship baseline translations.
- `CosmosTheme` now includes `dividerThickness` and `controlSize` selectors.

### Fixed
- Removed accidental leading colon from `Sources/CosmosScreen/Loader/CosmosScreenLoader.swift` that broke compilation.
- Normalized locale identifier lookup to match SwiftPM's lowercased `.lproj` directory names (e.g. `pt-br.lproj`).

## [0.0.1] - 2026-06-21

### Added
- Initial SPM package scaffolding for Apple v26 platforms.
- Governance and documentation skeleton.

