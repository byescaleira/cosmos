import Testing
import Foundation
@testable import Cosmos

@Suite("Configuration")
struct CosmosConfigurationTests {

    @Test func subContractDefaults() {
        let c = CosmosConfiguration.default
        #expect(c.enable.isEnabled == true)
        #expect(c.enable.isVisible == true)
        #expect(c.enable.isReadOnly == false)
        #expect(c.loading.isLoading == false)
        #expect(c.haptics.isEnabled == true)
        #expect(c.haptics.respectReduceMotion == true)
        #expect(c.tracking.isEnabled == false, "tracking is opt-in/passive by default")
        #expect(c.log.isEnabled == true)
    }

    @Test func fluentBuilders() {
        let c = CosmosConfiguration.default
        #expect(c.withEnable(.init(isEnabled: false)).enable.isEnabled == false)
        #expect(c.withLoading(.init(isLoading: true)).loading.isLoading == true)
        #expect(c.withHaptics(.init(isEnabled: false)).haptics.isEnabled == false)
        #expect(c.withTracking(.init(isEnabled: true)).tracking.isEnabled == true)
    }

    @Test func fluentDoesNotMutateOriginal() {
        let c = CosmosConfiguration.default
        _ = c.withEnable(.init(isEnabled: false))
        #expect(c.enable.isEnabled == true)
    }
}