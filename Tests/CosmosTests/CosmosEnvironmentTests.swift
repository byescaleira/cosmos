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
}