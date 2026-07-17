import Testing
import Foundation
import Synchronization
@testable import Cosmos

@Suite("Haptics")
struct CosmosHapticsTests {

    @Test func policyGatesOnIsEnabled() {
        #expect(CosmosHapticsPolicy.shouldEmit(isEnabled: false, respectReduceMotion: true, reduceMotion: false) == false)
        #expect(CosmosHapticsPolicy.shouldEmit(isEnabled: false, respectReduceMotion: false, reduceMotion: false) == false)
    }

    @Test func policyRespectsReduceMotion() {
        #expect(CosmosHapticsPolicy.shouldEmit(isEnabled: true, respectReduceMotion: true, reduceMotion: true) == false)
        #expect(CosmosHapticsPolicy.shouldEmit(isEnabled: true, respectReduceMotion: true, reduceMotion: false) == true)
    }

    @Test func policyIgnoresReduceMotionWhenNotRespecting() {
        #expect(CosmosHapticsPolicy.shouldEmit(isEnabled: true, respectReduceMotion: false, reduceMotion: true) == true)
    }

    @Test func impactFactoryDefaultsIntensityToNil() {
        if case .impact(let weight, let intensity) = CosmosHapticsFeedback.impact(weight: .light) {
            #expect(weight == .light)
            #expect(intensity == nil)
        } else {
            Issue.record("expected impact feedback")
        }
    }

    @Test func handlerInvokedWhenEmitting() {
        let box = Mutex<[CosmosHapticsFeedback]>([])
        let config = CosmosHapticsConfiguration(isEnabled: true, respectReduceMotion: false) { feedback in box.withLock { $0.append(feedback) } }
        config.handler(.selection)
        config.handler(.impact(weight: .heavy, intensity: 0.5))
        let received = box.withLock { $0 }
        #expect(received.count == 2)
        if case .selection = received[0] {
            // ok
        } else {
            Issue.record("expected .selection feedback, got \(received[0])")
        }
        if case .impact(let weight, _) = received[1] {
            #expect(weight == .heavy)
        } else {
            Issue.record("expected .impact feedback, got \(received[1])")
        }
    }

    @Test func configDefaults() {
        let config = CosmosHapticsConfiguration.default
        #expect(config.isEnabled == true)
        #expect(config.respectReduceMotion == true)
    }
}