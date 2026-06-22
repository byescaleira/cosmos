import SwiftUI
import CosmosBase

/// A flexible spacer atom.
///
/// `CosmosSpacer` reads its visibility from the SwiftUI environment and
/// expands along the major axis of its container. It accepts an optional
/// minimum length through its initializer; override visibility through the
/// `.cosmosVisible(_:)` modifier.
public struct CosmosSpacer: View {
    @Environment(\.cosmosConfiguration) private var configuration

    let minLength: CGFloat?

    /// Creates a Cosmos spacer atom.
    public init(minLength: CGFloat? = nil) {
        self.minLength = minLength
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    public var body: some View {
        if effectiveVisible {
            Spacer(minLength: minLength)
        }
    }
}
