---
tags: [risk, localization, string-catalog, swiftpm, xcodebuild, refuted-spec, hygiene]
aliases: [SwiftPM String Catalog symbols, GeneratedStringSymbols not emitted by swift build, LocalizedStringResource codegen gap]
related: [ci-no-cross-builds, cosmos-audit-2026-07-24, cosmos-button]
---

# Refuted spec — SwiftPM does not generate String Catalog symbols

## Finding

The `/swiftui-pro` hygiene rule recommends generated `LocalizedStringResource` symbols
(`Text(.helloWorld)`) over raw string keys when a project ships a `Localizable.xcstrings`.
The strict-alignment audit (task **D**) planned to migrate Cosmos to those generated symbols:
delete the hand-authored `CosmosPreviewStrings`, use `CosmosButton(.welcomeContinue, action:)`
in previews, and assert `String(localized: .welcomeHeadline)` in tests.

**This is infeasible under the project's build system.** Verified on a clean build:

```
$ rm -rf .build && swift build
# 529 errors: "reference to member 'welcomeHeadline' cannot be resolved without a contextual type"
$ find .build -name "GeneratedStringSymbols_Localizable.swift" | wc -l
0
```

`swift build` (SwiftPM) compiles only 40 source files and emits **no**
`GeneratedStringSymbols_Localizable.swift`. The "Generate String Catalog Symbols" codegen is an
**Xcode build-system** feature — it runs under `xcodebuild -scheme Cosmos …` (which does produce
the file under `.build/out/Intermediates.noindex/Cosmos.build/…/DerivedSources/`), but **not** under
SwiftPM's `swift build`, which is the project's binding primary build/verify path
(`swift build && swift test && swift build -c release`, per CLAUDE.md).

## Why hand-authoring the extension is also blocked

The obvious fallback — write `extension LocalizedStringResource { static var welcomeHeadline … }`
in checked-in source — collides with the other build path: `xcodebuild` *does* generate that exact
extension. Two definitions in the same module → `invalid redeclaration of 'welcomeHeadline'`,
breaking the cross-compile matrix (task **E**). So the generated-symbol pattern cannot be used
in-library under **either** build system without breaking the other.

## Resolution (applied)

- **Keep `CosmosPreviewStrings`** (hand-authored `String` constants) as the in-library source of
  truth. It compiles under both `swift build` and `xcodebuild` with no collision. Documented inline
  why it stays (the SwiftPM gap + the xcodebuild collision).
- **Add `CosmosButton.init(_ resource: LocalizedStringResource, action:)`** as a **consumer-facing**
  API: consumers using Xcode's codegen for *their* app's catalog pass their generated symbols
  (`CosmosButton(.theirKey, action: {})`). This is real hygiene value for consumers without Cosmos
  itself depending on symbols it can't generate. `Text(resource)` resolves via SwiftUI's native
  runtime (the resource carries its bundle).
- **Overload coexistence**: a bare `String` literal resolves to the `String` (`titleKey`) init —
  Swift prefers `String` for string literals among `ExpressibleByStringLiteral` candidates — so the
  two inits don't collide at existing call sites (`CosmosButton("welcome.continue")`). Verified by
  build + a construction test (`buttonConstructsFromLocalizedStringResource`).
- **Localization.md** documents the gap.

## Why the finding is refuted, not deferred

This isn't a "do it later" — the pattern is structurally unavailable under SwiftPM and structurally
redundant/conflicting under xcodebuild. No toolchain upgrade closes it without SwiftPM gaining the
codegen (and even then, hand-authored would conflict until removed). The manual constants are the
correct, durable choice for a SwiftPM-primary multiplatform library.

## How to apply

- Do **not** introduce `Text(.someKey)` / `String(localized: .someKey)` against Cosmos's own catalog
  keys in library source — it breaks `swift build`.
- Do add `LocalizedStringResource`-accepting inits where they help consumers pass their own symbols
  (the `CosmosButton` pattern), and test with an explicit `LocalizedStringResource(…)` value.
- If SwiftPM ever gains String Catalog symbol codegen, revisit: drop `CosmosPreviewStrings` and
  migrate previews/tests to generated symbols (the xcodebuild collision disappears because nothing
  is hand-authored).