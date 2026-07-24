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
    ///
    /// `comment` is the translator context for the key (one of the four components of a localizable
    /// string per WWDC23-10155); it is forwarded to `NSLocalizedString` so it exports into XLIFF
    /// `<note>` when the catalog is extracted. It is **not** used by the `.xcstrings` parser route
    /// (the catalog already carries its own `comment` field per key).
    public func string(for key: String?, comment: String? = nil) -> String? {
        string(for: key, count: nil, comment: comment)
    }

    /// Resolves a localized, plural-aware string for `key` interpolated with `count`.
    ///
    /// When `count` is non-`nil`, the String Catalog `plural` variation is selected for the
    /// configured locale (`one` for exactly 1, `other` otherwise — sufficient for `en` + `pt-BR`,
    /// which use only those two categories; a locale with `zero`/`few`/`many` would resolve
    /// through the compiled-`.lproj` route, where Foundation's `stringsdict` engine applies the
    /// full CLDR rule). The compiled `.lproj` route (Xcode 27) also drives plurals natively;
    /// this manual variation lookup is the fallback for the no-`.lproj` SwiftPM build.
    public func string(for key: String?, count: Int?, comment: String? = nil) -> String? {
        guard let key else { return nil }
        let resolvedBundle = bundle ?? Bundle.module
        let nsComment = comment ?? ""

        // Route 1 — compiled `.lproj/Localizable.strings` (Xcode 27 / Swift 6.4 SwiftPM compiles
        // the `.xcstrings` into per-locale `.lproj` sub-bundles). When a locale is explicitly
        // configured, resolve from its `.lproj` so the result is deterministic and does not depend
        // on the process preferred-language list. `String(localized:bundle:locale:)` does not
        // reliably honor `locale` for lookup across all bundle layouts/OS versions, so the lproj
        // route is the robust path. Plural resolution (`.stringsdict`) is driven by `count` here.
        //
        // Device variations are **not** resolvable by `NSLocalizedString` (only by the String
        // Catalog runtime) — when the lproj returns the key unchanged (the `value:` fallback), it
        // means the entry has no flat string for this key, so fall through to Route 2's manual
        // `.xcstrings` lookup, which handles `device`/`plural` variations directly.
        if let locale, let lprojBundle = Self.lprojBundle(for: locale, in: resolvedBundle) {
            if let count {
                let formatted = String.localizedStringWithFormat(
                    NSLocalizedString(key, tableName: tableName, bundle: lprojBundle, value: key, comment: nsComment),
                    count
                )
                if formatted != key { return formatted }
            } else {
                let resolved = NSLocalizedString(key, tableName: tableName, bundle: lprojBundle, value: key, comment: nsComment)
                if resolved != key { return resolved }
            }
        }

        // Route 2 — read the `.xcstrings` catalog directly. Xcode 26 / Swift 6.3 SwiftPM copies
        // the `.xcstrings` verbatim instead of compiling `.lproj` (no `.lproj` is produced), so
        // `NSLocalizedString` cannot resolve and would return the key. Parse the catalog JSON and
        // extract the value for the configured locale (full id → language code → source language),
        // honoring `plural`/`device` variations when `count` is set / a device hint is present.
        // Also the fallback for `device` variations on the Xcode 27 lproj build (Route 1 cannot
        // resolve them via `NSLocalizedString`).
        if let value = Self.xcstringsValue(for: key, table: tableName, locale: locale, count: count, in: resolvedBundle) {
            if let count, let formatted = Self.format(value, with: count) {
                return formatted
            }
            return value
        }

        return NSLocalizedString(key, tableName: tableName, bundle: resolvedBundle, value: key, comment: nsComment)
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
    ///
    /// When `count` is non-`nil`, the per-locale `plural` variation is selected (`one` for exactly
    /// 1, else `other`); when a `device` variation exists for the host device, that branch is
    /// preferred. Both fall back to the plain `stringUnit.value` when the variation is absent.
    private static func xcstringsValue(for key: String, table: String, locale: Locale?, count: Int?, in container: Bundle) -> String? {
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
            guard let loc = localizations[id] as? [String: Any] else { continue }
            // Variation precedence: device (host) → plural (count) → plain stringUnit.
            if let deviceValue = deviceVariationValue(in: loc) {
                return deviceValue
            }
            if let count, let pluralValue = pluralVariationValue(in: loc, count: count) {
                return pluralValue
            }
            if let unit = loc["stringUnit"] as? [String: Any],
               let value = unit["value"] as? String {
                return value
            }
        }
        return nil
    }

    /// Returns the host-device variation value when the catalog declares one for this device,
    /// else `nil`. String Catalog `device` keys: `iPhone`, `iPad`, `Mac`, `Apple TV`,
    /// `Apple Watch`, `Apple Vision Pro`.
    private static func deviceVariationValue(in loc: [String: Any]) -> String? {
        guard let variations = loc["variations"] as? [String: Any],
              let device = variations["device"] as? [String: Any] else {
            return nil
        }
        let key = CosmosPlatform.localizedTextDeviceKey
        if let unit = device[key] as? [String: Any],
           let value = (unit["stringUnit"] as? [String: Any])?["value"] as? String {
            return value
        }
        return nil
    }

    /// Returns the plural variation value for `count` (`one` for exactly 1, else `other`),
    /// else `nil` when no `plural` variation is declared.
    private static func pluralVariationValue(in loc: [String: Any], count: Int) -> String? {
        guard let variations = loc["variations"] as? [String: Any],
              let plural = variations["plural"] as? [String: Any] else {
            return nil
        }
        let category = count == 1 ? "one" : "other"
        // Try the exact category, then `other` as the universal fallback.
        for candidate in [category, "other"] {
            if let unit = plural[candidate] as? [String: Any],
               let value = (unit["stringUnit"] as? [String: Any])?["value"] as? String {
                return value
            }
        }
        return nil
    }

    /// Interpolates an integer `count` into a `%lld`-bearing format string using Foundation's
    /// positional formatter. `nil` when the value carries no positional placeholder (leave it
    /// unformatted for the caller to render raw).
    private static func format(_ value: String, with count: Int) -> String? {
        guard value.contains("%") else { return nil }
        return String.localizedStringWithFormat(NSLocalizedString(value, comment: ""), count)
    }
}
