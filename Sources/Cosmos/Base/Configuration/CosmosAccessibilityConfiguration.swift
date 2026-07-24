import SwiftUI

/// A piece of custom accessibility content (rendered by VoiceOver beyond label/value).
public struct CosmosAccessibilityCustomContent: Sendable {
    public var label: String
    public var value: String?

    public init(label: String, value: String? = nil) {
        self.label = label
        self.value = value
    }
}

/// Accessibility contract.
///
/// Atoms apply these only when non-nil (via the `cosmosAccessibility*` helpers), so an
/// unset value never silences VoiceOver's fallback. The SwiftUI environment gates are
/// routed through ``CosmosAccessibilityPolicy`` (the chokepoint mirroring
/// ``CosmosMotionPolicy``) plus the `respect*` flags below, so each gate can be
/// intentionally overridden:
/// - `accessibilityReduceMotion` / `accessibilityReduceTransparency` — wired through
///   ``CosmosMotionPolicy`` (`shouldEmit` / `shouldCollapseTransparency`).
/// - `accessibilityDifferentiateWithoutColor` — wired through
///   ``CosmosAccessibilityPolicy/shouldDifferentiateWithoutColor(respectDifferentiateWithoutColor:differentiateWithoutColor:)``
///   (e.g. ``CosmosToastContent`` falls to a monochrome, shape-only icon when active).
/// - `accessibilityShowBorders` — wired through
///   ``CosmosAccessibilityPolicy/shouldShowBorders(respectShowBorders:showBorders:)``: the
///   borderless `.ghost` button draws a capsule outline when the gate is on (see
///   ``CosmosButton``). High-contrast `colorSchemeContrast` variants are surfaced through an
///   asset catalog at the app layer.
///
/// `AccessibilityTraits` and `AccessibilityCustomContentImportance` are SwiftUI `Sendable`
/// types, so this struct is `Sendable` (SE-0302).
public struct CosmosAccessibilityConfiguration: Sendable {
    public var label: String?
    public var hint: String?
    public var value: String?
    public var identifier: String?
    public var traits: AccessibilityTraits
    public var isHidden: Bool
    public var sortPriority: Double?
    public var customContent: [CosmosAccessibilityCustomContent]
    public var respondsToUserInteraction: Bool?
    /// When true, strengthens synthetic low-contrast surfaces/outlines if
    /// `accessibilityReduceTransparency`-style increased contrast (`colorSchemeContrast`) is
    /// active. Default `true` (mirror `CosmosMotionConfiguration.respectReduceMotion`).
    public var respectIncreaseContrast: Bool
    /// When true, stops conveying information by color alone if
    /// `accessibilityDifferentiateWithoutColor` is active. Default `true`.
    public var respectDifferentiateWithoutColor: Bool
    /// When true, draws a visible border on borderless controls if `accessibilityShowBorders`
    /// (née `accessibilityShowButtonShapes`) is active. Default `true`.
    public var respectShowBorders: Bool

    public init(
        label: String? = nil,
        hint: String? = nil,
        value: String? = nil,
        identifier: String? = nil,
        traits: AccessibilityTraits = [],
        isHidden: Bool = false,
        sortPriority: Double? = nil,
        customContent: [CosmosAccessibilityCustomContent] = [],
        respondsToUserInteraction: Bool? = nil,
        respectIncreaseContrast: Bool = true,
        respectDifferentiateWithoutColor: Bool = true,
        respectShowBorders: Bool = true
    ) {
        self.label = label
        self.hint = hint
        self.value = value
        self.identifier = identifier
        self.traits = traits
        self.isHidden = isHidden
        self.sortPriority = sortPriority
        self.customContent = customContent
        self.respondsToUserInteraction = respondsToUserInteraction
        self.respectIncreaseContrast = respectIncreaseContrast
        self.respectDifferentiateWithoutColor = respectDifferentiateWithoutColor
        self.respectShowBorders = respectShowBorders
    }

    public static let `default` = CosmosAccessibilityConfiguration()
}