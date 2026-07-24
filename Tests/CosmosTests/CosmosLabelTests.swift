import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosLabel")
struct CosmosLabelTests {

    // MARK: - Construction

    @Test func labelConstructsWithCustomTitleAndIcon() {
        _ = CosmosLabel(title: { Text(verbatim: "Title") }, icon: { Image(systemName: "star") })
    }

    @Test func labelConstructsFromLocalizedKeyAndSystemImage() {
        _ = CosmosLabel("preview.title", systemImage: "star")
    }

    @Test func labelConstructsFromLocalizedKeyAndAssetImage() {
        _ = CosmosLabel("preview.title", image: "PlaceholderAsset")
    }

    @Test func labelConstructsFromVerbatimTitleAndSystemImage() {
        _ = CosmosLabel(verbatim: "Label", systemImage: "star")
    }

    @Test func labelConstructsFromVerbatimTitleAndAssetImage() {
        _ = CosmosLabel(verbatim: "Label", image: "PlaceholderAsset")
    }

    @Test(.tags(.selector), arguments: CosmosLabelStyle.allCases)
    func labelAcceptsEveryStyleVariant(_ style: CosmosLabelStyle) {
        _ = CosmosLabel("preview.title", systemImage: "star").cosmosLabelStyle(style)
    }

    // MARK: - Style selector enum

    @Test func labelStyleAllCases() {
        #expect(CosmosLabelStyle.allCases == [.automatic, .titleAndIcon, .iconOnly, .titleOnly, .cosmos])
    }
}