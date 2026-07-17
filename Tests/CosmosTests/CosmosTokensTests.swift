import Testing
import Foundation
@testable import Cosmos

@Suite("Tokens")
struct CosmosTokensTests {

    // MARK: Spacing (4-pt grid)

    @Test func spacingGrid() {
        #expect(CosmosSpacingTokens.value(for: .none) == 0)
        #expect(CosmosSpacingTokens.value(for: .xs) == 4)
        #expect(CosmosSpacingTokens.value(for: .small) == 8)
        #expect(CosmosSpacingTokens.value(for: .medium) == 12)
        #expect(CosmosSpacingTokens.value(for: .large) == 16)
        #expect(CosmosSpacingTokens.value(for: .xl) == 24)
        #expect(CosmosSpacingTokens.value(for: .xxl) == 32)
    }

    @Test func spacingConstants() {
        #expect(CosmosSpacingTokens.large == 16)
        #expect(CosmosSpacingTokens.xxl == 32)
    }

    // MARK: Radius

    @Test func radiusTokens() {
        #expect(CosmosRadiusTokens.none == 0)
        #expect(CosmosRadiusTokens.small == 4)
        #expect(CosmosRadiusTokens.medium == 8)
        #expect(CosmosRadiusTokens.large == 16)
        #expect(CosmosRadiusTokens.card == CosmosRadiusTokens.large)
        #expect(CosmosRadiusTokens.full > 100)
    }

    // MARK: Text style

    @Test func textStylePoints() {
        #expect(CosmosTextStyle.largeTitle.pointSize == 34)
        #expect(CosmosTextStyle.title.pointSize == 28)
        #expect(CosmosTextStyle.body.pointSize == 17)
        #expect(CosmosTextStyle.caption2.pointSize == 11)
    }

    @Test func textStyleAllCasesResolveFontWithoutCrashing() {
        for style in CosmosTextStyle.allCases {
            _ = CosmosTypographyTokens.default.font(for: style)
        }
    }

    // MARK: Selectors

    @Test func buttonStyleAllCases() {
        #expect(CosmosButtonStyle.allCases.count == 5)
        #expect(CosmosButtonStyle.allCases.contains(.glass))
    }

    @Test func controlSizeMapping() {
        #expect(CosmosControlSize.small.controlSize == .small)
        #expect(CosmosControlSize.medium.controlSize == .regular)
        #expect(CosmosControlSize.large.controlSize == .large)
    }

    // MARK: Version

    @Test func versionCurrentIsCosmos26() {
        #expect(CosmosVersion.current == .cosmos26)
        #expect(CosmosVersion.cosmos26.osMajor == 26)
    }

    @Test func fontPresetAndCustomFont() {
        // Cosmos ships no bundled fonts: the only preset is `.default` (system → nil name).
        #expect(CosmosFontPreset.allCases == [.default])
        #expect(CosmosFontPreset.default.fontName == nil)
        // Default typography uses the system font (nil custom name).
        #expect(CosmosTypographyTokens.default.customFontName == nil)
        // A custom font is carried as the PostScript name and resolved via Font.custom(_:relativeTo:).
        #expect(CosmosTypographyTokens(customFont: "DMSans-Regular").customFontName == "DMSans-Regular")
        #expect(CosmosTypographyTokens(preset: .default).customFontName == nil)
    }
}