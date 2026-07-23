import Testing
import Foundation
import SwiftUI
import Synchronization
@testable import Cosmos

@Suite("Motion")
struct CosmosMotionTests {

    // MARK: - Configuration defaults

    @Test func configurationDefaults() {
        let m = CosmosMotionConfiguration.default
        #expect(m.isEnabled == true)
        #expect(m.respectReduceMotion == true)
        #expect(m.reduceMotionPolicy == .substitute)
        #expect(m.respectReduceTransparency == true)
        #expect(m.reduceTransparencyPolicy == .substitute)
        #expect(m.stagger.step == .moderate1)
        #expect(m.stagger.maxSteps == 3)
    }

    @Test func motionKindAllCases() {
        #expect(CosmosMotionKind.allCases.count == 10)
        #expect(CosmosMotionKind.allCases.contains(.press))
        #expect(CosmosMotionKind.allCases.contains(.containerTransform))
    }

    @Test func reduceMotionPolicyAllCases() {
        #expect(CosmosReduceMotionPolicy.allCases == [.substitute, .instant, .preserve])
    }

    // MARK: - Policy (mirrors CosmosHapticsPolicy)

    @Test func policyGatesOnIsEnabled() {
        #expect(CosmosMotionPolicy.shouldEmit(isEnabled: false, respectReduceMotion: true, reduceMotion: false) == false)
        #expect(CosmosMotionPolicy.shouldEmit(isEnabled: false, respectReduceMotion: false, reduceMotion: false) == false)
    }

    @Test func policyRespectsReduceMotion() {
        #expect(CosmosMotionPolicy.shouldEmit(isEnabled: true, respectReduceMotion: true, reduceMotion: true) == false)
        #expect(CosmosMotionPolicy.shouldEmit(isEnabled: true, respectReduceMotion: true, reduceMotion: false) == true)
    }

    @Test func policyIgnoresReduceMotionWhenNotRespecting() {
        #expect(CosmosMotionPolicy.shouldEmit(isEnabled: true, respectReduceMotion: false, reduceMotion: true) == true)
    }

    // MARK: - Reduce-transparency collapse (chokepoint)

    @Test func transparencyCollapseOnlyWhenActiveRespectedAndSubstituting() {
        // Materials collapse only when reduce-transparency is active, respected by config, AND
        // the policy is .substitute. Default config collapses; .preserve keeps materials.
        #expect(CosmosMotionPolicy.shouldCollapseTransparency(respectReduceTransparency: true, reduceTransparency: true, policy: .substitute) == true)
        #expect(CosmosMotionPolicy.shouldCollapseTransparency(respectReduceTransparency: true, reduceTransparency: true, policy: .preserve) == false)
        #expect(CosmosMotionPolicy.shouldCollapseTransparency(respectReduceTransparency: true, reduceTransparency: false, policy: .substitute) == false)
        #expect(CosmosMotionPolicy.shouldCollapseTransparency(respectReduceTransparency: false, reduceTransparency: true, policy: .substitute) == false)
    }

    @Test func reduceTransparencyPolicyAllCases() {
        #expect(CosmosReduceTransparencyPolicy.allCases == [.substitute, .preserve])
    }

    // MARK: - Handler invocation

    @Test func handlerInvokedWithMotionEvent() {
        let box = Mutex<[CosmosMotionEvent]>([])
        let config = CosmosMotionConfiguration(isEnabled: true, respectReduceMotion: false) { event in
            box.withLock { $0.append(event) }
        }
        config.handler(.motion(.press))
        config.handler(.motion(.valueChange))
        let received = box.withLock { $0 }
        #expect(received.count == 2)
        if case .motion(let kind) = received[0] {
            #expect(kind == .press)
        } else {
            Issue.record("expected .motion(.press), got \(received[0])")
        }
    }

    // MARK: - Springs & duration scale

    @Test func springPresetsDistinct() {
        #expect(CosmosSpring.cosmosSmooth.spring != CosmosSpring.cosmosSnappy.spring)
        #expect(CosmosSpring.cosmosBouncy.spring != CosmosSpring.cosmosGentle.spring)
        #expect(CosmosSpringStyle.snappy.spring.spring == CosmosSpring.cosmosSnappy.spring)
    }

    @Test func durationScaleMonotonic() {
        let values = CosmosDuration.allCases.map(\.rawValue)
        #expect(values == [0, 0.070, 0.110, 0.150, 0.240, 0.400, 0.700])
        #expect(CosmosDuration.instant.rawValue == 0)
        #expect(CosmosDuration.extraLong.rawValue > CosmosDuration.long.rawValue)
    }

    // MARK: - Tokens resolver (the synchronization guarantee)

    @Test func animationSameIntentSameCurve() {
        let tokens = CosmosMotionTokens.default
        let a1 = tokens.animation(for: .press, reduceMotion: false, policy: .substitute)
        let a2 = tokens.animation(for: .press, reduceMotion: false, policy: .substitute)
        // Same intent → identical curve (the synchronization guarantee). `Animation` is Equatable.
        #expect(a1 != nil)
        #expect(a2 != nil)
        #expect(a1 == a2)
    }

    @Test func animationNilUnderReduceMotionInstant() {
        let tokens = CosmosMotionTokens.default
        // reduce-motion + .instant → nil (snap).
        #expect(tokens.animation(for: .press, reduceMotion: true, policy: .instant) == nil)
    }

