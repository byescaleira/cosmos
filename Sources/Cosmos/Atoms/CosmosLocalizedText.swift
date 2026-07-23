import SwiftUI

/// Resolves a localized String Catalog key through ``CosmosLocalizationConfiguration`` (honoring
/// the configured `locale`), so ``CosmosLabel``'s key-based inits flow through the same pipeline
/// as ``CosmosText``.
public struct CosmosLocalizedText: View {
    private let key: String
    @Environment(\.cosmosConfiguration) private var configuration

    public init(key: String) { self.key = key }

    @ViewBuilder
    public var body: some View {
        // `string(for:)` is optional-aware (returns `nil` for a `nil` key or an unresolved key);
        // render nothing when unresolved, mirroring ``CosmosText``'s nil-handling.
        if let resolved = configuration.localization.string(for: key) {
            Text(resolved)
        }
    }
}