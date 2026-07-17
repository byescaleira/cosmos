import Foundation

/// Loading-state contract.
///
/// Atoms render loading affordances (spinner overlay, `.redacted(.placeholder)`) based on
/// `isLoading`. `minimumDisplayTime` avoids flicker; `delay` postpones the loading
/// appearance (useful for fast operations). All value types → `Sendable` (SE-0302).
public struct CosmosLoadingConfiguration: Sendable {
    /// Whether the consuming component is currently in a loading state.
    public var isLoading: Bool
    /// Minimum time the loading state stays visible once shown (avoids flicker), in seconds.
    public var minimumDisplayTime: TimeInterval
    /// Delay before the loading state appears, in seconds (useful for fast operations).
    public var delay: TimeInterval

    public init(isLoading: Bool = false, minimumDisplayTime: TimeInterval = 0, delay: TimeInterval = 0) {
        self.isLoading = isLoading
        self.minimumDisplayTime = minimumDisplayTime
        self.delay = delay
    }

    public static let `default` = CosmosLoadingConfiguration()
}