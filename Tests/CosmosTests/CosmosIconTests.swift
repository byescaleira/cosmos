import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosIcon")
struct CosmosIconTests {

    // MARK: - Construction

    @Test func iconConstructsFromSystemName() {
        _ = CosmosIcon(systemName: "star.fill")
    }

    @Test func iconConstructsFromVariableValue() {
        _ = CosmosIcon(systemName: "chart.bar.fill", variableValue: 0.75)
    }

    @Test func iconConstructsFromBundledAssetName() {
        _ = CosmosIcon("PlaceholderAsset", bundle: nil)
    }

    @Test func iconConstructsDecoratively() {
        _ = CosmosIcon(decorative: "PlaceholderAsset", bundle: nil)
    }

    @Test func iconConstructsDecorativeSystemName() {
        _ = CosmosIcon(decorativeSystemName: "star.fill")
    }

    @Test func iconConstructsFromCustomImageView() {
        _ = CosmosIcon { Image(systemName: "sparkles") }
    }
}