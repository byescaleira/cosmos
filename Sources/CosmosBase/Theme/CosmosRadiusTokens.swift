import CoreGraphics

/// Corner radius tokens used by Cosmos components.
///
/// Values are in points. `full` maps to a capsule or circle shape depending
/// on the component.
public struct CosmosRadiusTokens: Sendable, Equatable {
    public var none: CGFloat
    public var small: CGFloat
    public var medium: CGFloat
    public var large: CGFloat
    public var full: CGFloat

    /// Creates a radius token collection.
    public init(
        none: CGFloat = 0,
        small: CGFloat = 4,
        medium: CGFloat = 8,
        large: CGFloat = 16,
        full: CGFloat = 999_999
    ) {
        self.none = none
        self.small = small
        self.medium = medium
        self.large = large
        self.full = full
    }

    /// The default radius token collection.
    public static let `default` = CosmosRadiusTokens()
}
