import Foundation

/// Cross-platform list style selector.
///
/// Mirrors SwiftUI `ListStyle` choices without importing SwiftUI symbols,
/// so JSON models and theme files can describe a list style in the platform-
/// agnostic `CosmosScreen` target.
public enum CosmosListStyle: String, Sendable, Codable, CaseIterable {
    case automatic
    case plain
    case grouped
    case insetGrouped
    case sidebar
}
