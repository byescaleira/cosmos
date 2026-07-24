import Testing
import Foundation
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosDatePicker")
struct CosmosDatePickerTests {

    // MARK: - Construction (gated off tvOS — DatePicker type unavailable there)

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func datePickerConstructsFromLocalizedKey() {
        _ = CosmosDatePicker("preview.title", selection: .constant(Date()))
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func datePickerConstructsFromVerbatimTitle() {
        _ = CosmosDatePicker(verbatim: "Pick a date", selection: .constant(Date()))
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func datePickerConstructsWithCustomLabelAndComponents() {
        _ = CosmosDatePicker(selection: .constant(Date()), displayedComponents: .date) { Text(verbatim: "When") }
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func datePickerConstructsWithClosedRange() {
        let range = Date()...Date().addingTimeInterval(3600)
        _ = CosmosDatePicker(selection: .constant(Date()), in: range) { Text(verbatim: "In range") }
    }

    @Test(.disabled(if: isTvOS), .tags(.availability, .selector), arguments: CosmosDatePickerStyle.allCases)
    func datePickerAcceptsEveryStyleVariant(_ style: CosmosDatePickerStyle) {
        _ = CosmosDatePicker("preview.title", selection: .constant(Date())).cosmosDatePickerStyle(style)
    }

    // MARK: - Style selector enum

    @Test func datePickerStyleAllCases() {
        #expect(CosmosDatePickerStyle.allCases == [
            .automatic, .wheel, .graphical, .compact, .field, .stepperField
        ])
    }

    // MARK: - CosmosDatePickerAvailability (full style × platform matrix)
    //
    // Parameterized over (style, platform) so the whole 6×5 matrix is asserted in one test on any
    // host. `DatePicker` is type-level unavailable on tvOS (every style false); `.field` and
    // `.stepperField` are macOS-only; `.wheel` is macOS-unavailable; `.graphical`/`.compact` are
    // watchOS-unavailable. `automatic` is available everywhere except tvOS.

    @Test(.tags(.selector), arguments: CosmosDatePickerStyle.allCases, CosmosPlatform.allCases)
    func datePickerAvailabilityMatrix(_ style: CosmosDatePickerStyle, on platform: CosmosPlatform) {
        let expected: Bool
        switch (style, platform) {
        case (.field, .macos), (.stepperField, .macos):
            expected = true // field/stepperField are macOS-only
        case (_, .tvos):
            expected = false // DatePicker unavailable on tvOS for every style
        case (.automatic, _):
            expected = true // automatic available on ios/macos/watchos/visionos
        case (.wheel, .ios), (.wheel, .watchos), (.wheel, .visionos):
            expected = true // wheel unavailable on macOS + tvOS
        case (.graphical, .ios), (.graphical, .macos), (.graphical, .visionos):
            expected = true // graphical unavailable on watchOS + tvOS
        case (.compact, .ios), (.compact, .macos), (.compact, .visionos):
            expected = true // compact unavailable on watchOS + tvOS
        default:
            expected = false // wheel off macOS; graphical/compact off watchOS; field/stepperField off non-macOS
        }
        #expect(
            CosmosDatePickerAvailability.isAvailable(style, on: platform) == expected,
            "\(style) on \(platform.rawValue)"
        )
    }

    @Test func datePickerResolveFallsBackToAutomatic() {
        // An unavailable requested style resolves to .automatic; an available one resolves to itself.
        #expect(CosmosDatePickerAvailability.resolve(.wheel, on: .macos) == .automatic)
        #expect(CosmosDatePickerAvailability.resolve(.field, on: .ios) == .automatic)
        #expect(CosmosDatePickerAvailability.resolve(.graphical, on: .watchos) == .automatic)
        #expect(CosmosDatePickerAvailability.resolve(.stepperField, on: .visionos) == .automatic)
        #expect(CosmosDatePickerAvailability.resolve(.automatic, on: .tvos) == .automatic)
        #expect(CosmosDatePickerAvailability.resolve(.graphical, on: .ios) == .graphical)
        #expect(CosmosDatePickerAvailability.resolve(.wheel, on: .watchos) == .wheel)
        #expect(CosmosDatePickerAvailability.resolve(.field, on: .macos) == .field)
    }
}