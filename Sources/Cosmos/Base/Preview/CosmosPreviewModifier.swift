import SwiftUI

/// Official shared-context preview modifier (`PreviewModifier` is available on all 5 platforms at
/// the Cosmos 26 baseline: iOS 18 / macOS 15 / tvOS 18 / watchOS 11 / visionOS 2).
///
/// `makeSharedContext()` runs once per canvas and performs preview-only setup: font registration
/// via the existing once-token (no lock). Inject with
/// `#Preview("…", traits: .modifier(CosmosPreviewModifier()))`.
///
/// The struct is **not** explicitly annotated `@MainActor`: `PreviewModifier` is a `@MainActor`
/// protocol, so the conformance already isolates `makeSharedContext`/`body` to the main actor.
/// Adding `@MainActor` would be redundant. `makeSharedContext` calls only the nonisolated
/// once-token `CosmosFont.registerIfNeeded()`, which is safe from any isolation context.
public struct CosmosPreviewModifier: PreviewModifier {
    public init() {}

    public static func makeSharedContext() async throws {
        // Font registration uses the once-token `static let` (thread-safe, no lock primitive).
        CosmosFont.registerIfNeeded()
    }

    @ViewBuilder public func body(content: Content, context: Void) -> some View {
        content
            .environment(\.cosmosConfiguration, .default)
            .environment(\.cosmosTheme, .default)
    }
}