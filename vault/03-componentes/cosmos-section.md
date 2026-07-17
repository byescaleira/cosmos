---
tags: [component, atom, wave-e, section, list, swiftui]
aliases: [CosmosSection]
related: [header-prominence-not-a-real-api]
---

# CosmosSection

`Section` wrap-view — Wave E atom ([[PHASE2]] §2.13). File: `Sources/Cosmos/Atoms/CosmosSection.swift`.

## Pattern

Wrap-view (no `SectionStyle` — `Section` is a primitive, `Body == Never`; zero style-protocol hits in either `.swiftinterface`). No type-level `#if os()` guard: every exposed init is `@available` ≤ iOS 17 / visionOS 1, below the Cosmos 26 floor, so the type compiles on all 5 platforms.

## Exposed inits

- `init(content:header:footer:)` — primary 3-closure form.
- `init(content:footer:)` (Parent == EmptyView); `init(content:header:)` (Footer == EmptyView); `init(content:)` (both EmptyView).
- `init(_ titleKey: String, content:)` (Parent == CosmosLocalizedText, Footer == EmptyView) — Cosmos convention (String Catalog key), **not** the native `LocalizedStringKey`.
- `init(verbatim:content:)` (Parent == Text); `init(_ titleResource: LocalizedStringResource, content:)` (Parent == Text, iOS 16+).
- Collapsible `init(isExpanded:content:header:)` + title-key / verbatim / titleResource `isExpanded` variants — all constrained `where Footer == EmptyView` (a collapsible section **with a footer is not publicly expressible**).

The atom stores an optional `isExpanded: Binding<Bool>?`; `body` branches in one `@ViewBuilder` (the `isExpanded` branch builds a fresh `Section` with `EmptyContent` footer, ignoring the stored footer closure — correct because the `isExpanded` inits constrain `Footer == EmptyView`).

## Customization limits

Appearance is fully determined by the enclosing `List`/`Form`/`.listStyle`. **MUST NOT set its own background/inset/separators.** `Section` renders nothing meaningful outside a `List`/`Form`/`GroupBox`-like container — previews wrap in `List`.

## Container-modifier platform matrix (verified Xcode 27 Beta 3)

The native modifiers carry `@available(<platform>, unavailable)` in the interface even though the symbols physically appear in every platform's `.swiftinterface` — `#if os()` is still required or it is a compile error.

| Modifier | iOS | macOS | tvOS | watchOS | visionOS | Cosmos wrapper |
|---|---|---|---|---|---|---|
| `listSectionSpacing(_:)` | 17+ | ✗ | ✗ | 10+ | ✓ | `cosmosListSectionSpacing` — `ListSectionSpacing` **type** is macOS/tvOS-unavailable → the typed overload is whole-function `#if os(iOS) \|\| os(watchOS) \|\| os(visionOS)`; the `CGFloat` overload is a true no-op elsewhere |
| `listSectionSeparator(_:edges:)` / `…Tint` | 15+ | 13+ | ✗ | ✗ | ✓ | `#if !os(tvOS) && !os(watchOS)` body guard (params universal → true no-op) |
| `listRowSeparator(_:edges:)` / `…Tint` | 15+ | 13+ | ✗ | ✗ | ✓ | `#if !os(tvOS) && !os(watchOS)` |
| `sectionActions(_:)` | 18+ | 15+ | ✗ | ✗ | 2+ | `#if !os(tvOS) && !os(watchOS)` |
| `listSectionMargins(_:_:)` | 26+ | ✗ | ✗ | ✗ | 26+ | `#if os(iOS) \|\| os(visionOS)` |

All version bounds are ≤ the Cosmos 26 floor → **no runtime `if #available` gate needed**, only `#if os()` compile guards. The platform-unavailable **parameter type** (`ListSectionSpacing`) forces a whole-function guard rather than a body-only no-op — the key gotcha.

## Cross-cutting

- **Accessibility:** structural — no own traits. `Text`/`CosmosLocalizedText` header → SwiftUI exposes header semantics. Custom `View` header → caller adds `.accessibilityAddTraits(.isHeader)` (and optionally `.accessibilityHeading(.h2)`); the atom does not force it.
- **Haptics:** none (non-interactive; disclosure/expand is native). `.sectionActions` button haptics belong to those buttons.
- **Motion:** `none` — native expand/collapse only; do NOT layer `.cosmosAnimation` (desync). Callers wanting coordinated expand/collapse wrap the `Binding<Bool>` mutation in one `withAnimation(theme.motion.spring(for: .containerTransform).animation)`.
- **Tracking:** none — structural/decorative (like `CosmosDivider`); a `List` of many sections would be noisy.

## See also

- [[header-prominence-not-a-real-api]] — the one spec item omitted from the wiring.