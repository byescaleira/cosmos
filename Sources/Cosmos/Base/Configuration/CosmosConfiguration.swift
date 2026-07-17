import Foundation

/// Aggregate of all 9 cross-cutting behavior contracts.
///
/// Injected via `@Environment(\.cosmosConfiguration)` (an `@Entry` value). Because every
/// sub-configuration is a `Sendable` value type with a nonisolated default initializer,
/// this aggregate is `Sendable` and safe to use as an `@Entry` default (no MainActor-isolated
/// default-value conflict — SE-0412). Per-instance overrides use `.cosmos*` modifiers that
/// read the environment, mutate a copy via the fluent builders below, and re-inject.
public struct CosmosConfiguration: Sendable {
    public var accessibility: CosmosAccessibilityConfiguration
    public var localization: CosmosLocalizationConfiguration
    public var log: CosmosLogConfiguration
    public var error: CosmosErrorConfiguration
    public var loading: CosmosLoadingConfiguration
    public var enable: CosmosEnableConfiguration
    public var haptics: CosmosHapticsConfiguration
    public var motion: CosmosMotionConfiguration
    public var tracking: CosmosTrackingConfiguration

    public init(
        accessibility: CosmosAccessibilityConfiguration = .default,
        localization: CosmosLocalizationConfiguration = .default,
        log: CosmosLogConfiguration = .default,
        error: CosmosErrorConfiguration = .default,
        loading: CosmosLoadingConfiguration = .default,
        enable: CosmosEnableConfiguration = .default,
        haptics: CosmosHapticsConfiguration = .default,
        motion: CosmosMotionConfiguration = .default,
        tracking: CosmosTrackingConfiguration = .default
    ) {
        self.accessibility = accessibility
        self.localization = localization
        self.log = log
        self.error = error
        self.loading = loading
        self.enable = enable
        self.haptics = haptics
        self.motion = motion
        self.tracking = tracking
    }

    public static let `default` = CosmosConfiguration()

    // MARK: - Fluent builders (return a mutated copy)

    public func withAccessibility(_ accessibility: CosmosAccessibilityConfiguration) -> CosmosConfiguration { var c = self; c.accessibility = accessibility; return c }
    public func withLocalization(_ localization: CosmosLocalizationConfiguration) -> CosmosConfiguration { var c = self; c.localization = localization; return c }
    public func withLog(_ log: CosmosLogConfiguration) -> CosmosConfiguration { var c = self; c.log = log; return c }
    public func withError(_ error: CosmosErrorConfiguration) -> CosmosConfiguration { var c = self; c.error = error; return c }
    public func withLoading(_ loading: CosmosLoadingConfiguration) -> CosmosConfiguration { var c = self; c.loading = loading; return c }
    public func withEnable(_ enable: CosmosEnableConfiguration) -> CosmosConfiguration { var c = self; c.enable = enable; return c }
    public func withHaptics(_ haptics: CosmosHapticsConfiguration) -> CosmosConfiguration { var c = self; c.haptics = haptics; return c }
    public func withMotion(_ motion: CosmosMotionConfiguration) -> CosmosConfiguration { var c = self; c.motion = motion; return c }
    public func withTracking(_ tracking: CosmosTrackingConfiguration) -> CosmosConfiguration { var c = self; c.tracking = tracking; return c }
}