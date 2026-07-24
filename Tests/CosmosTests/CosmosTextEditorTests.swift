import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosTextEditor")
struct CosmosTextEditorTests {

    // MARK: - Construction (gated off tvOS + watchOS — TextEditor unavailable there)

    @Test(.disabled(if: isTvOS || isWatchOS), .tags(.availability))
    func textEditorConstructsWithTextBinding() {
        _ = CosmosTextEditor(text: .constant(""))
    }

    @Test(.disabled(if: isTvOS || isWatchOS), .tags(.availability, .selector), arguments: CosmosTextEditorStyle.allCases)
    func textEditorAcceptsEveryStyleVariant(_ style: CosmosTextEditorStyle) {
        _ = CosmosTextEditor(text: .constant("")).cosmosTextEditorStyle(style)
    }

    // MARK: - Style selector enum

    @Test func textEditorStyleAllCases() {
        #expect(CosmosTextEditorStyle.allCases == [.automatic, .plain, .roundedBorder])
    }

    // MARK: - CosmosTextEditorAvailability (full style × platform matrix)
    //
    // Parameterized over (style, platform) so the whole 3×5 matrix is asserted in one test on any
    // host. `TextEditor` is unavailable on tvOS/watchOS entirely; `.roundedBorder` is
    // visionOS-only; `.automatic`/`.plain` are available on iOS/macOS/visionOS.

    @Test(.tags(.selector), arguments: CosmosTextEditorStyle.allCases, CosmosPlatform.allCases)
    func textEditorAvailabilityMatrix(_ style: CosmosTextEditorStyle, on platform: CosmosPlatform) {
        let expected: Bool
        switch (style, platform) {
        case (.roundedBorder, .visionos): expected = true
        case (.automatic, .ios), (.automatic, .macos), (.automatic, .visionos): expected = true
        case (.plain, .ios), (.plain, .macos), (.plain, .visionos): expected = true
        default: expected = false // tvOS/watchOS for all; .roundedBorder off visionOS
        }
        #expect(
            CosmosTextEditorAvailability.isAvailable(style, on: platform) == expected,
            "\(style) on \(platform.rawValue)"
        )
    }

    @Test func textEditorResolveFallsBackToAutomatic() {
        // An unavailable requested style resolves to .automatic; an available one resolves to itself.
        #expect(CosmosTextEditorAvailability.resolve(.roundedBorder, on: .ios) == .automatic)
        #expect(CosmosTextEditorAvailability.resolve(.roundedBorder, on: .macos) == .automatic)
        #expect(CosmosTextEditorAvailability.resolve(.roundedBorder, on: .tvos) == .automatic)
        #expect(CosmosTextEditorAvailability.resolve(.plain, on: .ios) == .plain)
        #expect(CosmosTextEditorAvailability.resolve(.automatic, on: .visionos) == .automatic)
        #expect(CosmosTextEditorAvailability.resolve(.roundedBorder, on: .visionos) == .roundedBorder)
    }
}