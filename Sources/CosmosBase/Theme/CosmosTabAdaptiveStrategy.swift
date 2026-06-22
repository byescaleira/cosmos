import Foundation

/// Strategy used by `CosmosTabView` to choose between a bottom tab bar and a
/// sidebar layout.
///
/// `.automatic` reads the horizontal size class: compact widths use a
/// `TabView` and regular widths use a `NavigationSplitView` sidebar. The host
/// can override this per view using `.cosmosTabAdaptiveStrategy(_:)`.
public enum CosmosTabAdaptiveStrategy: String, Sendable, Codable, CaseIterable {
    case automatic
    case tabBar
    case sidebar
}
