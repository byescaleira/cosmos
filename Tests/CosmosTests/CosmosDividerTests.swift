import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosDivider")
struct CosmosDividerTests {

    @Test func dividerConstructs() {
        _ = CosmosDivider()
    }
}