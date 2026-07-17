# Proposal: Cosmos

## 1. Problem

Rafael's previous design system, `Prism`, drifted and accumulated tech debt. A fresh foundation is needed for Apple v26 platforms with strict atomic design, but starting from components led to inconsistent behavior and duplicate configuration logic.

## 2. Solution

Create `Cosmos`, a new design system that begins with a **shared base object** (`CosmosConfiguration`) distributed via SwiftUI `Environment`. Every component inherits the same contracts for accessibility, localization, log, error, loading, and enablement. Only after the base is solid do we add atoms, molecules, and organisms.

## 3. Goals

- Predictable component behavior through shared configuration.
- Platform-native feel aligned with Apple Human Interface Guidelines.
- Swift 6 strict concurrency with `Sendable` value types.
- A single SPM target `Cosmos` that exposes configuration, theme, atoms, molecules, and data-driven screens through one `import Cosmos`.

## 4. Non-goals

- UIKit support or any explicit UIKit dependency.
- watchOS, visionOS, or Mac Catalyst support.
- Pre-v27 Apple platform compatibility.
- Runtime theming engine in the first iteration.

## 5. Success Criteria

- `swift build` and `swift test` pass on every commit.
- Every component reads behavior from `CosmosConfiguration`.
- Base contracts are documented and unit-tested.

## 6. Risks

| Risk | Mitigation |
|---|---|
| Over-engineering the base | Keep contracts minimal; add fields only when a component needs them. |
| `@MainActor` / `@Observable` friction | Use value types and environment replacement instead of shared mutable classes. |
| Localization complexity | Start with `Bundle` + `Locale`; defer plural rules and ICU integration. |

## 7. Next Steps

1. Add `.strings` catalog with sample keys.
2. Create `/byescaleira` Claude Code plugin with project context.
3. Implement the first atom using the base contract.
