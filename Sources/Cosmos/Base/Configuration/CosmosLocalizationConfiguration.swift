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

        // Route 1 — compiled `.lproj/Localizable.strings` (Xcode 27 / Swift 6.4 SwiftPM compiles
        // the `.xcstrings` into per-locale `.lproj` sub-bundles). When a locale is explicitly
        // configured, resolve from its `.lproj` so the result is deterministic and does not depend
        // on the process preferred-language list. `String(localized:bundle:locale:)` does not
        // reliably honor `locale` for lookup across all bundle layouts/OS versions, so the lproj
        // route is the robust path.
        if let locale {
            if let lprojBundle = Self.lprojBundle(for: locale, in: resolvedBundle) {
                return NSLocalizedString(key, tableName: tableName, bundle: lprojBundle, value: key, comment: "")
            }
        }

        // Route 2 — read the `.xcstrings` catalog directly. Xcode 26 / Swift 6.3 SwiftPM copies
        // the `.xcstrings` verbatim instead of compiling `.lproj` (no `.lproj` is produced), so
        // `NSLocalizedString` cannot resolve and would return the key. Parse the catalog JSON and
        // extract the value for the configured locale (full id → language code → source language).
        // No-op when the `.lproj` route already resolved or when no `.xcstrings` is present.
        if let value = Self.xcstringsValue(for: key, table: tableName, locale: locale, in: resolvedBundle) {
            return value
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

    /// Parses the `.xcstrings` catalog at `<table>.xcstrings` in `container` and returns the
    /// resolved value for `key`, trying the full locale id (hyphen- and underscore-normalized),
    /// the language code, a `language-Region` reconstruction, and finally the source language.
    /// `nil` when the catalog or key is absent. Used as the fallback when no `.lproj` exists.
    private static func xcstringsValue(for key: String, table: String, locale: Locale?, in container: Bundle) -> String? {
        guard let url = container.url(forResource: table, withExtension: "xcstrings"),
              let data = try? Data(contentsOf: url),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let strings = object["strings"] as? [String: Any],
              let entry = strings[key] as? [String: Any],
              let localizations = entry["localizations"] as? [String: Any] else {
            return nil
        }

        var candidateIds: [String] = []
        if let locale {
            let raw = locale.identifier
            candidateIds.append(raw)
            candidateIds.append(raw.replacingOccurrences(of: "_", with: "-"))
            if let lang = locale.language.languageCode?.identifier {
                candidateIds.append(lang)
                if let region = locale.region?.identifier {
                    candidateIds.append("\(lang)-\(region)")
                }
            }
        }
        if let sourceLanguage = object["sourceLanguage"] as? String {
            candidateIds.append(sourceLanguage)
        }

        for id in candidateIds {
            if let loc = localizations[id] as? [String: Any],
               let unit = loc["stringUnit"] as? [String: Any],
               let value = unit["value"] as? String {
                return value
            }
        }
        return nil
    }
}