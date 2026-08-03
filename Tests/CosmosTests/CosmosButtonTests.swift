import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosButton")
struct CosmosButtonTests {

    // MARK: - Construction

    @Test(.tags(.smoke)) func buttonConstructsFromCustomLabel() {
        _ = CosmosButton(action: {}) { Text(verbatim: "Save") }
    }

    @Test(.tags(.smoke)) func buttonConstructsFromLocalizedTitleKey() {
        _ = CosmosButton("welcome.continue") {}
    }

    @Test(.tags(.smoke)) func buttonConstructsFromLocalizedStringResource() {
        // The `LocalizedStringResource` init lets consumers pass their app's generated String
        // Catalog symbols. A bare `String` literal resolves to the `String` overload above, so the
        // two inits coexist without ambiguity; an explicit `LocalizedStringResource` selects this one.
        _ = CosmosButton(LocalizedStringResource("welcome.continue", table: "Localizable"), action: {})
    }

    @Test(.tags(.selector), arguments: CosmosButtonStyle.allCases)
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
}