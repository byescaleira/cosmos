import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosIcon")
struct CosmosIconTests {

    // MARK: - Construction
    //
    // `CosmosIcon` is `@available(*, deprecated)` (migrate to `CosmosImage`); every construction
    // test is annotated with the matching `@available(*, deprecated)` passthrough so the deprecated
    // init call sites don't emit warnings — keeps the build warning-free for the deprecation runway.
    // One test per deprecated init, mirroring the `CosmosImage` construction matrix.

    @Test(.tags(.smoke))
    @available(*, deprecated, message: "Exercising deprecated CosmosIcon inits during the deprecation runway.")
    func iconConstructsFromCustomLabel() {
        _ = CosmosIcon { Image(systemName: "star.fill") }
    }

    @Test(.tags(.smoke))
    @available(*, deprecated, message: "Exercising deprecated CosmosIcon inits during the deprecation runway.")
    func iconConstructsFromSystemName() {
        _ = CosmosIcon(systemName: "star.fill")
    }

    @Test(.tags(.smoke))
    @available(*, deprecated, message: "Exercising deprecated CosmosIcon inits during the deprecation runway.")
    func iconConstructsFromSystemNameAndVariableValue() {
        _ = CosmosIcon(systemName: "chart.bar.fill", variableValue: 0.75)
    }

    @Test(.tags(.smoke))
    @available(*, deprecated, message: "Exercising deprecated CosmosIcon inits during the deprecation runway.")
    func iconConstructsFromDecorativeSystemName() {
        _ = CosmosIcon(decorativeSystemName: "chevron.right")
    }

    @Test(.tags(.smoke))
    @available(*, deprecated, message: "Exercising deprecated CosmosIcon inits during the deprecation runway.")
    func iconConstructsFromBundledAssetName() {
        // `bundle: nil` resolves via the main bundle at runtime; construction must not crash.
        _ = CosmosIcon("PlaceholderAsset", bundle: nil)
    }

    @Test(.tags(.smoke))
    @available(*, deprecated, message: "Exercising deprecated CosmosIcon inits during the deprecation runway.")
    func iconConstructsFromDecorativeBundledAsset() {
        _ = CosmosIcon(decorative: "PlaceholderAsset", bundle: nil)
    }
}