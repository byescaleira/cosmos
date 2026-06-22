import Foundation
import CosmosBase

/// Describes the root layout of a screen.
///
/// `CosmosLayout` is a `Sendable`, `Codable` value type. It only describes
/// structure; the renderer turns it into a SwiftUI container.
public struct CosmosLayout: Sendable, Codable, Equatable {
    /// The root container type.
    public var root: CosmosContainerType

    /// The spacing between children, using Cosmos semantic tokens.
    public var spacing: CosmosPadding

    /// The padding around the root container, using Cosmos semantic tokens.
    public var padding: CosmosPadding

    /// The alignment of children inside the root container.
    public var alignment: CosmosStackAlignment

    /// Creates a layout description.
    public init(
        root: CosmosContainerType = .vStack,
        spacing: CosmosPadding = .medium,
        padding: CosmosPadding = .large,
        alignment: CosmosStackAlignment = .center
    ) {
        self.root = root
        self.spacing = spacing
        self.padding = padding
        self.alignment = alignment
    }

    /// The default layout.
    public static let `default` = CosmosLayout()
}

/// Supported root containers for a screen.
public enum CosmosContainerType: String, Sendable, Codable, CaseIterable {
    case vStack, hStack, zStack
}

/// Cross-axis alignment for stacks.
public enum CosmosStackAlignment: String, Sendable, Codable, CaseIterable {
    case leading, center, trailing
}
