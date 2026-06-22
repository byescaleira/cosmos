import Foundation

/// Loading behavior defaults for Cosmos components.
///
/// Components use the `isLoading` flag directly and can optionally honor the
/// `delay` and `minimumDisplayTime` fields to avoid flashing spinners.
public struct CosmosLoadingConfiguration: Sendable, Equatable {
    /// Whether components should render loading placeholders.
    public var isLoading: Bool

    /// Minimum time a loading state should be shown before dismissal.
    /// A value of `nil` means no minimum.
    public var minimumDisplayTime: Duration?

    /// Delay before a loading state appears.
    /// A value of `nil` means immediate.
    public var delay: Duration?

    /// Creates a loading configuration.
    public init(
        isLoading: Bool = false,
        minimumDisplayTime: Duration? = nil,
        delay: Duration? = nil
    ) {
        self.isLoading = isLoading
        self.minimumDisplayTime = minimumDisplayTime
        self.delay = delay
    }

    /// The default loading configuration.
    public static let `default` = CosmosLoadingConfiguration()
}
