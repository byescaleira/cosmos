---
tags: [button, liquid-glass, shape, ios26, ios27, research, atom-input]
aliases: [button-shape-research, liquid-glass-button-shape, capsule-vs-roundedrectangle]
related: [[cosmos-button]]
---

# Button shapes in iOS 26 / 27 Liquid Glass — research

Synthesis of Apple HIG + WWDC25/26 + SwiftUI/UIKit docs on **prominent / filled button shape** under Liquid Glass. Source of truth for any Cosmos primary-button shape decision. All claims cited.

## TL;DR verdict

- **Apple's default for Liquid Glass buttons is CAPSULE** (fully rounded, radius = half the control height). This is the system's rhythm for iOS 26+.
- A Cosmos **primary / prominent** button should default to **capsule** (`RoundedRectangle(cornerRadius: .infinity)` / `Capsule()`), NOT `RoundedRectangle(cornerRadius: 8)`.
- A **discrete-radius RoundedRectangle** is correct for: nested/grouped content (cards, List rows, GroupBox), high-density macOS inspectors (`.mini`/`.small`/`.medium` `controlSize`), and anywhere concentricity with a rectangular parent matters (`cornerRadius: .containerConcentric`).

## 1. Default shape — capsule (direct quotes)

WWDC25 "Build a SwiftUI app with the new design" (session 323):
> "Bordered buttons now have a **capsule shape by default**, harmonious with the curved corners of the new design. Mini, small, and medium size controls on macOS retain a rounded-rectangle shape, which preserves horizontal density. And the existing **buttonBorderShape** modifier enables you to specify the shape for any size."
URL: https://developer.apple.com/videos/play/wwdc2025/323/

WWDC25 "Build a UIKit app with the new design" (session 284):
> "By default, the glass is in a **capsule shape**. To customize the shape, use the new **cornerConfiguration** API."
URL: https://developer.apple.com/videos/play/wwdc2025/284/

WWDC25-356 "Get to know the new design system" — shape-type table:
- **Fixed** — "Constant corner radius."
- **Capsule** — "Radius half the container size."
- **Concentric** — "Calculated radius by subtracting padding from parent."
> "Capsule is used a lot in system, because it supports concentricity."
> "Capsules bring focus to touch-friendly layouts."
> "Capsules best used for standout actions on desktop."
> "iPhone → Capsules for controls near screen edge."
> "iPad and Mac → Concentric shape for controls near the edge."
URL: https://wwdcnotes.com/documentation/wwdc25-356-get-to-know-the-new-design-system/

## 2. `.glass` / `.glassProminent` (SwiftUI, iOS 26)

- `.glass` — translucent, see-through; **secondary actions**.
- `.glassProminent` — opaque, no background show-through, tinted with app accent; **primary actions** (analogous to `.borderedProminent`).
- Default border shape: **`.capsule`** (per conorluddy reference: `// Default: .regular variant, .capsule shape` and `.buttonBorderShape(.capsule) // Default`).
URLs:
- https://apple-docs.everest.mt/docs/swiftui/primitivebuttonstyle/glassprominent/
- https://apple-docs.everest.mt/docs/swiftui/primitivebuttonstyle/glass(_:)/
- https://github.com/conorluddy/LiquidGlassReference

SwiftUI example (WWDC25-323):
```swift
Button("Get Started") { }.buttonStyle(.glassProminent)
Button("Learn More")  { }.buttonStyle(.glass)
```

## 3. Can the radius be customized? Yes.

Three independent mechanisms:

1. **`buttonBorderShape(_:)`** — affects `.bordered`, `.borderedProminent`, `.glass`, `.glassProminent` platter shape.
   - `.buttonBorderShape(.capsule)` — fully rounded (default).
   - `.buttonBorderShape(.roundedRectangle(radius: 8))` — discrete radius.
   - `.buttonBorderShape(.circle)` — circular.
   URLs:
   - https://apple-docs.everest.mt/docs/swiftui/view/buttonbordershape(_:)/
   - https://apple-docs.everest.mt/docs/swiftui/buttonbordershape/roundedrectangle(radius:)/
   - https://developer.apple.com/documentation/swiftui/shape/buttonborder

