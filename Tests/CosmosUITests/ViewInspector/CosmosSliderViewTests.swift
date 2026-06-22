import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosSliderViewTests {

    @Test func sliderRendersSlider() throws {
        let view = CosmosSlider(value: .constant(0.5))
        let slider = try view.inspect().slider()
        #expect(!slider.isAbsent)
    }

    @Test func sliderRendersWithStep() throws {
        let view = CosmosSlider(value: .constant(5), in: 0...10, step: 1)
        let slider = try view.inspect().slider()
        #expect(!slider.isAbsent)
    }

    @Test func sliderIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosSlider(value: .constant(0.5))
            .environment(\.cosmosConfiguration, configuration)

        let slider = try view.inspect().slider()
        #expect(!slider.isAbsent)
    }
}
