---
tags: [research, ios26, liquid-glass, swiftui, apple-samples, design-system-comparison]
aliases: [Apple iOS 26 sample code patterns, Liquid Glass sample catalog, Landmarks sample patterns]
related: [[button-shapes-ios26-liquid-glass]], [[ios-27-swiftui-above-floor-apis]], [[cosmos-tabview]]
---

# Apple iOS 26 sample code — SwiftUI pattern catalog

Research catalog of Apple's official sample code projects that target or demonstrate **iOS 26 / Liquid Glass (WWDC25, 2025)**, with the exact SwiftUI APIs each demonstrates. Source of truth for what APIs Apple actually uses in its reference apps — informs Cosmos atom conventions. The root docs (`CLAUDE.md`, `DECISIONS.md`, `ARCHITECTURE.md`) win on conflict.

## Fetch caveats

`developer.apple.com` pages are JS-rendered; direct `WebFetch` returned only titles. Patterns were extracted from:
- The WWDC25 session 323 transcript (fully fetchable) — the canonical walkthrough of the Landmarks sample.
- The `apple-docs.everest.mt` mirror (renders Apple docs as static markdown) for the sample-article bodies.
- Web search result snippets for the App Intents / SwiftData samples.

Could NOT fetch: the `developer.apple.com/sample-code` index (JS-rendered, no content). Sample names below come from search + WWDC session references, not invented.

## Catalog

### 1. Landmarks: Building an app with Liquid Glass (flagship)

