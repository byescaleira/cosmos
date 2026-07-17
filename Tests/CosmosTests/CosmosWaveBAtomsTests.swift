import Testing
import Foundation
@testable import Cosmos

@Suite("Wave B Atoms")
struct CosmosWaveBAtomsTests {

    // MARK: - CosmosOpenURLResolution

    @Test func openURLResolutionAllCases() {
        #expect(CosmosOpenURLResolution.allCases == [.handled, .systemAction, .discarded])
    }

    @Test func openURLResolutionRawValuesAreStable() {
        // Raw values are persisted as tracking metadata, so they are part of the contract.
        #expect(CosmosOpenURLResolution.handled.rawValue == "handled")
        #expect(CosmosOpenURLResolution.systemAction.rawValue == "systemAction")
        #expect(CosmosOpenURLResolution.discarded.rawValue == "discarded")
    }

    // MARK: - CosmosOpenURLRouting.resolve (pure URL → resolution)

    @Test func openURLResolutionHandledWhenInApp() {
        // Predicate accepts the URL → routed in-app, not handed to the system.
        let url = URL(string: "cosmos://about")!
        #expect(CosmosOpenURLRouting.resolve(url: url, inApp: { _ in true }) == .handled)
    }

    @Test func openURLResolutionSystemActionWhenNotInApp() {
        // Predicate rejects the URL → falls back to the system.
        let url = URL(string: "https://example.com")!
        #expect(CosmosOpenURLRouting.resolve(url: url, inApp: { _ in false }) == .systemAction)
    }

    @Test func openURLRoutingPredicateReceivesExactUrl() {
        // The predicate must receive the exact URL being opened (no normalization/mutation): it
        // returns true only when the opened URL equals the input, and routing reflects that.
        let url = URL(string: "https://example.com/path?x=1")!
        #expect(CosmosOpenURLRouting.resolve(url: url, inApp: { opened in opened == url }) == .handled)
        // A different URL would be rejected by that same exact-match predicate.
        #expect(CosmosOpenURLRouting.resolve(url: url, inApp: { opened in opened == URL(string: "https://other.com")! }) == .systemAction)
    }

    @Test func openURLRoutingRoutesByScheme() {
        // A realistic predicate: route deep links in-app, everything else to the system.
        let inApp: @Sendable (URL) -> Bool = { $0.scheme == "cosmos" }
        #expect(CosmosOpenURLRouting.resolve(url: URL(string: "cosmos://settings")!, inApp: inApp) == .handled)
        #expect(CosmosOpenURLRouting.resolve(url: URL(string: "https://example.com")!, inApp: inApp) == .systemAction)
        #expect(CosmosOpenURLRouting.resolve(url: URL(string: "mailto:a@b.com")!, inApp: inApp) == .systemAction)
    }

    @Test func openURLResolutionIsDeterministic() {
        // Same inputs always yield the same resolution (pure function — no hidden state).
        let url = URL(string: "https://example.com")!
        let a = CosmosOpenURLRouting.resolve(url: url, inApp: { _ in true })
        let b = CosmosOpenURLRouting.resolve(url: url, inApp: { _ in true })
        #expect(a == b)
    }
}