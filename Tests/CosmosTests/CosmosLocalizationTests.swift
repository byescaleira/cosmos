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
        // to a non-empty string rather than returning the key literally.
        let value = CosmosLocalizationConfiguration.default.string(for: CosmosPreviewStrings.previewName)
        #expect(!value.isEmpty)
        #expect(value != CosmosPreviewStrings.previewName)
    }
}