- **URL:** https://developer.apple.com/documentation/swiftui/landmarks-building-an-app-with-liquid-glass
- **iOS version:** iOS 26 / macOS Tahoe 26 (Xcode 26)
- **Summary:** SwiftUI multiplatform app (iPhone/iPad/Mac) rebuilt for Liquid Glass; the canonical iOS 26 reference. Walked through in WWDC25 session 323 (https://developer.apple.com/videos/play/wwdc2025/323/).
- **Patterns demonstrated:**
  - Liquid Glass: `glassEffect()`, `glassEffect(in: .rect(cornerRadius: 16))`, `glassEffect(.regular.tint(.green))`, `glassEffect(.regular.interactive())`, `GlassEffectContainer`, `glassEffectID(_:in:)` with `@Namespace`, `.buttonStyle(.glass)`, `.buttonStyle(.glassProminent)`
  - Background extension: `backgroundExtensionEffect()` (artwork mirrors/blur beyond safe area behind sidebar + inspector)
  - Navigation: `NavigationSplitView` (floating glass sidebar), `.inspector(isPresented:)`
  - Toolbar: `.toolbar`, `ToolbarItem`, `ToolbarItemGroup`, `ToolbarSpacer(.fixed)` / `ToolbarSpacer(.flexible, placement: .bottomBar)`, `.badge(count)`, `.sharedBackgroundVisibility(.hidden)` (separate item from shared glass background)
  - Scroll edge: `.scrollEdgeEffectStyle(.hard, for: .top)`
  - Search: `.searchable(text:)`, `.searchToolbarBehavior(.minimize)`, `Tab(role: .search)`
  - Tab bar: `TabView` with floating glass, `.tabBarMinimizeBehavior(.onScrollDown)`, `.tabViewBottomAccessory`, `@Environment(\.tabViewBottomAccessoryPlacement)`
  - Sheets / transitions: `.presentationDetents([.height(180), .medium, .large])`, `.matchedTransitionSource(id:in:)`, `.navigationTransition(.zoom(sourceID:in:))`
  - Button shapes: `.buttonBorderShape(.capsule)` (the default for prominent glass buttons)
  - Controls: `.controlSize(.large)`/`.small`, `.pickerStyle(.segmented)`, `Slider` with `step` (auto tick marks), `ticks` closure, `neutralValue`
  - Shape: `.rect(corner: .containerConcentric)` (concentric rectangle — corners match container)
  - Menus: `Menu` + `Label` (consistent icon+text across platforms incl. macOS)
- **NOT present** in this sample: `glassEffectUnion`, `glassEffectTransition`, `matchedGeometryEffect`, `contentTransition`, `symbolEffect`, standalone `RoundedRectangle`/`clipShape` (uses `.rect(cornerRadius:)` instead), `ButtonBorderShape` as a named type, `buttonBorderRadius`.

#### 1a–1d. Landmarks sub-articles (each a focused companion piece)

- **1a. Landmarks: Applying a background extension effect** — `backgroundExtensionEffect()`, `Image` extension to leading/trailing edges.
- **1b. Landmarks: Extending horizontal scrolling under a sidebar or inspector** — https://developer.apple.com/documentation/swiftui/landmarks-extending-horizontal-scrolling-under-a-sidebar-or-inspector — `ScrollView(.horizontal)` aligned to leading/trailing edges, `Spacer` for title-padding alignment.
- **1c. Landmarks: Refining the system-provided Liquid Glass effect in toolbars** — toolbar glass refinement (`.sharedBackgroundVisibility`, `ToolbarSpacer` grouping).
- **1d. Landmarks: Displaying custom activity badges** — `glassEffect(_:in:)` on badge views, `GlassEffectContainer` grouping badges + toggle, `glassEffectID(_:in:)` per badge, `@Namespace` morphing.

### 2. Applying Liquid Glass to custom views

- **URL:** https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views (mirror: https://apple-docs.everest.mt/docs/swiftui/applying-liquid-glass-to-custom-views/)
- **iOS version:** iOS 26
- **Summary:** The conceptual how-to for `glassEffect(_:in:)`; complements Landmarks with the morphing/union APIs Landmarks doesn't show.
- **Patterns demonstrated (verbatim code):**
  - `.glassEffect()` (default shape is `Capsule`)
  - `.glassEffect(in: .rect(cornerRadius: 16.0))` (custom shape)
  - `.glassEffect(.regular.tint(.orange).interactive())` (tinted + interactive)
  - `GlassEffectContainer(spacing: 40.0) { … }`
  - `.glassEffectID("pencil", in: namespace)` with `@Namespace private var namespace`
  - `.glassEffectUnion(id: item < 2 ? "1" : "2", namespace: namespace)` — merge multiple glass elements into one capsule
  - `.glassEffectTransition(_:)` — `GlassEffectTransition.matchedGeometry` (default) and `.materialize`
  - `.buttonStyle(.glass)`; `GlassButtonStyle` / `GlassProminentButtonStyle` / `DefaultGlassEffectShape` in See Also
  - `withAnimation { isExpanded.toggle() }` drives morphing
- **Key convention:** default glass shape is **`Capsule`**, not `RoundedRectangle`. `Circle` shown as alt. No `clipShape`/`RoundedRectangle`/`buttonBorderRadius` in this doc.

### 3. SampleTrips — SwiftData inheritance & schema migration

- **URL (session):** https://developer.apple.com/videos/play/wwdc2025/291/
- **URL (downloadable sample):** https://developer.apple.com/documentation/coredata/adopting_swiftdata_for_a_core_data_app/
- **iOS version:** session demonstrates iOS 26 features (`@available(iOS 26, *)` subclasses); downloadable sample floor is iOS 18.0+ / Xcode 16+.
- **Summary:** SwiftUI trip-tracking app demonstrating SwiftData class inheritance (`BusinessTrip`, `PersonalTrip` subclasses of `Trip`), `SchemaMigrationPlan` V1→V4, `#Predicate` filtering.
- **Patterns demonstrated:**
  - Navigation: `NavigationSplitView` with `List(selection:)` + `ForEach` in sidebar, `@Query`-driven content
  - Controls: `.pickerStyle(.segmented)` filtering trips by type via `#Predicate` (`$0 is PersonalTrip`)
  - SwiftData: `@Model`, `@Query`, `ModelContainer(for: [Trip.self, BusinessTrip.self, PersonalTrip.self])`, `#Unique`, `#Index`, `@Attribute(.preserveValueOnDeletion)`, `SchemaMigrationPlan`, `HistoryDescriptor` `sortBy` (iOS 26)
- **SwiftUI pattern relevance:** modest — NavigationSplitView + segmented Picker + List. No Liquid Glass APIs in the session snippets.

### 4. Accelerating app interactions with App Intents (Trails)

- **URL:** https://developer.apple.com/documentation/appintents/acceleratingappinteractionswithappintents
- **iOS version:** iOS 18.1+ / iPadOS 18.1+ / macOS 15.1+ / visionOS 2.1+ / watchOS 11.0+ / **Xcode 26.0+** (2025-era, but floor is iOS 18.1, not 26)
- **Summary:** Trail information app exposing features through Siri, Spotlight, Shortcuts via App Intents.
- **Patterns demonstrated (App Intents, not SwiftUI-visual):** `AppIntent`, `AppShortcut`, `AppShortcutsProvider`, `AppEntity`, `EntityQuery` / `EnumerableEntityQuery` / `EntityPropertyQuery`, `ProvidesDialog`, `ShowsSnippetView`, `IndexedEntity`, `CSSearchableItem` + `associateAppEntity(_:priority:)`, `URLRepresentableEntity`, `IntentParameter`, `EntityProperty`, `IntentDialog`, `SiriTipView`, `OpenIntent`, `URLRepresentableIntent`, `EntityStringQuery`, `NeedsDisambiguationError`.
- **SwiftUI pattern relevance:** low — no `glassEffect`, `NavigationStack/SplitView`, `List`, `.searchable`, or `buttonStyle` named in the doc. Listed for completeness as a 2025 sample.

### 5. Landmarks App Intents extension (WWDC25 session 275)

- **URL (session):** https://developer.apple.com/videos/play/wwdc2025/275/
- **iOS version:** iOS 26
- **Summary:** The Landmarks app extended with the new iOS 26 App Intents surface. The session says "check out our sample app on the developer website" but I could **not** locate a standalone downloadable sample page for it — it may be folded into the Landmarks sample or not separately published. Flagging as unconfirmed.
- **Patterns mentioned (session, not independently verified):** `SnippetIntent`, `IntentValueQuery` + `SemanticContentDescriptor` (Visual Intelligence image search), onscreen entities via `userActivity` modifier + `Transferable` (PDF export), `IndexedEntity` + `indexingKey` + `PredictableIntent` (Spotlight), `UndoableIntent`, `requestChoice` (multiple-choice), `onAppIntentExecution`, `TargetContentProvidingIntent`, `ComputedProperty` / `DeferredProperty` macros, `AppIntentsPackage`.

## Patterns observed across iOS 26 samples (synthesis)

**Most frequent APIs (by sample count):**
1. `NavigationSplitView` — Landmarks, SampleTrips. The dominant iOS 26 navigation shell; floating glass sidebar + `backgroundExtensionEffect` is the canonical iPad/Mac layout.
2. `glassEffect()` / `.buttonStyle(.glass)` / `.glassProminent` — Landmarks + Applying-Liquid-Glass. Every custom glass surface goes through these; raw materials are out.
3. `GlassEffectContainer` + `glassEffectID(_:in:)` + `@Namespace` — both glass samples. **Grouping multiple glass views in a `GlassEffectContainer` is the convention** for consistent sampling and morphing; morph transitions use `glassEffectID`, not `matchedGeometryEffect`.
4. `.toolbar` + `ToolbarSpacer` + `ToolbarItemGroup` + `.badge` + `.sharedBackgroundVisibility` — Landmarks. Toolbar grouping with `ToolbarSpacer(.fixed)` to separate action clusters is the convention; `.sharedBackgroundVisibility(.hidden)` separates an item from a shared glass background.
5. `TabView` floating + `.tabBarMinimizeBehavior(.onScrollDown)` + `.tabViewBottomAccessory` + `Tab(role: .search)` — Landmarks. The floating, scroll-minimizing tab bar with a dedicated search tab is the iOS 26 navigation convention on iPhone.
6. `.searchable` + `.searchToolbarBehavior(.minimize)` — Landmarks.
7. `.presentationDetents` + `.matchedTransitionSource` + `.navigationTransition(.zoom)` — Landmarks. Sheet→source zoom morph is the iOS 26 sheet convention (replaces ad-hoc `matchedGeometryEffect` for sheet entry).
8. `.controlSize`, `.pickerStyle(.segmented)` — Landmarks, SampleTrips.
9. `.rect(corner: .containerConcentric)` — Landmarks. Concentric rectangle shape for nested rounded corners.
10. `Menu` + `Label` — Landmarks. Consistent icon+text menu items across platforms.

**Conventions confirmed:**
- **Capsule is the default glass button shape.** `.buttonStyle(.glass)`/`.glassProminent` default to `.buttonBorderShape(.capsule)`; the no-arg `glassEffect()` also defaults to `Capsule`. `RoundedRectangle`/`.rect(cornerRadius:)` is used only for cards/badges/grouped content, not prominent buttons. (Corroborates [[button-shapes-ios26-liquid-glass]].)
- **`GlassEffectContainer` groups glass views** — the samples do not scatter loose `.glassEffect()` views; they wrap related glass surfaces (badges + toggle) in a container and use `glassEffectID` for morphing, `glassEffectUnion` for merging.
- **No raw `clipShape`/`RoundedRectangle` for glass** — the samples use `.glassEffect(in: .rect(cornerRadius:))` / `.buttonBorderShape(...)` rather than clipping a material. (Community gotcha: `.clipped()` kills the glass effect.)
- **`backgroundExtensionEffect` over manual safe-area insets** — the sidebar/inspector extend artwork beyond the safe area without clipping; this replaces manual `ignoresSafeArea` + edge-inset plumbing.
- **`matchedTransitionSource` + `.navigationTransition(.zoom)` for sheet entry** — not `matchedGeometryEffect`. `matchedGeometryEffect` did **not** appear in any iOS 26 sample for sheet/source morphing.
- **One `withAnimation` per coordinated change** — the Applying-Liquid-Glass doc drives badge morphing with a single `withAnimation { isExpanded.toggle() }`, matching Cosmos's "one `withAnimation` per coordinated state change" rule.

**APIs the user asked about that did NOT appear in any iOS 26 sample:**
- `PhaseAnimator`, `KeyframeAnimator`, `.contentTransition(.blurReplace/.numericText)`, `withAnimation` completion, `matchedGeometryEffect`, `.accessibilityRotor`, `MeshGradient`, `scrollPosition`, `scrollTransition`, `ViewThatFits`, `AnyLayout`, `Layout` protocol, `Charts` — none surfaced in the Landmarks/Applying-Liquid-Glass/SampleTrips material. Their absence in the flagship iOS 26 samples is itself a signal (Apple did not make them load-bearing for the new design language).
- `listSectionSpacing`, `.sectionActions` — not present in the fetched sample material.
- `buttonBorderRadius` — not present (the samples use `.buttonBorderShape(.capsule)` + `.controlSize`, not a radius knob).

## Sources

- https://developer.apple.com/sample-code (index; not fetchable, JS-rendered)
- https://developer.apple.com/videos/play/wwdc2025/323/ — Build a SwiftUI app with the new design (Landmarks walkthrough)
- https://developer.apple.com/documentation/swiftui/landmarks-building-an-app-with-liquid-glass
- https://apple-docs.everest.mt/docs/swiftui/landmarks-building-an-app-with-liquid-glass/
- https://apple-docs.everest.mt/docs/swiftui/applying-liquid-glass-to-custom-views/
- https://developer.apple.com/documentation/swiftui/landmarks-extending-horizontal-scrolling-under-a-sidebar-or-inspector
- https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass
- https://developer.apple.com/videos/play/wwdc2025/291/ — SwiftData inheritance & migration (SampleTrips)
- https://developer.apple.com/documentation/coredata/adopting_swiftdata_for_a_core_data_app/
- https://developer.apple.com/documentation/appintents/acceleratingappinteractionswithappintents
- https://developer.apple.com/videos/play/wwdc2025/275/ — Explore new advances in App Intents (Landmarks extension)
- https://developer.apple.com/videos/play/wwdc2025/224/ — Evaluate your app for Accessibility Nutrition Labels (uses Landmarks; not a sample)