---
tags: [research, ios-27, swiftui, above-floor, wwdc26]
aliases: [iOS 27 SwiftUI APIs, above-floor iOS 27, WWDC26 SwiftUI]
related: [[above-floor-gating-pattern]], [[cosmos-picker]], [[cosmos-tabview]], [[cosmos-section]]
---

# iOS 27 (WWDC26) SwiftUI above-floor APIs

Research snapshot of SwiftUI symbols introduced above the Cosmos-26 floor (i.e. `@available(iOS 27, *)` / `*OS 27.0+`). Distinguishes **above-floor (27)** from **floor (26 / 18 / 17)** so the Cosmos-27 resolver layer (see [[above-floor-gating-pattern]]) can target only what is genuinely new.

## Confirmed above-floor (iOS 27.0+)

### Tab / navigation
- `TabRole.prominent` — `static var prominent: TabRole { get }`. Platforms: iOS 27.0+, iPadOS 27.0+, Mac Catalyst 27.0+, macOS 27.0+, tvOS 27.0+, visionOS 27.0+, watchOS 27.0+. Trailing-separated tab (like `.search`); only one tab may be prominent; if none set, a `.search` tab may receive the prominent treatment by default.
  ```swift
  if #available(iOS 27.0, *) {
      Tab("Now", systemImage: "play.fill", value: .nowPlaying, role: .prominent) { NowPlayingView() }
  }
  ```
  Refs: https://developer.apple.com/documentation/swiftui/tabrole/prominent , https://livsycode.com/swiftui/swiftui-tabrole-prominent-in-ios27/

- `NavigationTransition.crossFade` (=`CrossFadeNavigationTransition`) — `static var crossFade: CrossFadeNavigationTransition { get }`. Cross-fades between appearing/disappearing view; no `sourceID`/namespace required (unlike `.zoom`). On a sheet, fades in over content instead of sliding. Platforms: 27.0+ across iOS/iPadOS/Mac Catalyst/macOS/tvOS/visionOS/watchOS.
  ```swift
  .navigationTransition(.crossFade)
  ```
- `AnyNavigationTransition` — type eraser to pick a navigation transition at runtime. 27.0+.
  Refs: https://developer.apple.com/documentation/swiftui/navigationtransition/crossfade , https://livsycode.com/swiftui/navigationtransition-crossfade-in-swiftui/

### Picker
- `PickerStyle.tabs` / `TabsPickerStyle` — `static var tabs: TabsPickerStyle { get }`. Platforms: iOS 27.0+, iPadOS 27.0+, Mac Catalyst 27.0+, macOS 27.0+, tvOS 27.0+, visionOS 27.0+. **Not watchOS.** Renders segmented tabs; on iOS/tvOS/visionOS visually matches `.segmented`; macOS has distinct tab treatment; VoiceOver announces as "tabs" (use only for tab navigation, not value selection). Get the Liquid Glass look with `.buttonBorderShape(.capsule).pickerStyle(.tabs)`; also appears automatically for a Picker in a root `TabView`/sidebar/inspector.
  ```swift
  Picker("View", selection: $view) { Text("Events").tag(Views.events); Text("Reminders").tag(Views.reminders) }
  .buttonBorderShape(.capsule).pickerStyle(.tabs)
  ```
  Refs: https://apple-docs.everst.mt/docs/swiftui/pickerstyle/tabs/ , https://origin-devforums.apple.com/forums/thread/833199 (Apple frameworks engineer), WWDC26 session 269 @ 02:38.

### Toolbar
- `ToolbarItemPlacement.topBarPinnedTrailing` — pins an item to the trailing edge; only overflows when search is active. 27.0+.
- `toolbarMinimizeBehavior(_:for:)` — collapse the navigation bar on scroll (integrated top tab bar minimizes with it). 27.0+.
- `visibilityPriority(_:)` on `ToolbarContent` + `ToolbarOverflowMenu` — rank items / declare always-overflow actions. 27.0+.
  Refs: https://developer.apple.com/videos/play/wwdc2026/269/ , https://swiftwithmajid.com/2026/06/23/taking-control-of-toolbar-items-in-swiftui/

### Reorder / drag containers (27.0+; lazy drag is macOS 26.0+)
- `reorderContainer(for:isEnabled:move:)` and multi-collection `reorderContainer(for:in:isEnabled:move:)`; `reorderable()` / `reorderable(collectionID:)` on `DynamicViewContent`. `ReorderDifference<Item.ID, CollectionID>` — no manual index math. Works across `List`, `LazyVGrid`, custom containers; **watchOS gets reordering for the first time**; **unavailable on tvOS**.
- `dragContainer(for:itemID:in:_:)` + `draggable(containerItemID:containerNamespace:)` — lazy payload drag. **macOS 26.0+** (above-floor for Mac only at 26; elsewhere 27.0+).
  Refs: WWDC26 session 271 (code-along), https://blakecrosley.com/blog/whats-new-swiftui-ios-27

