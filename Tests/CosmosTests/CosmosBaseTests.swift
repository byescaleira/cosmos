import Testing
import Foundation
import SwiftUI
@testable import CosmosBase
@testable import Cosmos

// MARK: - Helpers

final class ThreadSafeBox<T: Sendable>: @unchecked Sendable {
    private var _value: T?
    private let lock = NSLock()

    func set(_ value: T?) {
        lock.lock()
        defer { lock.unlock() }
        _value = value
    }

    var value: T? {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }
}

// MARK: - CosmosConfiguration

@Test func configurationStartsWithDefaults() {
    let configuration = CosmosConfiguration.default

    #expect(configuration.accessibility == .default)
    #expect(configuration.localization == .default)
    #expect(configuration.loading == .default)
    #expect(configuration.enable == .default)
}

@Test func configurationMutationsCreateNewInstances() {
    var configuration = CosmosConfiguration.default
    configuration.enable.isEnabled = false
    configuration.loading.isLoading = true

    #expect(!configuration.enable.isEnabled)
    #expect(configuration.loading.isLoading)

    // Original unchanged
    #expect(CosmosConfiguration.default.enable.isEnabled)
    #expect(!CosmosConfiguration.default.loading.isLoading)
}

@Test func configurationFluentMutationsCreateNewInstances() {
    let disabled = CosmosConfiguration.default.withEnabled(false)
    #expect(!disabled.enable.isEnabled)
    #expect(CosmosConfiguration.default.enable.isEnabled)

    let loading = CosmosConfiguration.default.withLoading(true)
    #expect(loading.loading.isLoading)
    #expect(!CosmosConfiguration.default.loading.isLoading)

    let hidden = CosmosConfiguration.default.withAccessibilityHidden(true)
    #expect(hidden.accessibility.isHidden)
    #expect(!CosmosConfiguration.default.accessibility.isHidden)
}

// MARK: - CosmosEnableConfiguration

@Test func enableConfigurationDefaults() {
    let enable = CosmosEnableConfiguration.default

    #expect(enable.isEnabled)
    #expect(enable.isVisible)
    #expect(!enable.isReadOnly)
}

// MARK: - CosmosLoadingConfiguration

@Test func loadingConfigurationDefaults() {
    let loading = CosmosLoadingConfiguration.default

    #expect(!loading.isLoading)
    #expect(loading.delay == nil)
    #expect(loading.minimumDisplayTime == nil)
}

// MARK: - CosmosAccessibilityConfiguration

@Test func accessibilityConfigurationDefaults() {
    let accessibility = CosmosAccessibilityConfiguration.default

    #expect(accessibility.label == nil)
    #expect(accessibility.hint == nil)
    #expect(accessibility.traits == nil)
    #expect(!accessibility.isHidden)
    #expect(accessibility.sortPriority == 0)
}

// MARK: - CosmosLocalizationConfiguration

@Test func localizationConfigurationDefaultsToModuleBundle() {
    let localization = CosmosLocalizationConfiguration()

    #expect(localization.locale == .current)
    #expect(localization.tableName == nil)
}

@Test func localizationConfigurationResolvesEnglishStrings() {
    let localization = CosmosLocalizationConfiguration(
        locale: Locale(identifier: "en")
    )

    #expect(localization.string(for: "welcome.headline") == "Get started")
    #expect(localization.string(for: "welcome.continue") == "Continue")
}

@Test func localizationConfigurationResolvesBrazilianPortugueseStrings() {
    let localization = CosmosLocalizationConfiguration(
        locale: Locale(identifier: "pt-BR")
    )

    #expect(localization.string(for: "welcome.headline") == "Comece agora")
    #expect(localization.string(for: "welcome.continue") == "Continuar")
}

// MARK: - CosmosTheme

@Test func themeStartsWithDefaults() {
    let theme = CosmosTheme.default

    #expect(theme.colors == .default)
    #expect(theme.typography == .default)
    #expect(theme.spacing == .default)
    #expect(theme.radii == .default)
    #expect(theme.textStyle == .body)
    #expect(theme.iconScale == .medium)
    #expect(theme.dividerStyle == .default)
    #expect(theme.buttonStyle == .primary)
    #expect(theme.padding == .medium)
}

@Test func themeFluentMutationsCreateNewInstances() {
    let theme = CosmosTheme.default
        .withTextStyle(.title)
        .withIconScale(.large)
        .withPadding(.small)

    #expect(theme.textStyle == .title)
    #expect(theme.iconScale == .large)
    #expect(theme.padding == .small)

    // Original unchanged
    #expect(CosmosTheme.default.textStyle == .body)
    #expect(CosmosTheme.default.iconScale == .medium)
    #expect(CosmosTheme.default.padding == .medium)
}

@Test func themeFontMapping() {
    #expect(CosmosTypographyTokens.default.font(for: .title) == .title)
    #expect(CosmosTypographyTokens.default.font(for: .body) == .body)
    #expect(CosmosTypographyTokens.default.font(for: .caption) == .caption)
}

@Test func themeIconScaleMapping() {
    #expect(CosmosIconScale.small.imageScale == .small)
    #expect(CosmosIconScale.large.imageScale == .large)
}

@Test func themeSpacingMapping() {
    #expect(CosmosSpacingTokens.default.value(for: .none) == 0)
    #expect(CosmosSpacingTokens.default.value(for: .small) == 8)
    #expect(CosmosSpacingTokens.default.value(for: .medium) == 12)
    #expect(CosmosSpacingTokens.default.value(for: .large) == 16)
}

// MARK: - Environment distribution

@Test func configurationEnvironmentProvidesDefault() {
    let environment = EnvironmentValues()
    #expect(environment.cosmosConfiguration.accessibility == .default)
    #expect(environment.cosmosConfiguration.enable == .default)
}

@Test func themeEnvironmentProvidesDefault() {
    let environment = EnvironmentValues()
    #expect(environment.cosmosTheme == .default)
}

// MARK: - Log/Error

@Test func logConfigurationReceivesEvents() {
    let box = ThreadSafeBox<CosmosLogEvent>()
    var config = CosmosLogConfiguration.default
    config.handler = { event in box.set(event) }

    config.log(CosmosLogEvent(level: .info, message: "ok", source: "test"))

    #expect(box.value?.message == "ok")
    #expect(box.value?.level == .info)
}

@Test func errorConfigurationReceivesErrors() {
    let box = ThreadSafeBox<CosmosErrorEvent>()
    var config = CosmosErrorConfiguration.default
    config.handler = { event in box.set(event) }

    struct TestError: Error {}
    config.report(TestError(), source: "test", metadata: ["k": "v"])

    #expect(box.value?.source == "test")
    #expect(box.value?.metadata["k"] == "v")
}
