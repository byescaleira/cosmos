import Foundation

/// Cross-platform tab role selector.
///
/// Mirrors SwiftUI `Tab.Role` so JSON models can describe tab prominence
/// without importing SwiftUI symbols. `.prominent` maps to the iOS 27+
/// `Tab(role: .prominent)` API.
public enum CosmosTabRole: String, Sendable, Codable, CaseIterable {
    case `default`
    case prominent
}
