import Testing
import SwiftUI
import ViewInspector
@testable import Cosmos

@MainActor
struct CosmosSearchBarViewTests {

    @Test func searchBarRendersIconAndField() throws {
        let view = CosmosSearchBar(
            text: .constant(""),
            placeholder: "search.placeholder"
        )

        let inspected = try view.inspect().view(CosmosSearchBar.self)
        #expect(try inspected.find(ViewInspector.ViewType.Image.self).isAbsent == false)
        #expect(try inspected.find(ViewInspector.ViewType.TextField.self).isAbsent == false)
    }

    @Test func searchBarShowsClearButtonWhenTextIsNotEmpty() throws {
        let view = CosmosSearchBar(
            text: .constant("query"),
            placeholder: "search.placeholder"
        )

        let inspected = try view.inspect().view(CosmosSearchBar.self)
        #expect(try inspected.find(ViewInspector.ViewType.Button.self).isAbsent == false)
    }

    @Test func searchBarHidesClearButtonWhenTextIsEmpty() throws {
        let view = CosmosSearchBar(
            text: .constant(""),
            placeholder: "search.placeholder"
        )

        let inspected = try view.inspect().view(CosmosSearchBar.self)
        let buttons = try inspected.findAll(ViewInspector.ViewType.Button.self)
        #expect(buttons.isEmpty)
    }
}
