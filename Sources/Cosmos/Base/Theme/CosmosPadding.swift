import CoreGraphics
import SwiftUI

/// Semantic padding selectors backed by a 4-pt spacing scale.
///
/// Atoms read `theme.padding` and resolve it through `CosmosSpacingTokens.value(for:)`,
/// so layouts never hardcode raw point values. See `CosmosSpacingTokens`.
public enum CosmosPadding: String, Sendable, Codable, CaseIterable {
    case none
    case xs
    case small
    case medium
    case large
    case xl
    case xxl
}

/// The set of edges a ``View/cosmosPadding(_:_:)`` (edge form) applies its token-scaled padding to.
/// Mirrors SwiftUI's `Edge.Set` so a token-driven padding can target a subset of edges
/// (`.horizontal`, `.vertical`, a single side, or `.all`) without falling back to raw points.
public enum CosmosPaddingEdges: Sendable, Hashable, CaseIterable {
    case all
    case horizontal
    case vertical
    case top
    case bottom
    case leading
    case trailing

    /// The matching SwiftUI `Edge.Set` passed to `.padding(_:_)`.
    public var edgeSet: Edge.Set {
        switch self {
        case .all: return .all
        case .horizontal: return .horizontal
        case .vertical: return .vertical
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        }
    }
}