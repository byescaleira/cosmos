import SwiftUI

/// Semantic text styles mapped to SwiftUI Dynamic Type text styles.
///
/// `CosmosTypographyTokens.font(for:)` resolves a `CosmosTextStyle` to a `Font`,
/// preserving Dynamic Type scaling for both system and custom fonts (custom fonts
/// use `Font.custom(_:size:relativeTo:)` with the matching `TextStyle`).
public enum CosmosTextStyle: String, Sendable, Codable, CaseIterable {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case caption
    case caption2
    case footnote

    /// The matching SwiftUI `Font.TextStyle` used for Dynamic Type scaling.
    public var textStyle: Font.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .caption: return .caption
        case .caption2: return .caption2
        case .footnote: return .footnote
        }
    }

    /// The default point size for this style (matches iOS system defaults),
    /// used as the fixed size for custom fonts so they scale relative to the
    /// correct `TextStyle` via `Font.custom(_:size:relativeTo:)`.
    public var pointSize: CGFloat {
        switch self {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        case .subheadline: return 15
        case .body: return 17
        case .callout: return 16
        case .caption: return 12
        case .caption2: return 11
        case .footnote: return 13
        }
    }

    /// The system font for this style (Dynamic Type aware).
    public var systemFont: Font {
        .system(textStyle)
    }
}