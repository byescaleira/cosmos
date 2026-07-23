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
/// unset value never silences VoiceOver's fallback. Of the SwiftUI environment gates, only
/// `accessibilityReduceMotion` and `accessibilityReduceTransparency` are currently read in
/// atoms/modifiers (the latter via `CosmosMotionPolicy.shouldCollapseTransparency`); the
/// increased-contrast / differentiate-without-color / button-shapes gates are not yet wired
/// here (tracked gap — see the vault risks index). High-contrast color variants are surfaced
/// through an asset catalog at the app layer.
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

    public init(
        label: String? = nil,
        hint: String? = nil,
        value: String? = nil,
        identifier: String? = nil,
        traits: AccessibilityTraits = [],
        isHidden: Bool = false,
        sortPriority: Double? = nil,
        customContent: [CosmosAccessibilityCustomContent] = [],
        respondsToUserInteraction: Bool? = nil
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
    }

    public static let `default` = CosmosAccessibilityConfiguration()
}