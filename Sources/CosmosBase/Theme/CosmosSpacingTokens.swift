import CoreGraphics

/// Spacing tokens used by Cosmos components.
///
/// Values are in points. The defaults are a 4-point grid scaled to common
/// increments. Platform-specific overrides can be introduced later without
/// changing the public API.
public struct CosmosSpacingTokens: Sendable, Equatable {
    public var none: CGFloat
    public var xs: CGFloat
    public var small: CGFloat
    public var medium: CGFloat
    public var large: CGFloat
    public var xl: CGFloat
    public var xxl: CGFloat

    /// Creates a spacing token collection.
    public init(
        none: CGFloat = 0,
        xs: CGFloat = 4,
        small: CGFloat = 8,
        medium: CGFloat = 12,
        large: CGFloat = 16,
        xl: CGFloat = 24,
        xxl: CGFloat = 32
    ) {
        self.none = none
        self.xs = xs
        self.small = small
        self.medium = medium
        self.large = large
        self.xl = xl
        self.xxl = xxl
    }

    /// The default spacing token collection.
    public static let `default` = CosmosSpacingTokens()

    /// Returns the point value for a named padding/spacing token.
    public func value(for padding: CosmosPadding) -> CGFloat {
        switch padding {
        case .none: none
        case .xs: xs
        case .small: small
        case .medium: medium
        case .large: large
        case .xl: xl
        case .xxl: xxl
        }
    }
}