### Document model (27.0+)
- `ReadableDocument` / `WritableDocument` (class-bound protocols), `Document` typealias; `DocumentReader<Snapshot>` / `DocumentWriter<Snapshot>`, `FileWrapperDocumentReader/Writer`, `URLDocumentConfiguration`, `DocumentCreationSource` + `NewDocumentButton`. Updated `fileExporter` takes a `WritableDocument`. Apps built with the 27.0 SDK.

### Presentation / alerts (27.0+)
- Item-binding: `alert(_:item:actions:)`, `alert(_:item:actions:message:)`, `confirmationDialog(_:item:titleVisibility:actions:)`, `confirmationDialog(_:item:titleVisibility:actions:message:)`.
- Error-binding: `alert(error:actions:message:)`, `alert(error:actions:)` — title inferred from `LocalizedError.errorDescription`.
- Swipe actions on any view: `swipeActions(edge:allowsFullSwipe:content:onPresentationChanged:)` + `swipeActionsContainer()` (on `ScrollView`/`LazyVStack`).

### AsyncImage (27.0+)
- Standard HTTP caching by default (respects server cache headers).
- `AsyncImage(request:scale:)` + phased + content/placeholder variants taking `URLRequest`.
- `asyncImageURLSession(_:)` — share a configured `URLSession`/`URLCache` across a subtree.

### Misc 27.0+
- `@State` becomes a macro; classes stored in `@State` lazily init once per view lifetime (back-deploys to iOS 17 / macOS 14 — source-breaking if you both default-init and assign in `init`).
- `ContentBuilder` unifies result builders (back-deploys; compile-time win in Xcode 27).
- `GestureInputKinds` option set (touch vs pointer…).
- `SensoryFeedback` `Payload` enum (intensity moved); fixes FB21333309.
- `TextRenderer` support on `Text` views.
- `TextField` prompt respects custom font/color styling.
- `UIHostingSceneDelegate` (UIKit bridge).
- `appearsActive` env value (dims custom UI when window inactive — iPad/Mac).
- iPhone apps resizable on iOS 27; Xcode 27 Live Preview resize handles.

## NOT above-floor (confirmed floor — do NOT gate at 27)

- **`onScrollGeometryChange` / `onScrollVisibilityChange` / `onScrollTargetVisibilityChange` / `ScrollGeometry`** — **iOS 18.0+** (WWDC24). Floor.
- **`tabViewBottomAccessory`** — **iOS 26.0+**; new `tabViewBottomAccessory(isEnabled:content:)` variant **iOS 26.2+** (fixes the 26.1 empty-container regression). Floor, but the `isEnabled` variant is a 26.2 floor sub-version.
- **`GlassEffectTransition.matchedGeometry` / `glassEffectTransition(_:)` / `glassEffectID` / `GlassEffectContainer`** — **iOS 26.0+** (Liquid Glass). Floor. The `default` transition now applies extra scale/offset when shape identity is unchanged but content changes; opt out by providing a specific animation like `spring`. No new 27-only glass cases surfaced.
- **`FormStyle` / `ControlGroupStyle`** — no new cases in iOS 27. Existing `.columns` FormStyle is iOS 16+ floor; ControlGroupStyle unchanged.
- **`symbolEffect` / `PhaseAnimator` / `KeyframeAnimator`** — floor (iOS 17 / WWDC23). No new variants in iOS 27 surfaced; iOS 27 mentions `@Animatable` macro (iOS 26) and `.reorderable()` for transitions.
- **`NavigationTransition` protocol / `.zoom` / `.automatic`** — floor iOS 18. Only `.crossFade` + `AnyNavigationTransition` are 27-new.

## Apple sample code (iOS 27 / WWDC26)

- **Enriching your text in text views** — TextKit 2 viewport rendering, collapsible layout, reusable attachments, `NSTextTable`. iOS 27.0+ Beta. GitHub mirror: https://github.com/apple-sample-code/EnrichingYourTextInTextViews ; session https://wwdc.ai/2026/370 . (UIKit/AppKit-centric — wrap via `UIViewRepresentable`/`NSViewRepresentable` for SwiftUI.)
- WWDC26 session 271 code-along ("Build powerful drag and drop in SwiftUI") demonstrates `reorderContainer` / `dragContainer` working unchanged across `List` and `LazyVGrid` — no downloadable sample URL surfaced.
- No standalone downloadable SwiftUI sample for `TabRole.prominent`, `.tabs`, `NavigationTransition.crossFade`, or the new document model surfaced on developer.apple.com/sample-code (page is JS-rendered; check directly after Xcode 27 install).

## Cosmos impact

- `CosmosTabRole` resolver: add `.prominent` as an above-floor case (combined compile+runtime gate, iOS 27). See [[cosmos-tabview]].
- `CosmosPicker`: `.tabs` is above-floor (27) and **not watchOS** — combined gate with `#if !os(watchOS)` plus `if #available(iOS 27, *)`. See [[cosmos-picker]].
- `CosmosNavigationTransition` (if introduced): expose `.crossFade` via a 27-only resolver case; `.zoom`/`.automatic` are floor iOS 18.
- Do **not** add 27-gates for scroll geometry, `tabViewBottomAccessory`, glass, `FormStyle`/`ControlGroupStyle`, or symbol/phase/keyframe — they are floor.