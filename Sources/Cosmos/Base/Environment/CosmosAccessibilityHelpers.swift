import SwiftUI

/// Decides whether the increased-contrast / differentiate-without-color / show-borders
/// accessibility gates may apply, combining the relevant `respect*` flag on
/// ``CosmosAccessibilityConfiguration`` with the matching environment gate. Mirrors
/// ``CosmosMotionPolicy`` — the single chokepoint every atom routes these gates through,
/// so `respect* = false` can intentionally override (never the bare env value).
public enum CosmosAccessibilityPolicy {
    /// Whether increased contrast should drive adaptive surface/outline strengthening.
    public static func shouldIncreaseContrast(
        respectIncreaseContrast: Bool,
        contrast: ColorSchemeContrast
    ) -> Bool {
        contrast == .increased && respectIncreaseContrast
    }

    /// Whether the UI must stop conveying information by color alone (use shape/symbol/text instead).
    public static func shouldDifferentiateWithoutColor(
        respectDifferentiateWithoutColor: Bool,
        differentiateWithoutColor: Bool
    ) -> Bool {
        differentiateWithoutColor && respectDifferentiateWithoutColor
    }

    /// Whether interactive controls should draw a visible border/shape. (`accessibilityShowBorders`
    /// on iOS 26 — née `accessibilityShowButtonShapes`; on macOS true when Increased Contrast is on.)
    public static func shouldShowBorders(
        respectShowBorders: Bool,
        showBorders: Bool
    ) -> Bool {
        showBorders && respectShowBorders
    }
}

/// Internal helpers that apply SwiftUI accessibility modifiers only when an override is
/// present, so an unset value never silences VoiceOver's native fallback. Atoms use these
/// after resolving values from ``CosmosAccessibilityConfiguration``.

extension View {
    @ViewBuilder func accessibilityLabelOrNil(_ label: String?) -> some View {
        if let label { accessibilityLabel(label) } else { self }
    }

    @ViewBuilder func accessibilityHintOrNil(_ hint: String?) -> some View {
        if let hint { accessibilityHint(hint) } else { self }
    }

    @ViewBuilder func accessibilityValueOrNil(_ value: String?) -> some View {
        if let value { accessibilityValue(value) } else { self }
    }

    @ViewBuilder func accessibilityIdentifierOrNil(_ id: String?) -> some View {
        if let id { accessibilityIdentifier(id) } else { self }
    }

    @ViewBuilder func accessibilitySortPriorityOrNil(_ priority: Double?) -> some View {
        if let priority { accessibilitySortPriority(priority) } else { self }
    }

    @ViewBuilder func accessibilityHiddenIf(_ hidden: Bool) -> some View {
        if hidden { accessibilityHidden(true) } else { self }
    }

    @ViewBuilder func accessibilityTraitsIfPresent(_ traits: AccessibilityTraits) -> some View {
        if traits.isEmpty { self } else { accessibilityAddTraits(traits) }
    }

    /// Folds custom content entries into the element, skipping when empty.
    ///
    /// `AnyView` is retained here as a **documented compiler-limit carve-out** (analogous to the
    /// `cosmosPreviewVariant` case): the identity-preserving alternative — a recursive generic
    /// `View` struct applying one `accessibilityCustomContent` per level — does not compile, because
    /// an unqualified recursive reference to the enclosing generic type reuses the same `Base` type
    /// parameter (Swift avoids infinite type recursion), so neither direct recursion nor an
    /// opaque-parameter boundary can bind a fresh `Base` per level. The `AnyView`-free form is
    /// therefore unexpressible in Swift today. The cost here is negligible in practice: custom
    /// content attaches accessibility *metadata* (not a diffable view subtree), so structural
    /// identity across re-renders is not at stake the way it is for visible content. performance.md
    /// allows `AnyView` "unless absolutely required" — this is that case.
    @ViewBuilder func accessibilityCustomContentIfPresent(_ content: [CosmosAccessibilityCustomContent]) -> some View {
        if content.isEmpty {
            self
        } else {
            AnyView(content.reduce(into: AnyView(self)) { acc, item in
                acc = AnyView(acc.accessibilityCustomContent(Text(item.label), Text(item.value ?? "")))
            })
        }
    }
}