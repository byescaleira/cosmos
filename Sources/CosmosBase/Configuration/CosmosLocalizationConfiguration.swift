import Foundation

/// Localization defaults for Cosmos components.
///
/// Components resolve strings through the provided `bundle` and `locale`. A
/// `tableName` of `nil` falls back to the default `Localizable.strings` table.
public struct CosmosLocalizationConfiguration: Sendable, Equatable {
    /// The bundle that contains localized strings.
    ///
    /// Defaults to the Cosmos module bundle so that the design system can ship
    /// its own baseline translations. Host apps can override this to use their
    /// main bundle or a custom localization package.
    public var bundle: Bundle

    /// The locale used for formatting and string lookup.
    public var locale: Locale

    /// The strings table name. `nil` uses the default `Localizable` table.
    public var tableName: String?

    /// Creates a localization configuration.
    public init(
        bundle: Bundle = CosmosResources.bundle,
        locale: Locale = .current,
        tableName: String? = nil
    ) {
        self.bundle = bundle
        self.locale = locale
        self.tableName = tableName
    }

    /// The default localization configuration.
    public static let `default` = CosmosLocalizationConfiguration()

    /// Resolves a localized string for the given key.
    ///
    /// The lookup respects `locale` by selecting a language-specific `.lproj`
    /// bundle when one exists, falling back to the base bundle otherwise. This
    /// makes it possible to unit translations for explicit locales without
    /// relying on the process-wide `Locale.current`.
    public func string(for key: String) -> String {
        let effectiveBundle = localeBundle ?? bundle
        return effectiveBundle.localizedString(
            forKey: key,
            value: nil,
            table: tableName
        )
    }

    /// A bundle specialized for the configured locale, if an `.lproj` directory
    /// exists for either the full locale identifier (e.g. `pt-BR`) or the base
    /// language code (e.g. `pt`).
    ///
    /// The lookup normalizes identifiers because SwiftPM may lowercase lproj
    /// directory names or use underscores instead of hyphens depending on the
    /// platform toolchain.
    private var localeBundle: Bundle? {
        let raw = locale.identifier
        let base = raw.split(separator: "-").first
            ?? raw.split(separator: "_").first
            ?? Substring(raw)

        let candidates: [String] = [
            raw,
            raw.lowercased(),
            raw.replacingOccurrences(of: "_", with: "-"),
            raw.replacingOccurrences(of: "_", with: "-").lowercased(),
            String(base),
            String(base).lowercased()
        ].filter { !$0.isEmpty }

        for code in Set(candidates) {
            if let lprojURL = bundle.url(forResource: code, withExtension: "lproj") {
                return Bundle(url: lprojURL)
            }
        }

        return nil
    }

    /// Returns a copy with the bundle replaced.
    public func withBundle(_ bundle: Bundle) -> Self {
        var copy = self
        copy.bundle = bundle
        return copy
    }

    /// Returns a copy with the locale replaced.
    public func withLocale(_ locale: Locale) -> Self {
        var copy = self
        copy.locale = locale
        return copy
    }

    /// Returns a copy with the strings table name replaced.
    public func withTableName(_ tableName: String?) -> Self {
        var copy = self
        copy.tableName = tableName
        return copy
    }
}
