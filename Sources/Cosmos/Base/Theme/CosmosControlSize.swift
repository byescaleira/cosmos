import SwiftUI

/// Semantic control-size selectors mapped to SwiftUI `ControlSize`.
public enum CosmosControlSize: String, Sendable, Codable, CaseIterable {
    case small
    case medium
    case large

    /// The matching SwiftUI `ControlSize` applied by atoms.
    public var controlSize: ControlSize {
        switch self {
        case .small: return .small
        case .medium: return .regular
        case .large: return .large
        }
    }
}