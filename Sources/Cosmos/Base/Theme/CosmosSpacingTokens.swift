import CoreGraphics

/// 4-pt spacing scale.
///
/// Raw values are provided as static constants for direct use. To honor Dynamic Type at
/// the accessibility sizes for *non-text* metrics, apply `@ScaledMetric` at the call site
/// (e.g. inside a View) — `@ScaledMetric` cannot live in a plain enum. Atoms that read
/// `theme.padding` resolve it through ``value(for:)``.
public enum CosmosSpacingTokens {
    public static let none: CGFloat = 0
    public static let xs: CGFloat = 4
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 12
    public static let large: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 32

    /// Resolves a ``CosmosPadding`` selector to a raw point value on the 4-pt grid.
    public static func value(for padding: CosmosPadding) -> CGFloat {
        switch padding {
        case .none: return none
        case .xs: return xs
        case .small: return small
        case .medium: return medium
        case .large: return large
        case .xl: return xl
        case .xxl: return xxl
        }
    }
}