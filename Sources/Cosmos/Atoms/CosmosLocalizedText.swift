import SwiftUI

/// Resolves a localized String Catalog key through ``CosmosLocalizationConfiguration`` (honoring
/// the configured `locale`), so ``CosmosLabel``'s key-based inits flow through the same pipeline
/// as ``CosmosText``.
public struct CosmosLocalizedText: View {
    private let key: String
    private let comment: String?
    @Environment(\.cosmosConfiguration) private var configuration

    /// Creates a localized text view for `key`.
    /// - Parameter comment: optional translator context for `key` (forwarded to `NSLocalizedString`
    ///   so it exports to XLIFF `<note>` on extraction; see ``CosmosLocalizationConfiguration/string(for:comment:)``).
    public init(key: String, comment: String? = nil) {
        self.key = key
        self.comment = comment
    }

    @ViewBuilder
    public var body: some View {
        // `string(for:comment:)` is optional-aware (returns `nil` for a `nil` key or an unresolved
        // key); render nothing when unresolved, mirroring ``CosmosText``'s nil-handling.
        if let resolved = configuration.localization.string(for: key, comment: comment) {
            Text(resolved)
        }
    }
}