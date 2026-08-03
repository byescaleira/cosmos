import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosAsyncImage")
struct CosmosAsyncImageTests {

    // MARK: - Construction
    //
    // `CosmosAsyncImage` is `@available(*, deprecated)` (migrate to `CosmosImage(url:)`); every
    // construction test is annotated with the matching `@available(*, deprecated)` passthrough so the
    // deprecated init call sites don't emit warnings — keeps the build warning-free for the
    // deprecation runway. One test per deprecated init family (default slots / typed slots / AnyView).

    @Test(.tags(.smoke))
    @available(*, deprecated, message: "Exercising deprecated CosmosAsyncImage inits during the deprecation runway.")
    func asyncImageConstructsWithDefaultSlots() {
        // Default placeholder (`CosmosAsyncImagePlaceholder`) + failure (`CosmosAsyncImageFailure`).
        _ = CosmosAsyncImage(url: URL(string: "https://example.com/image.png")) { image in image }
    }

    @Test(.tags(.smoke))
    @available(*, deprecated, message: "Exercising deprecated CosmosAsyncImage inits during the deprecation runway.")
    func asyncImageConstructsWithNilUrlAndDefaultSlots() {
        // A nil URL routes to the placeholder slot; construction must not crash.
        _ = CosmosAsyncImage(url: nil as URL?) { image in image }
    }

    @Test(.tags(.smoke))
    @available(*, deprecated, message: "Exercising deprecated CosmosAsyncImage inits during the deprecation runway.")
    func asyncImageConstructsWithTypedPlaceholderAndFailure() {
        // Typed (non-AnyView) slot closures — the canonical generic form (WWDC21-10022 identity).
        // The `retry` closure is non-Sendable; exercise the failure slot with a static view and
        // ignore `retry` (its wiring is covered by previews).
        _ = CosmosAsyncImage(
            url: URL(string: "https://example.com/image.png"),
            content: { image in image },
            placeholder: { CosmosText(verbatim: "Loading…") },
            failure: { _, _ in CosmosText(verbatim: "Failed to load") }
        )
    }

    @Test(.tags(.smoke))
    @available(*, deprecated, message: "Exercising deprecated CosmosAsyncImage inits during the deprecation runway.")
    func asyncImageConstructsWithAnyViewErasedSlots() {
        // The deprecated `AnyView`-erased overload — legacy call sites resolve here. Kept for the
        // deprecation runway; new code uses the typed-slot init above or `CosmosImage`.
        _ = CosmosAsyncImage(
            url: URL(string: "https://example.com/image.png"),
            content: { image in image },
            placeholder: { AnyView(CosmosText(verbatim: "Loading…")) },
            failure: { _, _ in AnyView(CosmosText(verbatim: "Failed to load")) }
        )
    }
}