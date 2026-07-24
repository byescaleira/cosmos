import Testing
import SwiftUI
@testable import Cosmos

/// Construction smoke tests for atoms that previously had **no behavior test** (only their selector
/// enums were exercised) — per the 2026-07 organization audit. Value-level construction only (no
/// rendering, no ViewInspector / snapshots, per the test contract). The goal is regression coverage
/// that every public init builds a view without crashing across the realistic input shapes.
@MainActor
@Suite("Cosmos Atoms — behavior")
struct CosmosAtomsBehaviorTests {

    // MARK: - CosmosButton

    @Test func buttonConstructsFromCustomLabel() {
        _ = CosmosButton(action: {}) { Text(verbatim: "Save") }
    }

    @Test func buttonConstructsFromLocalizedTitleKey() {
        _ = CosmosButton("welcome.continue") {}
    }

    @Test(arguments: CosmosButtonStyle.allCases)
    func buttonAcceptsEveryButtonStyleVariant(_ style: CosmosButtonStyle) {
        // The style applier routes each variant (incl. .glass on iOS/macOS 26); construction must
        // not crash for any selector. Override is subtree-scoped via the .cosmos* modifier.
        _ = CosmosButton("welcome.continue") {}.cosmosButtonStyle(style)
    }

    @Test func buttonAcceptsSwiftUIShapedOverrides() {
        // .cosmosFont/.cosmosTint/.cosmosForegroundStyle compose on a subtree without building a
        // CosmosTheme (the 0.5.0 surface). The button label honors theme typography, so these reach it.
        _ = CosmosButton("welcome.continue") {}
            .cosmosFont(.body, weight: .bold, design: .rounded)
            .cosmosTint(.purple)
            .cosmosForegroundStyle(.white)
            .cosmosControlSize(.large)
    }

    // MARK: - CosmosCard

    @Test func cardConstructsWithBodyOnly() {
        _ = CosmosCard { CosmosText(verbatim: "Body") }
    }

    @Test func cardConstructsWithHeaderAndFooter() {
        _ = CosmosCard(header: { CosmosText(verbatim: "Title") },
                       body: { CosmosText(verbatim: "Body") },
                       footer: { CosmosText(verbatim: "Footer") })
    }

    @Test func cardConstructsWithHeaderOnly() {
        _ = CosmosCard(header: { CosmosText(verbatim: "Title") },
                       body: { CosmosText(verbatim: "Body") })
    }

    // MARK: - CosmosText

    @Test func textConstructsFromLocalizedKey() {
        _ = CosmosText("welcome.headline")
    }

    @Test func textConstructsFromVerbatim() {
        _ = CosmosText(verbatim: "Hello, world")
    }

    @Test func textAcceptsNilKeyAndNilVerbatim() {
        // Both nil-key and nil-verbatim render nothing (the atom guards on a resolved string).
        _ = CosmosText(nil as String?)
        _ = CosmosText(verbatim: nil as String?)
    }

    @Test func textAcceptsFontOverride() {
        _ = CosmosText("welcome.headline").cosmosFont(.title, weight: .bold)
    }

    // MARK: - CosmosDivider

    @Test func dividerConstructs() {
        _ = CosmosDivider()
    }

    // MARK: - CosmosIcon

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

    @Test func iconConstructsFromCustomImageView() {
        _ = CosmosIcon { Image(systemName: "sparkles") }
    }

    // MARK: - CosmosLink

    @Test func linkConstructsFromDestinationAndCustomLabel() {
        _ = CosmosLink(destination: URL(string: "https://example.com")!) { Text(verbatim: "Open") }
    }

    @Test func linkConstructsFromLocalizedTitleKey() {
        _ = CosmosLink("welcome.continue", destination: URL(string: "https://example.com")!)
    }

    @Test func linkConstructsFromVerbatimTitle() {
        _ = CosmosLink(verbatim: "Visit", destination: URL(string: "https://example.com")!)
    }

    // MARK: - CosmosSection

    @Test func sectionConstructsWithContentOnly() {
        _ = CosmosSection { CosmosText(verbatim: "Row") }
    }

    @Test func sectionConstructsWithContentAndHeader() {
        _ = CosmosSection(content: { CosmosText(verbatim: "Row") },
                           header: { CosmosText(verbatim: "Header") })
    }

    @Test func sectionConstructsWithContentHeaderAndFooter() {
        _ = CosmosSection(content: { CosmosText(verbatim: "Row") },
                           header: { CosmosText(verbatim: "Header") },
                           footer: { CosmosText(verbatim: "Footer") })
    }

    @Test func sectionConstructsWithContentAndFooter() {
        _ = CosmosSection(content: { CosmosText(verbatim: "Row") },
                           footer: { CosmosText(verbatim: "Footer") })
    }

    // MARK: - CosmosScrollView

    @Test func scrollViewConstructsWithDefaultAxes() {
        _ = CosmosScrollView { CosmosText(verbatim: "Content") }
    }

    @Test func scrollViewConstructsWithHorizontalAxesAndNoIndicators() {
        _ = CosmosScrollView(.horizontal, showsIndicators: false) { CosmosText(verbatim: "Content") }
    }

    // MARK: - CosmosAsyncImage

    @Test func asyncImageConstructsWithUrlAndContent() {
        _ = CosmosAsyncImage(url: URL(string: "https://example.com/image.png"),
                             content: { image in image })
    }

    @Test func asyncImageConstructsWithNilUrl() {
        // A nil URL routes to the placeholder slot; construction must not crash.
        _ = CosmosAsyncImage(url: nil, content: { image in image })
    }

    @Test func asyncImageConstructsWithCustomPlaceholderAndFailure() {
        // The `retry` closure is non-Sendable; do not send it into another view — exercise the
        // failure slot with a static view and ignore `retry` (its wiring is covered by previews).
        _ = CosmosAsyncImage(
            url: URL(string: "https://example.com/image.png"),
            content: { image in image },
            placeholder: { AnyView(CosmosText(verbatim: "Loading…")) },
            failure: { _, _ in AnyView(CosmosText(verbatim: "Failed to load")) }
        )
    }
}