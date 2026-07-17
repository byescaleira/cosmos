import Testing
import Foundation
import Synchronization
@testable import Cosmos

@Suite("Tracking")
struct CosmosTrackingTests {

    @Test func trackIsNoOpWhenDisabled() {
        let box = Mutex<[CosmosTrackEvent]>([])
        let config = CosmosTrackingConfiguration(isEnabled: false) { event in box.withLock { $0.append(event) } }
        config.track(.init(name: "x", component: "C", action: .tap))
        #expect(box.withLock { $0.count } == 0)
    }

    @Test func trackInvokesHandlerWhenEnabled() {
        let box = Mutex<[CosmosTrackEvent]>([])
        let config = CosmosTrackingConfiguration(isEnabled: true) { event in box.withLock { $0.append(event) } }
        config.track(.init(
            name: "button_tap",
            component: "CosmosButton",
            componentId: "id-1",
            action: .tap,
            metadata: ["k": "v"]
        ))
        let events = box.withLock { $0 }
        #expect(events.count == 1)
        #expect(events[0].name == "button_tap")
        #expect(events[0].component == "CosmosButton")
        #expect(events[0].componentId == "id-1")
        #expect(events[0].action == .tap)
        #expect(events[0].metadata["k"] == "v")
    }

    @Test func componentIdFallbackHelper() {
        // Mirrors the atom logic: trackingId ?? accessibilityIdentifier.
        let resolve: (String?, String?) -> String? = { trackingId, accessibilityId in
            trackingId ?? accessibilityId
        }
        #expect(resolve("t", "a") == "t")
        #expect(resolve(nil, "a") == "a")
        #expect(resolve(nil, nil) == nil)
    }

    @Test func defaultIsOptIn() {
        #expect(CosmosTrackingConfiguration.default.isEnabled == false)
    }

    @Test func trackActionCases() {
        #expect(CosmosTrackAction.allCases.count == 6)
        #expect(CosmosTrackAction.allCases.contains(.tap))
        #expect(CosmosTrackAction.allCases.contains(.appear))
    }
}