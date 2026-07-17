import CoreGraphics

/// Corner radius scale.
///
/// `full` is represented as a large finite value (not `.infinity`) so it stays compatible
/// with `RoundedRectangle(cornerRadius:)` and `clipShape` across all platforms.
public enum CosmosRadiusTokens {
    public static let none: CGFloat = 0
    public static let small: CGFloat = 4
    public static let medium: CGFloat = 8
    public static let large: CGFloat = 16
    public static let full: CGFloat = 1_000

    /// Convenience alias used by container atoms (cards, menus).
    public static let card: CGFloat = large
}