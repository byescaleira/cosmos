import SwiftUI

/// Decides whether a haptic may fire, combining the haptics config with the
/// `accessibilityReduceMotion` environment gate.
public enum CosmosHapticsPolicy {
    public static func shouldEmit(isEnabled: Bool, respectReduceMotion: Bool, reduceMotion: Bool) -> Bool {
        isEnabled && (!respectReduceMotion || !reduceMotion)
    }
}

private extension CosmosHapticsWeight {
    /// Maps to `SensoryFeedback.Weight`, which only exposes `.light/.medium/.heavy`.
    var sensoryWeight: SensoryFeedback.Weight {
        switch self {
        case .light, .soft: return .light
        case .medium: return .medium
        case .heavy, .rigid: return .heavy
        }
    }
}

private extension CosmosHapticsFeedback {
    var sensoryFeedback: SensoryFeedback {
        switch self {
        case .impact(let weight, let intensity):
            return .impact(weight: weight.sensoryWeight, intensity: intensity ?? 1.0)
        case .selection: return .selection
        case .success: return .success
        case .warning: return .warning
        case .error: return .error
        }
    }
}

/// Attaches `.sensoryFeedback` gated by the haptics config and `accessibilityReduceMotion`,
/// and forwards the emission to the haptics handler (for tracking) when it fires.
private struct CosmosHapticFeedbackModifier<Trigger: Equatable & Sendable>: ViewModifier {
    let feedback: CosmosHapticsFeedback
    let trigger: Trigger
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ViewBuilder
    func body(content: Content) -> some View {
        if CosmosHapticsPolicy.shouldEmit(
            isEnabled: configuration.haptics.isEnabled,
            respectReduceMotion: configuration.haptics.respectReduceMotion,
            reduceMotion: reduceMotion
        ) {
            content
                .sensoryFeedback(feedback.sensoryFeedback, trigger: trigger)
                .onChange(of: trigger) { _, _ in
                    configuration.haptics.handler(feedback)
                }
        } else {
            content
        }
    }
}

extension View {
    /// Attaches a Cosmos haptic gated by the haptics configuration and Reduce Motion.
    /// `trigger` changes fire the feedback (and the tracking handler).
    public func cosmosHaptic<T: Equatable & Sendable>(_ feedback: CosmosHapticsFeedback, trigger: T) -> some View {
        modifier(CosmosHapticFeedbackModifier(feedback: feedback, trigger: trigger))
    }
}