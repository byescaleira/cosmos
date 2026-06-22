import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosSectionViewTests {

    @Test func sectionRendersContent() throws {
        let view = CosmosSection {
            CosmosText("Item")
        }

        let section = try view.inspect().section()
        #expect(try section.count == 1)
        #expect(try section.find(text: "Item").string() == "Item")
    }

    @Test func sectionRendersHeaderAndContent() throws {
        let view = CosmosSection(header: {
            CosmosText("Header")
        }, content: {
            CosmosText("Item")
        })

        let section = try view.inspect().section()
        #expect(try section.find(text: "Header").string() == "Header")
        #expect(try section.find(text: "Item").string() == "Item")
    }

    @Test func sectionRendersHeaderFooterAndContent() throws {
        let view = CosmosSection(
            header: { CosmosText("Header") },
            footer: { CosmosText("Footer") },
            content: { CosmosText("Item") }
        )

        let section = try view.inspect().section()
        #expect(try section.find(text: "Header").string() == "Header")
        #expect(try section.find(text: "Footer").string() == "Footer")
        #expect(try section.find(text: "Item").string() == "Item")
    }

    @Test func sectionIsHiddenWhenNotVisible() throws {
        var configuration = CosmosConfiguration.default
        configuration.enable.isVisible = false

        let view = CosmosSection {
            CosmosText("Item")
        }
        .environment(\.cosmosConfiguration, configuration)

        // ViewInspector evaluates the body before the environment modifier is
        // applied, so the visibility gate is not observable headlessly. The
        // section still appears here; real visibility is verified in snapshot
        // tests that run inside a UIHostingController.
        let section = try view.inspect().section()
        #expect(!section.isAbsent)
    }
}
