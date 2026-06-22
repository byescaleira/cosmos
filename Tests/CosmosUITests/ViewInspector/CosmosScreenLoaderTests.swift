import Testing
import Foundation
import ViewInspector
@testable import CosmosScreen

struct CosmosScreenLoaderTests {

    private let loader = CosmosScreenLoader()

    private var welcomeJSON: String {
        """
        {
            "id": "welcome",
            "title_key": "welcome.title",
            "layout": {
                "root": "vStack",
                "spacing": "medium",
                "padding": "large",
                "alignment": "center"
            },
            "components": [
                { "text": { "content_key": "welcome.headline" } },
                { "text": { "content_key": "welcome.body" } },
                { "spacer": {} },
                {
                    "button": {
                        "title_key": "welcome.continue",
                        "action": { "id": "continue" }
                    }
                }
            ]
        }
        """
    }

    @Test func loadsScreenFromJSONString() throws {
        let screen = try loader.screen(from: welcomeJSON)

        #expect(screen.id == "welcome")
        #expect(screen.titleKey == "welcome.title")
        #expect(screen.layout.root == .vStack)
        #expect(screen.layout.spacing == .medium)
        #expect(screen.layout.padding == .large)
        #expect(screen.layout.alignment == .center)
        #expect(screen.components.count == 4)
    }

    @Test func loadsComponentsFromJSONString() throws {
        let screen = try loader.screen(from: welcomeJSON)

        guard case .text(let headline) = screen.components[safe: 0] else {
            Issue.record("Expected text component at index 0")
            return
        }
        #expect(headline.contentKey == "welcome.headline")

        guard case .spacer = screen.components[safe: 2] else {
            Issue.record("Expected spacer component at index 2")
            return
        }

        guard case .button(let button) = screen.components[safe: 3] else {
            Issue.record("Expected button component at index 3")
            return
        }
        #expect(button.titleKey == "welcome.continue")
        #expect(button.action?.id == "continue")
    }

    @Test func loadsNestedStackFromJSON() throws {
        let json = """
        {
            "id": "nested",
            "layout": {
                "root": "vStack",
                "spacing": "medium",
                "padding": "large",
                "alignment": "center"
            },
            "components": [
                {
                    "h_stack": {
                        "components": [
                            { "text": { "content_key": "left" } },
                            { "text": { "content_key": "right" } }
                        ],
                        "spacing": "small",
                        "alignment": "leading"
                    }
                }
            ]
        }
        """

        let screen = try loader.screen(from: json)

        guard case .hStack(let stack) = screen.components[safe: 0] else {
            Issue.record("Expected hStack component")
            return
        }
        #expect(stack.components.count == 2)
        #expect(stack.spacing == .small)
        #expect(stack.alignment == .leading)
    }

    @Test func invalidJSONThrows() {
        let invalid = "{ "

        #expect(throws: Error.self) {
            try loader.screen(from: invalid)
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
