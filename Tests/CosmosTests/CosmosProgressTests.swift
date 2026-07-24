import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosProgress")
struct CosmosProgressTests {

    // MARK: - Construction (per-init construction smoke)

    @Test func progressConstructsIndeterminate() {
        _ = CosmosProgress()
    }

    @Test func progressConstructsIndeterminateWithLabel() {
        _ = CosmosProgress { Text(verbatim: "Loading") }
    }

    @Test func progressConstructsFromLocalizedTitleKey() {
        _ = CosmosProgress("preview.title")
    }

    @Test func progressConstructsDeterminateWithValue() {
        _ = CosmosProgress(value: 0.5)
    }

    @Test func progressConstructsDeterminateWithValueAndLabel() {
        _ = CosmosProgress(value: 0.5, total: 1.0) { Text(verbatim: "Half") }
    }

    @Test func progressConstructsDeterminateFromLocalizedKey() {
        _ = CosmosProgress("preview.title", value: 0.5)
    }

    @Test(.tags(.selector), arguments: CosmosProgressStyle.allCases)
    func progressAcceptsEveryStyleVariant(_ style: CosmosProgressStyle) {
        _ = CosmosProgress().cosmosProgressStyle(style)
    }

    // MARK: - Style selector enum

    @Test func progressStyleAllCases() {
        #expect(CosmosProgressStyle.allCases == [.automatic, .circular, .linear, .cosmos])
    }

    // MARK: - CosmosProgressAccessibility (pure determinate/indeterminate branch logic)

    @Test func progressIsIndeterminateWhenFractionNil() {
        #expect(CosmosProgressAccessibility.isIndeterminate(fractionCompleted: nil) == true)
        #expect(CosmosProgressAccessibility.isIndeterminate(fractionCompleted: 0.0) == false)
        #expect(CosmosProgressAccessibility.isIndeterminate(fractionCompleted: 0.5) == false)
        #expect(CosmosProgressAccessibility.isIndeterminate(fractionCompleted: 1.0) == false)
    }

    @Test func progressValueStringEmptyForIndeterminate() {
        // The native spinner owns its own value; the custom chrome emits no value for indeterminate.
        #expect(CosmosProgressAccessibility.valueString(fractionCompleted: nil) == "")
    }

    @Test func progressValueStringClampsAndRounds() {
        #expect(CosmosProgressAccessibility.valueString(fractionCompleted: 0.0) == "0%")
        #expect(CosmosProgressAccessibility.valueString(fractionCompleted: 0.454) == "45%")
        #expect(CosmosProgressAccessibility.valueString(fractionCompleted: 1.0) == "100%")
        // Clamped to [0, 1].
        #expect(CosmosProgressAccessibility.valueString(fractionCompleted: 1.5) == "100%")
        #expect(CosmosProgressAccessibility.valueString(fractionCompleted: -0.25) == "0%")
    }
}