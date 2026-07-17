import Testing
import Foundation
import SwiftUI
@testable import Cosmos

@Suite("Environment")
struct CosmosEnvironmentTests {

    @Test func trackingIdDefaultsToNil() {
        // `@Entry` defaults are computed (nonisolated) — safe to read from a bare EnvironmentValues.
        let values = EnvironmentValues()
        #expect(values.cosmosTrackingId == nil)
    }

    @Test func themeDefaultsMatchCosmosThemeDefault() {
        let values = EnvironmentValues()
        #expect(values.cosmosTheme.textStyle == CosmosTheme.default.textStyle)
        #expect(values.cosmosTheme.buttonStyle == CosmosTheme.default.buttonStyle)
        #expect(values.cosmosTheme.version == CosmosVersion.current)
    }

    @Test func configurationDefaultsMatchCosmosConfigurationDefault() {
        let values = EnvironmentValues()
        #expect(values.cosmosConfiguration.tracking.isEnabled == CosmosConfiguration.default.tracking.isEnabled)
        #expect(values.cosmosConfiguration.enable.isEnabled == true)
    }

    @Test func fontRegistrationIsIdempotent() {
        // Calling repeatedly from the test (any thread) must not crash and must stay a no-op.
        CosmosFont.registerIfNeeded()
        CosmosFont.registerIfNeeded()
        #expect(CosmosFont.bundledFontURLs().count >= 1, "expected bundled .ttf fonts")
    }
}