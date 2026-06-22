import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosStepperViewTests {

    @Test func stepperRendersDoubleStepper() throws {
        let view = CosmosStepper(value: .constant(5), in: 0...10)
        let stepper = try view.inspect().anyView().stepper()
        #expect(!stepper.isAbsent)
    }

    @Test func stepperRendersIntStepper() throws {
        let view = CosmosStepper(value: .constant(5), in: 0...10, step: 1)
        let stepper = try view.inspect().anyView().stepper()
        #expect(!stepper.isAbsent)
    }

    @Test func stepperRendersLabel() throws {
        let view = CosmosStepper(value: .constant(5), in: 0...10, "quantity")
        let stepper = try view.inspect().anyView().stepper()
        let label = try stepper.labelView().text().string()
        #expect(label == "quantity")
    }

    @Test func stepperIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosStepper(value: .constant(5), in: 0...10)
            .environment(\.cosmosConfiguration, configuration)

        let stepper = try view.inspect().anyView().stepper()
        #expect(!stepper.isAbsent)
    }
}