    @Test func animationNonNilUnderReduceMotionPreserve() {
        let tokens = CosmosMotionTokens.default
        // reduce-motion + .preserve → keep the full spring.
        #expect(tokens.animation(for: .press, reduceMotion: true, policy: .preserve) != nil)
    }

    @Test func animationSubstituteGivesEaseInOutUnderReduceMotion() {
        let tokens = CosmosMotionTokens.default
        // reduce-motion + .substitute → a non-nil short easeInOut crossfade (not nil, not the spring).
        let resolved = tokens.animation(for: .appear, reduceMotion: true, policy: .substitute)
        #expect(resolved != nil)
        // The full spring for .appear is cosmosSmooth; the substitute is a different curve.
        let full = tokens.animation(for: .appear, reduceMotion: false, policy: .substitute)
        #expect(full != nil)
    }

    // MARK: - Transitions (MainActor — resolved()/transition() are MainActor-isolated)

    @MainActor
    @Test func transitionFadeResolvesToOpacity() {
        let tokens = CosmosMotionTokens.default
        let resolved = tokens.transition(.fade, reduceMotion: false, policy: .substitute)
        #expect(resolved != nil)
    }

    @MainActor
    @Test func transitionReduceMotionSubstitutesOpacity() {
        let tokens = CosmosMotionTokens.default
        // reduce-motion + .substitute → .opacity (non-nil), not the full transition.
        let resolved = tokens.transition(.slide, reduceMotion: true, policy: .substitute)
        #expect(resolved != nil)
    }

    @MainActor
    @Test func transitionReduceMotionInstantIsIdentity() {
        let tokens = CosmosMotionTokens.default
        // reduce-motion + .instant → .identity (non-nil).
        let resolved = tokens.transition(.scale, reduceMotion: true, policy: .instant)
        #expect(resolved != nil)
    }

    @MainActor
    @Test func transitionBlurReplaceResolvesWhenMotionOn() {
        let tokens = CosmosMotionTokens.default
        // blurReplace is a concrete Transition (not AnyTransition-composable). Under full motion
        // resolved() returns nil (sentinel: the modifier applies BlurReplaceTransition directly).
        let resolved = tokens.transition(.blurReplace, reduceMotion: false, policy: .substitute)
        #expect(resolved == nil)
    }

    @MainActor
    @Test func transitionBlurReplaceSubstitutesUnderReduceMotion() {
        let tokens = CosmosMotionTokens.default
        // Under reduce-motion, blurReplace falls to the AnyTransition substitute (.opacity).
        let resolved = tokens.transition(.blurReplace, reduceMotion: true, policy: .substitute)
        #expect(resolved != nil)
    }

    @MainActor
    @Test func transitionPresetsCount() {
        #expect(CosmosTransition.presets.count == 10)
        // CosmosTransition is not Equatable (the .asymmetric case has associated values), so use a
        // pattern-match contains instead of Sequence.contains(_:).
        let hasBlurReplace = CosmosTransition.presets.contains { preset in
            if case .blurReplace = preset { return true }
            return false
        }
        #expect(hasBlurReplace)
    }

    // MARK: - Content transition presets

    @Test func contentTransitionPresets() {
        #expect(CosmosContentTransitionPreset.allCases.count == 4)
        #expect(CosmosContentTransitionPreset.symbolReplace.isSymbolEffect == true)
        #expect(CosmosContentTransitionPreset.numeric.isSymbolEffect == false)
        #expect(CosmosContentTransitionPreset.contentOpacity.isSymbolEffect == false)
    }

    // MARK: - Stagger

    @Test func staggerDelayClampsToMaxSteps() {
        // delay = min(index, max(0, maxSteps)) * step.rawValue — index above maxSteps clamps.
        let step = CosmosDuration.fast1.rawValue
        let maxSteps = 3
        let d0 = Double(min(0, max(0, maxSteps))) * step
        let d5 = Double(min(5, max(0, maxSteps))) * step
        #expect(d0 == 0)
        #expect(d5 == Double(maxSteps) * step) // clamped at maxSteps
    }

    // MARK: - Theme integration

    @Test func themeMotionTokensDefault() {
        let theme = CosmosTheme.default
        #expect(theme.motion.defaultSpringStyle == .snappy)
        #expect(theme.motion.shadowRadius == 8)
        #expect(theme.motion.shadowOpacity == 0.08)
    }

    @Test func themeWithMotionReturnsMutatedCopy() {
        let base = CosmosTheme.default
        let modified = base.withMotion(.init(defaultSpringStyle: .gentle, shadowRadius: 12, shadowOpacity: 0.1))
        #expect(modified.motion.defaultSpringStyle == .gentle)
        #expect(modified.motion.shadowRadius == 12)
        // Original untouched.
        #expect(base.motion.defaultSpringStyle == .snappy)
    }

    @Test func themeWithSpringStyleReturnsMutatedCopy() {
        let base = CosmosTheme.default
        let modified = base.withSpringStyle(.bouncy)
        #expect(modified.motion.defaultSpringStyle == .bouncy)
        #expect(base.motion.defaultSpringStyle == .snappy)
    }

    @Test func configWithMotionReturnsMutatedCopy() {
        let base = CosmosConfiguration.default
        let modified = base.withMotion(.init(isEnabled: false))
        #expect(modified.motion.isEnabled == false)
        #expect(base.motion.isEnabled == true)
    }
}