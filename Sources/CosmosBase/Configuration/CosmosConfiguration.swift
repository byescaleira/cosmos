import Foundation

/// Central behavior configuration shared by every Cosmos component.
///
/// `CosmosConfiguration` carries cross-cutting concerns such as accessibility,
/// localization, logging, error reporting, loading state, enablement, and
/// content redaction. It is a `Sendable` value type: mutations happen by
/// replacement, either through the SwiftUI environment or via a local `@State`
/// copy.
public struct CosmosConfiguration: Sendable {
    /// Accessibility defaults for components.
    public var accessibility: CosmosAccessibilityConfiguration

    /// Localization defaults for components.
    public var localization: CosmosLocalizationConfiguration

    /// Logging contract for components.
    public var log: CosmosLogConfiguration

    /// Error reporting contract for components.
    public var error: CosmosErrorConfiguration

    /// Loading behavior defaults for components.
    public var loading: CosmosLoadingConfiguration

    /// Enablement / visibility / read-only defaults for components.
    public var enable: CosmosEnableConfiguration

    /// Whether components should render placeholder redactions.
    public var redaction: CosmosRedactionConfiguration

    /// Creates a configuration with explicit contracts.
    public init(
        accessibility: CosmosAccessibilityConfiguration = .default,
        localization: CosmosLocalizationConfiguration = .default,
        log: CosmosLogConfiguration = .default,
        error: CosmosErrorConfiguration = .default,
        loading: CosmosLoadingConfiguration = .default,
        enable: CosmosEnableConfiguration = .default,
        redaction: CosmosRedactionConfiguration = .default
    ) {
        self.accessibility = accessibility
        self.localization = localization
        self.log = log
        self.error = error
        self.loading = loading
        self.enable = enable
        self.redaction = redaction
    }

    /// The default configuration used when none is injected.
    public static let `default` = CosmosConfiguration()
}

public extension CosmosConfiguration {
    /// Returns a copy with the global enabled flag replaced.
    func withEnabled(_ isEnabled: Bool) -> Self {
        var copy = self
        copy.enable.isEnabled = isEnabled
        return copy
    }

    /// Returns a copy with the global visibility flag replaced.
    func withVisible(_ isVisible: Bool) -> Self {
        var copy = self
        copy.enable.isVisible = isVisible
        return copy
    }

    /// Returns a copy with the global read-only flag replaced.
    func withReadOnly(_ isReadOnly: Bool) -> Self {
        var copy = self
        copy.enable.isReadOnly = isReadOnly
        return copy
    }

    /// Returns a copy with the global loading flag replaced.
    func withLoading(_ isLoading: Bool) -> Self {
        var copy = self
        copy.loading.isLoading = isLoading
        return copy
    }

    /// Returns a copy with the redaction placeholder flag replaced.
    func withRedacted(_ isRedacted: Bool) -> Self {
        var copy = self
        copy.redaction.isRedacted = isRedacted
        return copy
    }

    /// Returns a copy with the accessibility label replaced.
    func withAccessibilityLabel(_ label: String?) -> Self {
        var copy = self
        copy.accessibility.label = label
        return copy
    }

    /// Returns a copy with the accessibility hint replaced.
    func withAccessibilityHint(_ hint: String?) -> Self {
        var copy = self
        copy.accessibility.hint = hint
        return copy
    }

    /// Returns a copy with the accessibility hidden flag replaced.
    func withAccessibilityHidden(_ isHidden: Bool) -> Self {
        var copy = self
        copy.accessibility.isHidden = isHidden
        return copy
    }

    /// Returns a copy with the accessibility sort priority replaced.
    func withAccessibilitySortPriority(_ sortPriority: Double) -> Self {
        var copy = self
        copy.accessibility.sortPriority = sortPriority
        return copy
    }

    /// Returns a copy with the localization configuration replaced.
    func withLocalization(
        bundle: Bundle? = nil,
        locale: Locale? = nil,
        tableName: String? = nil
    ) -> Self {
        var copy = self
        if let bundle {
            copy.localization = copy.localization.withBundle(bundle)
        }
        if let locale {
            copy.localization = copy.localization.withLocale(locale)
        }
        if let tableName {
            copy.localization = copy.localization.withTableName(tableName)
        }
        return copy
    }

    /// Returns a copy with the log handler replaced.
    func withLogHandler(
        _ handler: @escaping @Sendable (CosmosLogEvent) -> Void
    ) -> Self {
        var copy = self
        copy.log.handler = handler
        return copy
    }

    /// Returns a copy with the error handler replaced.
    func withErrorHandler(
        _ handler: @escaping @Sendable (CosmosErrorEvent) -> Void
    ) -> Self {
        var copy = self
        copy.error.handler = handler
        return copy
    }
}
