import Testing
import Foundation
import SwiftUI
@testable import Cosmos

@Suite("Theme")
struct CosmosThemeTests {

    @Test func defaults() {
        let theme = CosmosTheme.default
        #expect(theme.version == .cosmos26)
        #expect(theme.textStyle == .body)
        #expect(theme.padding == .medium)
        #expect(theme.buttonStyle == .primary)
        #expect(theme.controlSize == .medium)
    }

    @Test func fluentBuildersReturnMutatedCopies() {
        let base = CosmosTheme.default
        #expect(base.withTextStyle(.headline).textStyle == .headline)
        #expect(base.withPadding(.large).padding == .large)
        #expect(base.withButtonStyle(.glass).buttonStyle == .glass)
        #expect(base.withControlSize(.small).controlSize == .small)
        #expect(base.withVersion(.cosmos26).version == .cosmos26)

        let customFont = base.withCustomFont("DMSans-Regular")
        #expect(customFont.typography.customFontName == "DMSans-Regular")
        let systemAgain = customFont.withCustomFont(nil)
        #expect(systemAgain.typography.customFontName == nil)
    }

    @Test func fluentBuildersDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withTextStyle(.headline)
        #expect(base.textStyle == .body)
    }

    @MainActor
    @Test func observableDefaultsAndMutation() {
        let observable = CosmosThemeObservable()
        // CosmosTheme holds non-Equatable Color tokens, so compare a representative field.
        #expect(observable.theme.textStyle == CosmosTheme.default.textStyle)
        #expect(observable.theme.version == CosmosTheme.default.version)
        observable.theme = .default.withTextStyle(.title)
        #expect(observable.theme.textStyle == .title)
    }
}