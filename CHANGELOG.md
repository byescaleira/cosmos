# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Wave D atoms** — the text-input + value-control group: `CosmosTextField` (`TextField` wrapper; visual variant from `textFieldStyle` — `.automatic`/`.plain`/`.bordered`/`.cosmos`; `.bordered` (`BorderedTextFieldStyle` + `.textInputBorderShape`) is `@available(anyAppleOS 27.0)` — the next OS above the Cosmos 26 floor, gated to OS 27 with an `.automatic` fallback; `.cosmos` chrome composed in the atom body where `@FocusState` is visible since `TextFieldStyle._body` is an opaque SPI whose `_Label` has `Body == Never`; animated focus border via one `.cosmosAnimation(.focus, value:)` chokepoint; `.submitLabel(.done)` on iOS/tvOS; additive `.impact(.light)` haptic + tracking on `.onSubmit`), `CosmosSecureField` (`SecureField` wrapper; no style selector — SecureField has no conformable style protocol; focus motion via `.cosmosAnimation(.focus, value:)`), and `CosmosTextEditor` (`#if !os(tvOS) && !os(watchOS)`-guarded `TextEditor` wrapper; forwards native built-ins only — `TextEditorStyleConfiguration` is an empty opaque struct so no custom chrome; `.roundedBorder` (`RoundedBorderTextEditorStyle`) is visionOS-only, falling back to `.automatic` elsewhere). Plus `CosmosSlider` (`#if !os(tvOS)`-guarded `Slider` wrapper; `V` fixed to `Double`; no SliderStyle — `.tint` is the only track customization; `.cosmosAnimation(.valueChange, value: steppedValue)` + `.cosmosHaptic(.selection, trigger: steppedValue)` quantized via `CosmosSliderMath.stepped` so feedback fires on step-snap, never per drag pixel; the iOS 26 ticks/`neutralValue`/`SliderTickBuilder` cluster deliberately deferred), `CosmosStepper` (`Stepper` wrapper with a uniform API on all 5 platforms; on tvOS — where `Stepper` is unavailable — renders a `CosmosButton` +/- pair fallback sharing the same increment/decrement closures; value inits synthesize closures capturing only init params (never `self`) calling static `step` → `CosmosStepperMath.advance` with bounds clamping; label-first non-deprecated inits only; no double haptic — native Stepper fires its own on the native branch, tvOS relies on `CosmosButton`'s press haptic), the pure render-free math enums `CosmosSliderMath` and `CosmosStepperMath`, and the platform-agnostic availability table `CosmosTextEditorAvailability` (full style × platform matrix, testable on any host). Theme selectors `textFieldStyle`/`textEditorStyle` (defaults `.automatic`) with fluent `with*` builders and `.cosmosTextFieldStyle(_:)`/`.cosmosTextEditorStyle(_:)` modifiers. Hardened after a high-effort code review: the `CosmosTextField` submit haptic now routes through `.cosmosHaptic(_:trigger:)` (real `.sensoryFeedback`, gated by `CosmosHapticsPolicy`) and only fires when a submit handler is installed; `CosmosSlider` defaults to **continuous** (`step` defaults to `0`, matching native `Slider(value:in:)`) with the per-step `.selection` haptic nil-gated off for continuous sliders, and tracking now keys off the quantized `steppedValue` (no `.ulpOfOne` float-compare desync with the haptic); `CosmosStepper` no longer double-fires `onEditingChanged` (the native `Stepper` owns session bracketing; the tvOS fallback brackets each press itself), its `CosmosStepperMath.advance` clamps the stride to the in-bounds distance before `advanced(by:)` so `Int` near bounds no longer traps on overflow, and its tvOS fallback no longer marks the HStack `.isButton` (button-containing-buttons tree); `.submitLabel(.done)` is now applied unguarded on `CosmosTextField`/`CosmosSecureField` (it is available on all 5 platforms incl. visionOS).
- **Wave C atoms** — three style-protocol atoms with a per-platform availability surface: `CosmosGroupBox` (`GroupBoxStyle`-conforming; `.cosmos` custom chrome + `.automatic` native; plain fallback on tvOS/watchOS where `GroupBox` is unavailable), `CosmosMenu` (`MenuStyle`-based `.automatic`/`.button`; `CosmosButton` fallback on watchOS where `Menu` is unavailable; optional primary action with `.selection`/`.impact(.rigid)` haptic + `press` motion), and `CosmosDatePicker` (per-style `#if os()` resolution with `.automatic` fallback where a requested style is unavailable; type-level `#if !os(tvOS)` guard since `DatePicker` is unavailable on tvOS; `.selection` haptic debounced on `selection.wrappedValue`; `.cosmosContentTransition(.numeric)` for compact/field text reflow — no direct `valueChange` animation on the picker, mirroring the Picker rule). Plus the shared, render-free `CosmosPlatform` enum (`ios`/`macos`/`watchos`/`visionos`/`tvos` with compile-time `.current`) and the pure availability tables `CosmosGroupBoxAvailability`, `CosmosMenuAvailability`, `CosmosMenuAccessibility`, and `CosmosDatePickerAvailability` (full style × platform matrix, testable on any host). Theme selectors `groupBoxStyle`/`menuStyle`/`datePickerStyle` (defaults `.automatic`) with fluent `with*` builders and `.cosmosGroupBoxStyle(_:)`/`.cosmosMenuStyle(_:)`/`.cosmosDatePickerStyle(_:)` modifiers.
- **Wave B atoms** — `CosmosDivider` (decorative separator wrapping the native `Divider`, hidden from VoiceOver, no tracking/motion), `CosmosIcon` (generic `Image` wrapper with token-driven foreground style + typography, caller-driven symbol-effect surface, nearest-ancestor color override), and `CosmosLink` (generic `Link` wrapper with token-driven accent + typography, `.isLink` trait, `.openURL` intercept). Plus the centralized `.cosmosOpenURL(inApp:)` modifier and the pure, render-free `CosmosOpenURLRouting.resolve(url:inApp:)` → `CosmosOpenURLResolution` routing function (testable without rendering). All wrap-view atoms (no style protocol); all platform-agnostic at the Cosmos 26 baseline (no `#if os()` in the atoms); motion kind `none`; no haptics.

