import SwiftUI

/// Resolves a localized String Catalog key through ``CosmosLocalizationConfiguration`` (honoring
/// the configured `locale`), so ``CosmosLabel``'s key-based inits flow through the same pipeline
/// as ``CosmosText``.
public struct CosmosLocalizedText: View {
    private let key: String
    private let count: Int?
    private let comment: String?
    @Environment(\.cosmosConfiguration) private var configuration

    /// Creates a localized text view for `key`.
    /// - Parameter comment: optional translator context for `key` (forwarded to `NSLocalizedString`
    ///   so it exports to XLIFF `<note>` on extraction; see ``CosmosLocalizationConfiguration/string(for:comment:)``).
    public init(key: String, comment: String? = nil) {
        self.key = key
        self.count = nil
        self.comment = comment
    }

    /// Creates a localized, plural-aware text view for `key` interpolated with `count`. Selects the
    /// String Catalog `plural` variation for the configured locale (`one` for exactly 1, else
    /// `other`); see ``CosmosLocalizationConfiguration/string(for:count:comment:)``.
    public init(key: String, count: Int, comment: String? = nil) {
        self.key = key
        self.count = count
        self.comment = comment
    }

    @ViewBuilder
    public var body: some View {
        // `string(for:count:comment:)` is optional-aware (returns `nil` for a `nil` key) and
        // returns the key itself when nothing resolves (the `value:` fallback). When it resolves
        // to a real value, render it. When it returns the *key* (unresolved — e.g. a `device`-
        // variation key on the Xcode 27 lproj build, where `NSLocalizedString` can't resolve device
        // variations and the raw `.xcstrings` isn't in the bundle to parse), fall back to SwiftUI's
        // native String Catalog runtime via `Text(LocalizedStringKey)`, which resolves `device`
        // (and `plural`, given interpolations) variations at render time.
        if let resolved = configuration.localization.string(for: key, count: count, comment: comment),
           resolved != key {
            Text(resolved)
        } else if count == nil {
            Text(LocalizedStringKey(key), bundle: CosmosResources.bundle)
        }
    }
}