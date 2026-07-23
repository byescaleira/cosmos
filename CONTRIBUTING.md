## Contributing

1. Keep atoms small and single-purpose; prefix every public type with `Cosmos`.
2. Prefer semantic tokens from `CosmosTheme` (`Sources/Cosmos/Base/Theme/`) over raw points / colors / fonts. Atoms **read** the relevant tokens in `body` so the `.cosmos*` subtree overrides reach them — never author a pass-through atom for a token its override surface promises (see `DECISIONS.md`, 2026-07-23).
3. Add reusable visual/behavior modifiers under `Sources/Cosmos/Modifiers/`. Per-instance overrides read `@Environment(\.cosmosTheme)` / `\.cosmosConfiguration`, mutate a copy via the `with*` builders, and re-inject with `.environment(\.…)` — subtree-scoped, composable.
4. Gate platform-absent APIs with `#if os()` and centralize `if #available` for above-floor features (per `VERSIONING.md`); mirror the SDK `@available` you guard against in a comment.
5. Document public APIs with DocC; co-locate `#Preview(_:traits:)` blocks (default / dark / Dynamic Type accessibility / landscape / RTL / per-platform) at the bottom of each atom file using `.cosmosPreviewEnv(…)` / `.cosmosPreviewVariant(…)` / `CosmosPreviewModifier`. Do not use the deprecated `.previewDevice` / `.previewLayout` / `.previewDisplayName` / `.previewInterfaceOrientation` / `.previewContext` modifiers.
6. Add Swift Testing unit tests (`Tests/CosmosTests/`) for models, tokens, contracts, and atom construction/behavior. Use `CosmosMock` for deterministic data; no UI snapshots, no ViewInspector.
7. Motion: call `.cosmosAnimation(_:value:)` / `.cosmosTransition(_:)` / `.cosmosContentTransition(_:)` — never raw `Animation.spring(...)` / `.transition(.move...)`. Gate through `CosmosMotionPolicy` (config-aware), not the bare `accessibilityReduceMotion` value. Symbol effects auto-respect Reduce Motion — gate on `isEnabled` only.
8. Concurrency: zero warnings under Swift 6 language mode. Public value types are `Sendable`; handlers `@Sendable`; no `NSLock` / `DispatchQueue` / `nonisolated(unsafe)` mutable globals. One-time work uses the `static let` once-token; mutable flags use `Mutex` / `Atomic` from `import Synchronization`.
9. No UIKit symbols (see `CLAUDE.md`): no `import UIKit`, `UIColor`, `UIViewController`, `UIHostingController`, or `#if canImport(UIKit)`. Haptics via `.sensoryFeedback`; fonts via CoreText; colors via SwiftUI `Color`.
10. Deprecate with `@available(*, deprecated, message:)` and a migration runway before obsoletion (per `VERSIONING.md`); record changes in `CHANGELOG.md`.

## Branching

Gitflow: English commits, each ending with `Co-Authored-By: Claude <noreply@anthropic.com>` when co-authored.

- `main` — stable releases only; never commit directly.
- `feature/<name>` — new components / features.
- `fix/<name>` — bug fixes.

Do not merge to `main` without explicit confirmation.

## Release process

1. Update `CHANGELOG.md` (`## [Unreleased]` → `## [X.Y.Z] - <date>`) and bump the install floor in `README.md` if the minimum version moved.
2. Build for every target platform: `swift build` + per-triple builds; `swift test`; `swift build -c release` (zero concurrency warnings).
3. Merge the feature branch to `main` (after explicit confirmation).
4. Tag `X.Y.Z` and publish a GitHub Release; confirm CI is green.

## Research and decisions

Research tasks (competitive analysis, API investigation, verification) are persisted to the Obsidian vault at `vault/`; architectural decisions are recorded as ADR rows in `DECISIONS.md` + a `vault/02-decisoes/` note. The root docs are the source of truth; the vault is a synthesis/navigation layer.