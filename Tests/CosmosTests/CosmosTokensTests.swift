import Testing
import Foundation
import SwiftUI
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

    // MARK: Padding edges

    @Test func paddingAllCases() {
        #expect(CosmosPadding.allCases == [.none, .xs, .small, .medium, .large, .xl, .xxl])
    }

    @Test func paddingEdgesAllCases() {
        #expect(CosmosPaddingEdges.allCases == [.all, .horizontal, .vertical, .top, .bottom, .leading, .trailing])
    }

    @Test func paddingEdgesMapToSwiftUISet() {
        // The edge enum mirrors SwiftUI's Edge.Set so `.cosmosPadding(.horizontal, .large)`
        // routes to `.padding(.horizontal, value)`.
        #expect(CosmosPaddingEdges.all.edgeSet == .all)
        #expect(CosmosPaddingEdges.horizontal.edgeSet == .horizontal)
        #expect(CosmosPaddingEdges.vertical.edgeSet == .vertical)
        #expect(CosmosPaddingEdges.top.edgeSet == .top)
        #expect(CosmosPaddingEdges.bottom.edgeSet == .bottom)
        #expect(CosmosPaddingEdges.leading.edgeSet == .leading)
        #expect(CosmosPaddingEdges.trailing.edgeSet == .trailing)
    }

    @Test func paddingEdgesHashable() {
        #expect(Set(CosmosPaddingEdges.allCases).count == 7)
        #expect(CosmosPaddingEdges.horizontal == .horizontal)
        #expect(CosmosPaddingEdges.horizontal != .vertical)
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

    // MARK: Typography — weight/design overrides (.cosmosFont backing tokens)

    @Test func typographyDefaultsAreNil() {
        #expect(CosmosTypographyTokens.default.weight == nil)
        #expect(CosmosTypographyTokens.default.design == nil)
        #expect(CosmosTypographyTokens.default.customFontName == nil)
    }

    @Test func typographyInitsCarryWeightDesign() {
        let system = CosmosTypographyTokens(preset: .default, weight: .bold, design: .rounded)
        #expect(system.weight == .bold)
        #expect(system.design == .rounded)
        #expect(system.customFontName == nil)
        let custom = CosmosTypographyTokens(customFont: "DMSans-Bold", weight: .semibold, design: .serif)
        #expect(custom.customFontName == "DMSans-Bold")
        // weight/design are accepted on the custom path for completeness (ignored by the resolver).
        #expect(custom.weight == .semibold)
        #expect(custom.design == .serif)
    }

    @Test func typographySystemResolverHonorsWeightAndDesign() {
        // Value-level: the resolver returns a Font for every (style, weight, design) combination
        // without crashing. (Font equality is not inspectable; we exercise construction only.)
        for style in CosmosTextStyle.allCases {
            for weight: Font.Weight? in [.regular, .bold, .semibold, .heavy, nil] {
                for design: Font.Design? in [.default, .rounded, .serif, .monospaced, nil] {
                    let tokens = CosmosTypographyTokens(preset: .default, weight: weight, design: design)
                    _ = tokens.font(for: style)
                }
            }
        }
    }

    @Test func typographyCustomPathIgnoresWeightDesign() {
        // A custom font routes through Font.custom(_:size:relativeTo:) regardless of weight/design.
        let tokens = CosmosTypographyTokens(customFont: "DMSans-Regular", weight: .bold, design: .rounded)
        for style in CosmosTextStyle.allCases {
            _ = tokens.font(for: style)   // must not crash; weight/design do not alter the custom path.
        }
        #expect(tokens.customFontName == "DMSans-Regular")
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