import Testing
import Foundation
@testable import Cosmos

@Suite("Localization")
struct CosmosLocalizationTests {

    @Test func englishHeadline() {
        let config = CosmosLocalizationConfiguration(locale: Locale(identifier: "en"))
        #expect(config.string(for: CosmosPreviewStrings.welcomeHeadline) == "Get started")
    }

    @Test func portugueseHeadline() {
        let config = CosmosLocalizationConfiguration(locale: Locale(identifier: "pt-BR"))
        #expect(config.string(for: CosmosPreviewStrings.welcomeHeadline) == "Comece agora")
    }

    @Test func englishContinue() {
        let config = CosmosLocalizationConfiguration(locale: Locale(identifier: "en"))
        #expect(config.string(for: CosmosPreviewStrings.welcomeContinue) == "Continue")
    }

    @Test func portugueseContinue() {
        let config = CosmosLocalizationConfiguration(locale: Locale(identifier: "pt-BR"))
        #expect(config.string(for: CosmosPreviewStrings.welcomeContinue) == "Continuar")
    }

    @Test func previewNameIsSameAcrossLocales() {
        let en = CosmosLocalizationConfiguration(locale: Locale(identifier: "en"))
        let pt = CosmosLocalizationConfiguration(locale: Locale(identifier: "pt-BR"))
        #expect(en.string(for: CosmosPreviewStrings.previewName) == "Cosmos")
        #expect(pt.string(for: CosmosPreviewStrings.previewName) == "Cosmos")
    }

    @Test func defaultConfigResolves() {
        // Smoke test: the default config (Bundle.module + system locale) resolves a known key
        // to a non-empty string rather than returning the key literally. `string(for:)` is
        // optional-aware (returns nil for an unresolved key), so unwrap the resolution.
        let value = CosmosLocalizationConfiguration.default.string(for: CosmosPreviewStrings.previewName)
        #expect(value?.isEmpty == false)
        #expect(value != CosmosPreviewStrings.previewName)
    }

    // MARK: - Plural variations (D4)

    @Test(.tags(.selector)) func englishPluralOneAndOther() {
        let config = CosmosLocalizationConfiguration(locale: Locale(identifier: "en"))
        #expect(config.string(for: "items.count", count: 1) == "1 item")
        #expect(config.string(for: "items.count", count: 0) == "0 items")
        #expect(config.string(for: "items.count", count: 5) == "5 items")
    }

    @Test(.tags(.selector)) func portuguesePluralOneAndOther() {
        let config = CosmosLocalizationConfiguration(locale: Locale(identifier: "pt-BR"))
        #expect(config.string(for: "items.count", count: 1) == "1 item")
        #expect(config.string(for: "items.count", count: 2) == "2 itens")
    }

    @Test func pluralWithoutCountReturnsFormatTemplate() {
        // `string(for:)` (no count) returns the un-interpolated template value, not a plural branch.
        let config = CosmosLocalizationConfiguration(locale: Locale(identifier: "en"))
        let plain = config.string(for: "items.count")
        #expect(plain != nil)
    }

    // MARK: - Device variations (D4)
    //
    // Device variations are resolved by SwiftUI's native String Catalog runtime (`Text` /
    // `LocalizedStringResource`), NOT by `NSLocalizedString`. The manual `string(for:)` pipeline
    // resolves them only when the raw `.xcstrings` is in the bundle (Route 2) — i.e. the Xcode 26
    // no-`.lproj` SwiftPM build. The Xcode 27 build compiles the catalog to `.lproj/.stringsdict`
    // and drops the raw `.xcstrings`, so Route 2 can't run there and device keys are rendered via
    // the native path in ``CosmosLocalizedText`` (preview-verified). These tests assert the manual
    // Route 2 parse and are skipped on builds without the raw catalog.

    @Test(.disabled(if: !Self.rawCatalogAvailable), .tags(.availability))
    func deviceVariationMatchesHostPlatform() {
        let config = CosmosLocalizationConfiguration(locale: Locale(identifier: "en"))
        let value = config.string(for: "cosmos.action.select")
        #expect(value?.isEmpty == false)
        #expect(value != "cosmos.action.select")
    }

    @Test(.disabled(if: !Self.rawCatalogAvailable), .tags(.availability))
    func deviceVariationResolvedForPortugueseHost() {
        let config = CosmosLocalizationConfiguration(locale: Locale(identifier: "pt-BR"))
        let value = config.string(for: "cosmos.action.select")
        #expect(value != nil)
        #expect(["Tocar", "Clicar", "Selecionar"].contains(value))
    }

    /// True when the raw `Localizable.xcstrings` is present in the Cosmos bundle (Route 2 can run).
    /// Absent on the Xcode 27 build (catalog compiled to `.lproj/.stringsdict`).
    private static var rawCatalogAvailable: Bool {
        CosmosResources.bundle.url(forResource: "Localizable", withExtension: "xcstrings") != nil
    }
}