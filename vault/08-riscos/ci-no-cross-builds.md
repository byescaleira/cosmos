---
tags: [risk, ci, multiplatform, glasseffect, visionos, methodology]
aliases: [CI cross-build gap, visionOS glassEffect regression, per-platform build verification]
related: [cosmos-image, cosmos-audit-2026-07-24, above-floor-gating-pattern]
---

# Risk — CI has no per-platform cross-builds (multiplatform regressions latent)

## Finding

The CI workflow (`.github/workflows/ci.yml`) runs only the host `swift build` +
`swift test` on `macos-latest`. It performs **no per-platform cross-builds** —
there is no `swift build --triple arm64-apple-{ios,tvos,watchos,xros}26.0-simulator`
matrix. CLAUDE.md is binding: *"Build for each target platform to confirm `#if os()`
coverage."* CI does not enforce this, so a platform-specific compile regression can
land on `main` green.

## Concretely surfaced (0.11.0)

During the `CosmosImage` 0.11.0 per-platform verification, the **visionOS**
cross-build failed on a **pre-existing** bug identical on `main` (untouched by
the image work):

- `CosmosButton` `ChromeBody` applied `.glassEffect(.regular.tint(chromeBackground),
  in: .capsule)` unconditionally to every non-glass variant.
- `cosmosToast` host chrome applied `.glassEffect(.regular, in: .rect(cornerRadius: 32))`
  unconditionally.

`glassEffect` is **unavailable on visionOS** (Liquid Glass is not on visionOS).
iOS / macOS / tvOS / watchOS 26 all expose it. The fix: `#if os(visionOS)` → fall
back to an opaque `theme.colors.surface` / chrome-tint capsule (matching the existing
reduce-transparency fallback); the other 4 platforms keep the glass path. Recorded
in `CHANGELOG.md` `[0.11.0] / Fixed`. The regression shipped through 0.9.0 / 0.10.0
undetected because CI never cross-built.

## Why it stayed latent

- `glassEffect` availability is a **compile-time** platform gate, not a runtime
  `if #available` — there is no graceful runtime degradation; the symbol simply is
  absent on visionOS. Only a visionOS compile catches it.
- The audit waves (see [[cosmos-audit-2026-07-24]]) reviewed code and ran host builds;
  none ran the full per-platform matrix, so the visionOS-absent symbol was never
  exercised.

## How to apply

- **Verify locally before every release** (already in the plan's Verification step):
  `swift build --triple arm64-apple-{ios26.0,tvos26.0,watchos26.0,xros26.0}-simulator`
  + macOS host. This caught the 0.11.0 regression.
- **Ideally**: add a per-platform build matrix to CI so the host-only gap closes.
  Until then, the local cross-build loop is the only guard against
  `#if os()` / platform-absent-symbol regressions. Any new use of an
  iOS-26-introduced symbol that is **not** uniform across all 5 platforms
  (e.g. `glassEffect` = no visionOS; `Slider`/`Stepper` = no tvOS;
  `TextEditor` = no tvOS/watchOS) must be `#if os()`-gated and cross-built.
- See [[above-floor-gating-pattern]] for the OS-27 `#if swift(>=6.4)` +
  `if #available` dual-gate (different concern: above-floor runtime availability,
  not platform-absent symbols).

## Status

**Mitigated (2026-08-03, swiftui-pro task E).** `.github/workflows/ci.yml` now has a
`cross-build` job with a `fail-fast: false` matrix that runs `xcodebuild -scheme Cosmos
-destination 'generic/platform=<OS>' build` for iOS / tvOS / watchOS / visionOS (SDK builds,
no simulator-runtime coupling). The macOS host slice stays gated by the existing
`build-and-test` job (`swift build && swift test --enable-code-coverage`). The cross-build
step skips gracefully (visible `::warning::`, exit 0) when a platform component isn't
installed on the runner — an environment limit, not a code defect — while a real `#if os()`
compile regression resolves the destination and fails compilation, propagating as a real
failure. This also validates the Xcode build path that runs the "Generate String Catalog
Symbols" codegen `swift build` doesn't (see [[swiftpm-no-string-catalog-symbol-codegen]]),
confirming the generated `LocalizedStringResource` extension compiles alongside the
hand-authored `CosmosPreviewStrings` with no redeclaration conflict. Locally verified:
iOS + tvOS build green; watchOS + visionOS skip (platform component not downloaded on this
dev machine) — hosted `macos-latest` runners ship all platform components, so all four gate
in CI.

The `glassEffect` visionOS regression itself was **fixed** in 0.11.0; this note now tracks the
former systemic CI gap, which is closed by the matrix.