2. **`glassEffect(_:in:)`** shape parameter (for custom glass views, not the button styles themselves):
   - `.glassEffect(.regular, in: .capsule)` — default.
   - `.glassEffect(.regular, in: .rect(cornerRadius: 16))` — fixed radius.
   - `.glassEffect(.regular, in: .rect(cornerRadius: .containerConcentric))` — auto-matches parent (concentric).
   URL: https://swiftcrafted.dev/article/mastering-liquid-glass-swiftui-complete-guide-ios-26-design-language

3. **UIKit `UIGlassEffect.cornerConfiguration`** — `.fixed(8)`, `.containerRelative()`, capsule default.
   URL: https://developer.apple.com/videos/play/wwdc2025/284/

There is **no dedicated `buttonBorderRadius` modifier** — radius is chosen via `ButtonBorderShape`. `Shape.buttonBorder` resolves the shape from the environment (`buttonBorderShape` overrides it).

## 4. When RoundedRectangle with a discrete radius is correct

- **Nested/grouped content** — cards, List rows, GroupBox: use `RoundedRectangle` with a fixed or `.containerConcentric` radius so inner corners align with the rectangular parent (concentricity). A capsule inside a card breaks the system's rhythm.
- **macOS high-density inspectors** — `.mini` / `.small` / `.medium` `controlSize` retain rounded-rectangle to "preserve horizontal density" (WWDC25-323).
- **Vertical stacks of text-labeled buttons** — visionOS HIG: "prefer the rounded-rectangle shape in a vertical stack of buttons and prefer the capsule shape in a horizontal row of buttons." URL: https://apple-docs.everest.mt/docs/design/human-interface-guidelines/buttons/
- **Where horizontal density matters** — small controls near content (toolbars of dense lists).

## 5. HIG Buttons page — what it actually says

The HIG Buttons page (mirror) does NOT give an iOS-specific capsule-vs-rounded prescription for filled/prominent buttons. Its explicit shape guidance is:
- visionOS: "an icon-only button uses a circle shape, a text-only button uses a roundedRectangle or capsule shape, and a button that includes both an icon and text uses the capsule shape." "In general, prefer circular or capsule-shape buttons." "Prefer the rounded-rectangle shape in a vertical stack of buttons and prefer the capsule shape in a horizontal row of buttons."
- watchOS: "watchOS displays all inline buttons using the capsule button shape."
- Style (all platforms): "In general, use a button that has a prominent visual style for the most likely action in a view." "Use style — not size — to visually distinguish the preferred choice among multiple options."
- Change log: "December 16, 2025 — Updated guidance for Liquid Glass."
URL: https://apple-docs.everest.mt/docs/design/human-interface-guidelines/buttons/

The capsule-as-default for iOS comes from the WWDC25 sessions (323, 284, 356) and the SwiftUI `buttonBorderShape` default — not a verbatim line on the HIG Buttons page.

## 6. `.controlSize` effect on shape

- `controlSize` changes height/density, **not** the shape family by itself.
- But on **macOS**, `.mini` / `.small` / `.medium` controls retain **rounded-rectangle** by default; `.large` / `.extraLarge` use **capsule**. WWDC25-356: "Large and extra large use capsule shapes."
- New size in iOS 26: `.extraLarge` (for "your most important, prominent actions"). URL: https://developer.apple.com/videos/play/wwdc2025/323/
- `.buttonBorderShape` overrides shape for any size.

## 7. iOS 27 (WWDC26) refinements