### Changed
- Reorganized the SPM into a single `Cosmos` target; merged `Sources/CosmosBase` into `Sources/Cosmos/Base` and `Sources/CosmosScreen` into `Sources/Cosmos/Screen`; removed `@_exported` re-exports.
- Made the package explicitly UIKit-free: removed `#if canImport(UIKit)` from `CosmosList.swift` and replaced `Color(uiColor:)` with `Color(.systemBackground)` in `CosmosColorTokens.swift`.
- Restored the full multiplatform matrix: iOS / macOS / tvOS / watchOS / visionOS, all at `.v26` (Swift 6.4, language mode v6). An earlier draft erroneously listed only iOS/macOS/tvOS 27 and "dropped watchOS+visionOS" — the package targets all 5 platforms at `.v26` per `Package.swift` + `CLAUDE.md`.
- Migrated CI from `xcodebuild docbuild` with an iOS Simulator destination to pure `swift build` + `swift test`.
- Updated documentation to reflect the single-target structure, UIKit-free scope, and the new platform matrix.
- Refactored `CosmosConditionModifier` so a single generic type handles both Boolean and optional-value conditions; the stored closures no longer take a `Content` parameter, and the `View` extension captures `self` to avoid `_ViewModifier_Content` conversion errors.

### Added
- **Motion subsystem** — `CosmosMotionConfiguration` (the 9th cross-cutting behavior contract: `isEnabled`/`respectReduceMotion`/`reduceMotionPolicy`/`respectReduceTransparency`/`stagger`/`handler`) aggregated into `CosmosConfiguration`; `CosmosMotionTokens` (visual: `CosmosSpring` presets, `CosmosDuration` scale, `CosmosTransition`/`CosmosContentTransitionPreset` presets, and the single `animation(for:reduceMotion:policy:)` resolver) added to `CosmosTheme`; `CosmosMotionPolicy` gates reduce-motion config-aware. Modifiers: `.cosmosAnimation(_:value:)`, `.cosmosTransition(_:)`, `.cosmosContentTransition(_:)`, `.cosmosStagger(…)` (gated chokepoints), plus behavior/visual overrides `.cosmosMotion(_:)`, `.cosmosReduceMotion(_:)`, `.cosmosMotionTokens(_:)`, `.cosmosSpringStyle(_:)`. Integrated into `CosmosButton`/`CosmosButtonChrome`/`CosmosText`/`CosmosCard`. `BlurReplaceTransition` applied via the generic `.transition<T>(_:)` overload (it is not `AnyTransition`-composable).
- **Preview + mock-data infrastructure** — `CosmosPreviewRNG` (deterministic SplitMix64 `RandomNumberGenerator & Sendable`); `CosmosPreview` namespace (`defaultSeed`/`locales`/`rtlLocale`/`accessibilitySizes`) + `CosmosPreviewVariant` + `CosmosPreviewContainer`; `CosmosPreviewModifier` (`PreviewModifier` shared-context path, iOS 18+); `.cosmosPreviewEnv(…)` / `.cosmosPreviewVariant(_:)` modifiers (inject reduce-motion/contrast/etc. via the stable underscore SPI); `CosmosMock` deterministic generators (string/number/decimal/currency/percentage/date/uuid/color/email/name/phone/url/address/lorem) + `CosmosMockWordlists`, with `Mutex<CosmosPreviewRNG>` shared state. No third-party deps, no UIKit, no `#if DEBUG`.
- Custom font support: bundled DM Sans, Space Grotesk, and JetBrains Mono under `Sources/Cosmos/Resources/Fonts/`.
- `CosmosFont` enum with cases for each bundled family and `registerAllFonts()` that automatically registers every `.ttf` in the bundle via `CTFontManagerRegisterFontsForURL`.
- `CosmosTypographyTokens` preset statics `.dmSans`, `.spaceGrotesk`, and `.jetBrainsMono`, plus a custom-font initializer that sizes fonts relative to `CosmosTextStyle` (using `Font.custom(..., relativeTo:)`) so Dynamic Type scaling still works.
- `CosmosTextModifier` (`View.cosmosText(family:style:weight:)`) for applying a custom Cosmos font, semantic style, and weight directly to a `Text` view.

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
- Removed `CosmosRedactionConfiguration` and the `.cosmosRedacted(_:)` modifier; loading placeholders are now driven by `.cosmosLoading(_:)` and `CosmosLoadingConfiguration`.

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
- Added `CosmosControlSize` selector and `.cosmosControlSize(_:)` theme modifier, mapped to SwiftUI `ControlSize` on supported platforms.
- Added `CosmosDividerThickness` to `CosmosTheme` and `.cosmosDividerThickness(_:)` modifier.
- Hardened `CosmosText` with `lineLimit`, `multilineTextAlignment`, `truncationMode`, and a `verbatim` initializer.
- Hardened `CosmosButton` with `controlSize` support.
- Hardened `CosmosIcon` with `resizable`, `aspectRatio`, `contentMode`, and `renderingMode` options.
- Hardened `CosmosDivider` with a configurable thickness token.
- Added ViewInspector tests for `CosmosIcon` and `CosmosDivider`; expanded `CosmosText` and `CosmosButton` coverage.
- Added `CosmosImage` atom with support for resource bundles, SF Symbols, and remote URLs (`URL` and `String`), plus placeholder shapes and automatic loading placeholders.
- Added `CosmosLabel` atom pairing an SF Symbol with localized text.
- Added `CosmosSpacer` atom with optional minimum length.
- Extended `CosmosComponent`, `CosmosScreenRenderer`, and screen JSON models to support image, label, spacer, link, textField, toggle, progress, slider, picker, and badge components.
- Added `CosmosLink` atom wrapping SwiftUI `Link` with URL and URL-string initializers, accent color, and underline control.
- Added `CosmosTextField` atom with `TextField`/`SecureField`, prompt localization, disabled state, and control size.
- Added `CosmosToggle` atom with `Toggle`, optional icon+text label, disabled state, and control size.
- Added `CosmosProgress` atom supporting indeterminate spinner and determinate linear progress.
- Added `CosmosSlider` atom with configurable bounds, step, and disabled state.
- Added `CosmosPicker` atom as a segmented control with `String` selection and labeled options.
- Added `CosmosBadge` atom with text pill and dot variants (primary, secondary, success, warning, error).
- Added `CosmosStepper` atom with `Int` and `Double` bindings, bounds, step, and label.
- Added `CosmosDatePicker` atom with `Date` binding and cross-platform displayed-components model.
- Added `CosmosMenu` atom wrapping SwiftUI `Menu` with custom label/content and a JSON-serializable action menu variant.
- Added `CosmosSection`, `CosmosList`, and `CosmosTabView` container atoms with environment-driven visibility and selection.
- Added `CosmosListStyle`, `CosmosTabRole`, and `CosmosTabAdaptiveStrategy` theme tokens.
- Implemented adaptive `CosmosTabView` that switches between `TabView` (compact) and `NavigationSplitView` sidebar (regular) via `horizontalSizeClass`.
- Wired `CosmosSection`, `CosmosList`, and `CosmosTabView` into `CosmosScreen` JSON models and renderer.
- Added project-level Claude Code context: `.claude/CLAUDE.md`, `.claude/commands/byescaleira.md`, and `.claude/skills/cosmos/SKILL.md`.
- Added molecule module folder `Sources/Cosmos/Molecules/`.
- Added `CosmosInputRow` molecule (label + text field) with JSON model and renderer support.
- Added `CosmosListRow` molecule (icon + title + subtitle + trailing) with `.none`, `.badge`, `.chevron`, and `.text` trailing variants.
- Added `CosmosFormRow` molecule (label + control) with toggle, picker, stepper, slider, and value variants.
- Wired `CosmosInputRow`, `CosmosListRow`, and `CosmosFormRow` into `CosmosScreen` JSON models and renderer.
- Added renderer-local `@State` wrappers for interactive molecules (`RenderedCosmosInputRow`, `RenderedCosmosFormRow`) with optional action dispatch on value changes.
- Added ViewInspector tests for the first three molecules.
- Added `CosmosEmptyState` molecule (image + title + subtitle + button) for empty/error/onboarding placeholders.
- Added `CosmosButtonRow` molecule (full-width icon + text button) with primary and danger variants.
- Added `CosmosSearchBar` molecule (search icon + text field + clear button) with rounded surface background.
- Wired `CosmosEmptyState`, `CosmosButtonRow`, and `CosmosSearchBar` into `CosmosScreen` JSON models and renderer.
- Added `RenderedCosmosSearchBar` renderer wrapper with local `@State` and optional text-change / clear actions.
- Added ViewInspector tests for `CosmosEmptyState`, `CosmosButtonRow`, and `CosmosSearchBar`.

### Removed
- Removed `ViewInspector` and `swift-snapshot-testing` dependencies.
- Removed `CosmosUITests` target and all UI/snapshot tests. Visual validation now relies on Xcode Previews and the planned `CosmosPreview` catalog app.

### Added
- Added `CosmosStatusRow` molecule (icon/image + title/subtitle + badge) for notification and status rows.
- Added `CosmosCard` molecule (image + title + subtitle + badge + button) for content cards.
- Added `CosmosAlertBanner` molecule (icon + title + action button) with info/success/warning/error variants.
- Added `CosmosLoadingState` molecule (progress indicator + title + subtitle) for loading placeholders.
- Wired `CosmosStatusRow`, `CosmosCard`, `CosmosAlertBanner`, and `CosmosLoadingState` into `CosmosScreen` JSON models and renderer.
- Added ViewInspector tests and JSON round-trip tests for all four new molecules.

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

