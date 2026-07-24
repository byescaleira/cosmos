import Testing
import Foundation
import SwiftUI
@testable import Cosmos

@Suite("Mock")
struct CosmosMockTests {

    // MARK: - RNG determinism

    @Test func rngSameSeedSameSequence() {
        var g1 = CosmosPreviewRNG(seed: CosmosPreview.defaultSeed)
        var g2 = CosmosPreviewRNG(seed: CosmosPreview.defaultSeed)
        let seq1 = (0..<10).map { _ in g1.next() }
        let seq2 = (0..<10).map { _ in g2.next() }
        #expect(seq1 == seq2, "same seed must produce identical sequences")
    }

    @Test func rngDifferentSeedDifferentSequence() {
        var g1 = CosmosPreviewRNG(seed: 1)
        var g2 = CosmosPreviewRNG(seed: 2)
        #expect(g1.next() != g2.next())
    }

    @Test func rngIsSendable() {
        // CosmosPreviewRNG conforms to Sendable (derived; the primary API has zero shared state).
        // Passing it to a Sendable-constrained generic is the compile-time check.
        let g = CosmosPreviewRNG(seed: 42)
        func accept<T: Sendable>(_ x: T) { _ = x }
        accept(g)
    }

    // MARK: - Deterministic generation (inout path)

    @Test func wordIsFromWordlist() {
        var g = CosmosPreviewRNG(seed: CosmosPreview.defaultSeed)
        let w = CosmosMock.word(using: &g)
        #expect(CosmosMockWordlists.lorem.contains(w))
    }

    @Test func wordsCount() {
        var g = CosmosPreviewRNG()
        #expect(CosmosMock.words(0, using: &g).isEmpty)
        #expect(CosmosMock.words(5, using: &g).count == 5)
    }

    @Test func stringLengthAndCharset() {
        var g = CosmosPreviewRNG()
        let s = CosmosMock.string(length: 16, using: &g)
        #expect(s.count == 16)
        #expect(s.unicodeScalars.allSatisfy { CharacterSet.alphanumerics.contains($0) })
    }

    @Test func stringZeroLengthIsEmpty() {
        var g = CosmosPreviewRNG()
        #expect(CosmosMock.string(length: 0, using: &g).isEmpty)
    }

    @Test func intInRange() {
        var g = CosmosPreviewRNG()
        let n = CosmosMock.int(in: 10..<20, using: &g)
        #expect(n >= 10 && n < 20)
    }

    @Test func doubleInRange() {
        var g = CosmosPreviewRNG()
        let d = CosmosMock.double(in: 5...10, using: &g)
        #expect(d >= 5 && d <= 10)
    }

    @Test func largeValueRange() {
        var g = CosmosPreviewRNG()
        let v = CosmosMock.largeValue(using: &g)
        #expect(v >= 1_000 && v <= 10_000_000)
    }

    @Test func uuidIsValid() {
        var g = CosmosPreviewRNG()
        let id = CosmosMock.uuid(using: &g)
        #expect(id != UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)))
        // Reproducible: same seed → same first UUID (two independent generators).
        var g1 = CosmosPreviewRNG(seed: 123)
        var g2 = CosmosPreviewRNG(seed: 123)
        #expect(CosmosMock.uuid(using: &g1) == CosmosMock.uuid(using: &g2))
    }

    @Test func emailContainsAt() {
        var g = CosmosPreviewRNG()
        let e = CosmosMock.email(using: &g)
        #expect(e.contains("@"))
        #expect(e.hasSuffix(".com") || e.hasSuffix(".dev") || e.hasSuffix(".test") || e.hasSuffix(".example"))
    }

    @Test func urlIsHTTPS() {
        var g = CosmosPreviewRNG()
        let u = CosmosMock.url(using: &g)
        #expect(u.scheme == "https")
    }

    @Test func personNameHasSpace() {
        var g = CosmosPreviewRNG()
        let name = CosmosMock.personName(using: &g)
        #expect(name.contains(" "))
        #expect(name.split(separator: " ").count == 2)
    }

    @Test func currencyFormatted() {
        var g = CosmosPreviewRNG()
        let s = CosmosMock.currency(amountIn: 1...100, locale: Locale(identifier: "en_US"), using: &g)
        #expect(s.contains("$"))
    }

    @Test func percentageFormatted() {
        var g = CosmosPreviewRNG()
        let s = CosmosMock.percentage(in: 0...1, using: &g)
        #expect(s.contains("%"))
    }

    @Test func decimalInRange() {
        var g = CosmosPreviewRNG()
        let d = CosmosMock.decimal(in: 0...100, using: &g)
        #expect(d >= 0 && d <= 100)
    }

    // MARK: - Color

    @Test func colorBrightnessRange() {
        var g = CosmosPreviewRNG()
        // Just verify generation does not crash and returns a usable color on all platforms.
        _ = CosmosMock.color(using: &g)
        _ = CosmosMock.color(brightnessIn: 0.3...0.7, using: &g)
    }

    // MARK: - Shared generator (Mutex-protected)

    @Test func resetMakesReproducible() {
        CosmosMock.reset(seed: CosmosPreview.defaultSeed)
        let a = CosmosMock.word()
        CosmosMock.reset(seed: CosmosPreview.defaultSeed)
        let b = CosmosMock.word()
        #expect(a == b, "reset(seed:) restores the same stream head")
    }

    @Test func sharedConvenienceNonEmpty() {
        CosmosMock.reset()
        #expect(!CosmosMock.sentence().isEmpty)
        #expect(!CosmosMock.lorem(paragraphs: 2).isEmpty)
        #expect(!CosmosMock.addressLine().isEmpty)
        #expect(!CosmosMock.phone().isEmpty)
        #expect(CosmosMockWordlists.sfSymbols.contains(CosmosMock.sfSymbol()))
    }
}

@Suite("Preview")
struct CosmosPreviewTests {

    @Test func defaultSeedIsValidHex() {
        // 0xC05505 — sanity that the seed is a real hex literal (not the invalid 0xC05M05).
        #expect(CosmosPreview.defaultSeed == 0xC05505)
    }

    @Test func localesBaseline() {
        #expect(CosmosPreview.locales.count == 2)
        #expect(CosmosPreview.locales.map(\.identifier).contains("pt-BR"))
    }

    @Test func rtlLocaleIsArabic() {
        #expect(CosmosPreview.rtlLocale.identifier == "ar")
    }

    @Test func accessibilitySizesCoverRange() {
        #expect(CosmosPreview.accessibilitySizes.count == 4)
        #expect(CosmosPreview.accessibilitySizes.contains(.accessibility5))
        #expect(CosmosPreview.accessibilitySizes.contains(.xSmall))
    }

    @Test func variantsAllCases() {
        #expect(CosmosPreviewVariant.allCases.count == 10)
        #expect(CosmosPreviewVariant.allCases.contains(.reduceMotion))
        #expect(CosmosPreviewVariant.allCases.contains(.increasedContrast))
        #expect(CosmosPreviewVariant.allCases.contains(.showBorders))
        #expect(CosmosPreviewVariant.allCases.contains(.rtl))
    }

    @Test func previewStringsConstants() {
        #expect(CosmosPreviewStrings.welcomeHeadline == "welcome.headline")
        #expect(CosmosPreviewStrings.loading == "Loading")
    }
}