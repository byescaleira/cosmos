import SwiftUI

extension EnvironmentValues {
    /// The current Cosmos behavior configuration.
    @Entry public var cosmosConfiguration: CosmosConfiguration = .default

    /// The current Cosmos visual theme.
    @Entry public var cosmosTheme: CosmosTheme = .default

    /// The adaptive strategy used by `CosmosTabView` when its own strategy
    /// parameter is `.automatic`.
    @Entry public var cosmosTabAdaptiveStrategy: CosmosTabAdaptiveStrategy = .automatic
}
