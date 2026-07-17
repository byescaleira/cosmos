import Foundation

/// Localization contract (modern String Catalog stack).
///
/// String Catalogs (`.xcstrings`) are compiled by `.process("Resources")` in `Package.swift`
/// into per-locale `.lproj/Localizable.strings` inside the module bundle. ``string(for:)``
/// resolves a key from the configured locale's `.lproj` sub-bundle — deterministic and
/// independent of the process's preferred-language list. When no locale is set, the bundle's
/// preferred localizations (system language) are used.
///
/// `Bundle` and `Locale` are `Sendable`, so this struct is `Sendable` (SE-0302).
public struct CosmosLocalizationConfiguration: Sendable {
    /// The bundle to resolve from. Defaults to `Bundle.module` (the compiled String Catalog).
    public var bundle: Bundle?
    /// An explicit locale; `nil` uses the system-preferred language.
    public var locale: Locale?
    /// The string table name. Defaults to `Localizable` (the catalog filename).
    public var tableName: String

    public init(bundle: Bundle? = nil, locale: Locale? = nil, tableName: String = "Localizable") {
        self.bundle = bundle
        self.locale = locale
        self.tableName = tableName
    }

    public static let `default` = CosmosLocalizationConfiguration()

    /// Resolves a localized string for `key`, honoring the configured `locale` when present.
    public func string(for key: String) -> String {
        let resolvedBundle = bundle ?? Bundle.module

        // When a locale is explicitly configured, resolve from its `.lproj` sub-bundle so the
        // result is deterministic and does not depend on the process preferred-language list.
        // `String(localized:bundle:locale:)` does not reliably honor `locale` for lookup across
        // all bundle layouts/OS versions, so the lproj route is the robust path.
        if let locale {
            if let lprojBundle = Self.lprojBundle(for: locale, in: resolvedBundle) {
                return NSLocalizedString(key, tableName: tableName, bundle: lprojBundle, value: key, comment: "")
            }
        }

        return NSLocalizedString(key, tableName: tableName, bundle: resolvedBundle, value: key, comment: "")
    }

    /// Returns the `.lproj` sub-bundle for `locale`, trying the full identifier first and then
    /// falling back to the language code (e.g. `pt-BR` → `pt`). `nil` when no matching lproj exists.
    private static func lprojBundle(for locale: Locale, in container: Bundle) -> Bundle? {
        if let path = container.path(forResource: locale.identifier, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        if let languageCode = locale.language.languageCode?.identifier,
           let path = container.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return nil
    }
}