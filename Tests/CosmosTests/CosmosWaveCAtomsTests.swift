import Testing
import Foundation
@testable import Cosmos

@Suite("Wave C Atoms")
struct CosmosWaveCAtomsTests {

    // MARK: - Style selector enums

    @Test func groupBoxStyleAllCases() {
        #expect(CosmosGroupBoxStyle.allCases == [.automatic, .cosmos])
    }

    @Test func menuStyleAllCases() {
        #expect(CosmosMenuStyle.allCases == [.automatic, .button])
    }

    @Test func datePickerStyleAllCases() {
        #expect(CosmosDatePickerStyle.allCases == [
            .automatic, .wheel, .graphical, .compact, .field, .stepperField
        ])
    }

    // MARK: - CosmosPlatform

    @Test func platformAllCases() {
        #expect(CosmosPlatform.allCases == [.ios, .macos, .watchos, .visionos, .tvos])
    }

    @Test func platformCurrentIsHost() {
        // The test host is macOS — `current` must resolve to the compile-time host.
        #expect(CosmosPlatform.current == .macos)
    }

    // MARK: - CosmosGroupBoxAvailability (pure platform predicate)

    @Test func groupBoxAvailabilityMatchesPlatform() {
        // The predicate must agree with the platform enum: native chrome exists everywhere except
        // tvOS/watchOS.
        let expected = CosmosPlatform.current != .tvos && CosmosPlatform.current != .watchos
        #expect(CosmosGroupBoxAvailability.hasNativeGroupBox == expected)
        // On the macOS host specifically, the native GroupBox path is live.
        #expect(CosmosGroupBoxAvailability.hasNativeGroupBox == true)
    }

    // MARK: - CosmosMenuAccessibility + availability

    @Test func menuPrimaryActionFeedback() {
        // Non-destructive primary tap → .selection.
        let normal = CosmosMenuAccessibility.primaryActionFeedback(isDestructive: false)
        if case .selection = normal {
            // expected
        } else {
            Issue.record("expected .selection for a non-destructive primary action")
        }
        // Destructive primary tap → .impact(weight: .rigid, intensity: nil).
        let destructive = CosmosMenuAccessibility.primaryActionFeedback(isDestructive: true)
        if case .impact(let weight, let intensity) = destructive {
            #expect(weight == .rigid)
            #expect(intensity == nil)
        } else {
            Issue.record("expected .impact(.rigid) for a destructive primary action")
        }
    }

    @Test func menuAvailabilityMatchesPlatform() {
        // `.menuActionDismissBehavior(.disabled)`: iOS 16.4+/tvOS 17+/visionOS 1+ — unavailable on
        // macOS/watchOS. On the macOS host this is `false`.
        #expect(CosmosMenuAvailability.supportsDismissBehaviorDisabled == (CosmosPlatform.current != .macos && CosmosPlatform.current != .watchos))
        // `.menuOrder(.priority)`: iOS/visionOS only.
        #expect(CosmosMenuAvailability.supportsMenuOrderPriority == (CosmosPlatform.current == .ios || CosmosPlatform.current == .visionos))
        #expect(CosmosMenuAvailability.supportsMenuOrderPriority == false) // macOS host
    }

    // MARK: - CosmosDatePickerAvailability (full style × platform matrix)
    //
    // Parameterized over (style, platform) so the whole 6×5 matrix is asserted in one test on any
    // host (T5). `DatePicker` is type-level unavailable on tvOS (every style false); `.field` and
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

    // MARK: - Theme selectors (defaults + fluent builders)

    @Test func themeDefaultsForWaveCSelectors() {
        let theme = CosmosTheme.default
        #expect(theme.groupBoxStyle == .automatic)
        #expect(theme.menuStyle == .automatic)
        #expect(theme.datePickerStyle == .automatic)
    }

    @Test func themeFluentBuildersForWaveC() {
        let base = CosmosTheme.default
        #expect(base.withGroupBoxStyle(.cosmos).groupBoxStyle == .cosmos)
        #expect(base.withMenuStyle(.button).menuStyle == .button)
        #expect(base.withDatePickerStyle(.graphical).datePickerStyle == .graphical)
    }

    @Test func themeFluentBuildersDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withGroupBoxStyle(.cosmos)
        _ = base.withMenuStyle(.button)
        _ = base.withDatePickerStyle(.wheel)
        #expect(base.groupBoxStyle == .automatic)
        #expect(base.menuStyle == .automatic)
        #expect(base.datePickerStyle == .automatic)
    }
}