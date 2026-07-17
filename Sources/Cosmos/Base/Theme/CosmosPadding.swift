import CoreGraphics

/// Semantic padding selectors backed by a 4-pt spacing scale.
///
/// Atoms read `theme.padding` and resolve it through `CosmosSpacingTokens.value(for:)`,
/// so layouts never hardcode raw point values. See `CosmosSpacingTokens`.
public enum CosmosPadding: String, Sendable, Codable, CaseIterable {
    case none
    case xs
    case small
    case medium
    case large
    case xl
    case xxl
}