No new button styles; refinements to existing Liquid Glass:
- **Liquid Glass opt-out removed** — `UIDesignRequiresCompatibility` no longer works; native components use Liquid Glass automatically. (conorluddy reference: "Temporary Opt-Out (expires iOS 27).")
- **More defined borders** — moved off drop shadows for distinguishability on white surfaces.
- **Lighter dark mode** — dark glass lighter; selected tab bar items now darker.
- **Transparency slider** — user-controlled, "ultra clear" → "fully tinted"; affects all apps automatically.
- **Better label contrast on `.glassProminent`** — default tint now gives better contrast out of the box (esp. against yellow/orange).
- **Scroll edge effect default** flipped from iOS 26's soft gradient blur to a "hard" blur with bottom border (use `.soft` to restore iOS 26 look).
- **macOS 27**: consistent corner radius; colored sidebar icons for active app.
URLs:
- https://designfornative.com/what-designers-need-to-know-about-ios-27/
- https://www.cultofmac.com/news/liquid-glass-changes-ios-27-macos-27
- https://9to5mac.com/2026/06/12/ios-27-fixes-liquid-glass-and-not-just-with-a-slider/

**No change to the capsule default** in iOS 27; the shape language carries forward.

## 8. Known quirks

- `.glassProminent` + `.buttonBorderShape(.circle)` has rendering artifacts; workaround `.clipShape(Circle())`. (conorluddy reference.)
- `.glassProminent` tint expansion had beta quirks in light mode (Natasha The Robot). URL: https://www.natashatherobot.com/p/liquidglass-button-ios-26

## Implication for Cosmos

- `CosmosButton` primary/prominent variant → default shape **capsule** (`RoundedRectangle(cornerRadius: .infinity)` is the SwiftUI-idiomatic form, clips to half-height). Expose a shape override via theme for grouped/card contexts.
- Secondary/tertiary → respect `buttonBorderShape` env; default capsule on iOS/watchOS/visionOS horizontal, rounded-rectangle in vertical stacks and macOS small densities.
- Map `CosmosTheme.buttonStyle.shape` (or a new `buttonShape` token) to `ButtonBorderShape` so consumers can opt into `.roundedRectangle(radius:)` or `.containerConcentric` for grouped content.
- Gate `.glass` / `.glassProminent` at `@available(iOS 26, *)` (Cosmos 26 baseline — no gate needed within baseline, but needed if the design-system supports an older floor pin via `CosmosTheme.version`).

## Sources

- WWDC25-323 Build a SwiftUI app with the new design — https://developer.apple.com/videos/play/wwdc2025/323/
- WWDC25-284 Build a UIKit app with the new design — https://developer.apple.com/videos/play/wwdc2025/284/
- WWDC25-356 Get to know the new design system (notes) — https://wwdcnotes.com/documentation/wwdc25-356-get-to-know-the-new-design-system/
- Adopting Liquid Glass — https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass
- HIG Buttons (mirror) — https://apple-docs.everest.mt/docs/design/human-interface-guidelines/buttons/
- ButtonStyle docs (mirror) — https://apple-docs.everest.mt/docs/swiftui/buttonstyle/
- glassProminent (mirror) — https://apple-docs.everest.mt/docs/swiftui/primitivebuttonstyle/glassprominent/
- glass(_:) (mirror) — https://apple-docs.everest.mt/docs/swiftui/primitivebuttonstyle/glass(_:)/
- buttonBorderShape(_:) (mirror) — https://apple-docs.everest.mt/docs/swiftui/view/buttonbordershape(_:)/
- roundedRectangle(radius:) (mirror) — https://apple-docs.everest.mt/docs/swiftui/buttonbordershape/roundedrectangle(radius:)/
- Shape.buttonBorder — https://developer.apple.com/documentation/swiftui/shape/buttonborder
- LiquidGlassReference (community) — https://github.com/conorluddy/LiquidGlassReference
- Liquid Glass SwiftUI guide — https://swiftcrafted.dev/article/mastering-liquid-glass-swiftui-complete-guide-ios-26-design-language
- Anatomy of a LiquidGlass Button — https://www.natashatherobot.com/p/liquidglass-button-ios-26
- iOS 27 designer guide — https://designfornative.com/what-designers-need-to-know-about-ios-27/
- Cult of Mac iOS 27 changes — https://www.cultofmac.com/news/liquid-glass-changes-ios-27-macos-27
- 9to5Mac iOS 27 fixes — https://9to5mac.com/2026/06/12/ios-27-fixes-liquid-glass-and-not-just-with-a-slider/