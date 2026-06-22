import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosLinkViewTests {

    @Test func linkRendersTitle() throws {
        let view = CosmosLink("Terms", url: URL(string: "https://byescaleira.com")!)
        let text = try view.inspect().link().labelView().text().string()
        #expect(text == "Terms")
    }

    @Test func linkRendersURL() throws {
        let view = CosmosLink("Terms", url: URL(string: "https://byescaleira.com")!)
        let url = try view.inspect().link().url()
        #expect(url.absoluteString == "https://byescaleira.com")
    }

    @Test func linkFromStringRendersWhenValid() throws {
        let view = CosmosLink("Terms", urlString: "https://byescaleira.com")
        #expect(view != nil)
        let text = try view!.inspect().link().labelView().text().string()
        #expect(text == "Terms")
    }

    @Test func linkFromStringIsNilWhenInvalid() {
        let view = CosmosLink("Terms", urlString: "not a url")
        #expect(view == nil)
    }

    @Test func linkIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosLink("Terms", url: URL(string: "https://byescaleira.com")!)
            .environment(\.cosmosConfiguration, configuration)

        let link = try view.inspect().link()
        #expect(!link.isAbsent)
    }
}
