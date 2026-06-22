import SwiftUI

/// Semantic typography tokens used by Cosmos components.
///
/// Defaults map to SwiftUI `Font` text styles so Dynamic Type works out of
/// the box on iOS, watchOS, and tvOS.
public struct CosmosTypographyTokens: Sendable, Equatable {
    public var largeTitle: Font
    public var title: Font
    public var title2: Font
    public var title3: Font
    public var headline: Font
    public var subheadline: Font
    public var body: Font
    public var callout: Font
    public var caption: Font
    public var caption2: Font
    public var footnote: Font

    /// Creates a typography token collection.
    public init(
        largeTitle: Font = .largeTitle,
        title: Font = .title,
        title2: Font = .title2,
        title3: Font = .title3,
        headline: Font = .headline,
        subheadline: Font = .subheadline,
        body: Font = .body,
        callout: Font = .callout,
        caption: Font = .caption,
        caption2: Font = .caption2,
        footnote: Font = .footnote
    ) {
        self.largeTitle = largeTitle
        self.title = title
        self.title2 = title2
        self.title3 = title3
        self.headline = headline
        self.subheadline = subheadline
        self.body = body
        self.callout = callout
        self.caption = caption
        self.caption2 = caption2
        self.footnote = footnote
    }

    /// The default typography token collection.
    public static let `default` = CosmosTypographyTokens()

    /// Returns the font for a given semantic text style.
    public func font(for style: CosmosTextStyle) -> Font {
        switch style {
        case .largeTitle: largeTitle
        case .title: title
        case .title2: title2
        case .title3: title3
        case .headline: headline
        case .subheadline: subheadline
        case .body: body
        case .callout: callout
        case .caption: caption
        case .caption2: caption2
        case .footnote: footnote
        }
    }
}
