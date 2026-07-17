---
tags: [risk, refuted-spec, swiftui, section, availability]
aliases: [headerProminence refuted]
related: [cosmos-section]
---

# `.headerProminence(_:)` is not a real SwiftUI API (refuted spec)

## Claim (from spec)

[[PHASE2]] §2.13 "CosmosSection" lists `.headerProminence(_:)` (iOS 15+) under "Customization surface" and "Key modifiers to wire".

## Verdict: REFUTED

`.headerProminence(_:)` does **not** exist in the Xcode 27 Beta 3 SwiftUI SDK. Verified by grepping both:

- `iPhoneSimulator.sdk/.../SwiftUI.swiftmodule/x86_64-apple-ios-simulator.swiftinterface`
- `MacOSX27.0.sdk/.../SwiftUI.swiftmodule/arm64e-apple-macos.swiftinterface`

Zero hits for `headerProminence` / `func headerProminence`. The only `Prominence`-named symbol is **`BadgeProminence`** with `decreased` / `standard` / `increased` and the `.badgeProminence(_:)` modifier (unrelated — that is for badges, not section headers).

## What this means

- `CosmosSection` (see [[cosmos-section]]) **omits** `.headerProminence(_:)`. Wiring it would be a compile error (`Value of type '...' has no member 'headerProminence'`).
- PHASE2 §2.13 should be updated to drop `.headerProminence(_:)` from the Section wiring list (root doc is the source of truth → on conflict the root doc wins, so this is a pending root-doc correction).

## How to confirm / re-check

```sh
IIFACE=".../SwiftUI.swiftmodule/x86_64-apple-ios-simulator.swiftinterface"
grep -in "headerprominence" "$IIFACE"   # → no output (refuted)
grep -in "badgeProminence" "$IIFACE"     # → the real, unrelated symbol
```

## If reintroduced

If a future SDK reintroduces section header prominence, add a guarded `cosmosHeaderProminence(_:)` `View` wrapper then. The `CosmosSection` doc comment already carries this note.