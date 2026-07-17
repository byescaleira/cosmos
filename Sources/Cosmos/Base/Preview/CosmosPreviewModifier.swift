import SwiftUI

/// Official shared-context preview modifier (`PreviewModifier` is available on all 5 platforms at
/// the Cosmos 26 baseline: iOS 18 / macOS 15 / tvOS 18 / watchOS 11 / visionOS 2).
///
/// `makeSharedContext()` runs once per canvas and injects the default configuration/theme. Cosmos
/// ships no bundled fonts, so there is no font-registration step (the system font is used by
/// default; register custom fonts in your app). Inject with
/// `#Preview("…", traits: .modifier(CosmosPreviewModifier()))`.
///
/// The struct is **not** explicitly annotated `@MainActor`: `PreviewModifier` is a `@MainActor`
/// protocol, so the conformance already isolates `makeSharedContext`/`body` to the main actor.
/// Adding `@MainActor` would be redundant.
public struct CosmosPreviewModifier: PreviewModifier {
    public init() {}

    public static func makeSharedContext() async throws {
        // No one-time setup is required: Cosmos uses the system font by default and reads all
        // behavior/appearance from the SwiftUI environment injected in `body`.
    }

    @ViewBuilder public func body(content: Content, context: Void) -> some View {
        content
            .environment(\.cosmosConfiguration, .default)
            .environment(\.cosmosTheme, .default)
    }
}