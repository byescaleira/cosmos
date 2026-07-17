import CoreGraphics
import Foundation

/// Impact weights mapped to `SensoryFeedback` impact parameters.
public enum CosmosHapticsWeight: String, Sendable, Codable, CaseIterable {
    case light
    case medium
    case heavy
    case soft
    case rigid
}

/// A haptic feedback emission, for tracking/logging when a haptic fires.
public enum CosmosHapticsFeedback: Sendable {
    case impact(weight: CosmosHapticsWeight, intensity: Double?)
    case selection
    case success
    case warning
    case error

    /// Convenience: impact with default intensity.
    public static func impact(weight: CosmosHapticsWeight) -> CosmosHapticsFeedback {
        .impact(weight: weight, intensity: nil)
    }
}

/// Haptics contract.
///
/// Atoms attach `.sensoryFeedback(...)` (SwiftUI, iOS 17+ — UIKit-free, compiles on all 5
/// platforms, no-op where no haptic hardware) gated by `isEnabled` and `respectReduceMotion`.
/// `handler` is `@Sendable` and is invoked *in addition to* the physical feedback when a
/// haptic fires, so consumers can track haptic usage. Passive by default (handler no-op).
public struct CosmosHapticsConfiguration: Sendable {
    /// Whether haptics may fire at all.
    public var isEnabled: Bool
    /// When true, suppresses haptics if `accessibilityReduceMotion` is active.
    public var respectReduceMotion: Bool
    /// Invoked when a haptic fires (for tracking). `@Sendable` (SE-0302).
    public var handler: @Sendable (CosmosHapticsFeedback) -> Void

    public init(
        isEnabled: Bool = true,
        respectReduceMotion: Bool = true,
        handler: @escaping @Sendable (CosmosHapticsFeedback) -> Void = { _ in }
    ) {
        self.isEnabled = isEnabled
        self.respectReduceMotion = respectReduceMotion
        self.handler = handler
    }

    public static let `default` = CosmosHapticsConfiguration()
}