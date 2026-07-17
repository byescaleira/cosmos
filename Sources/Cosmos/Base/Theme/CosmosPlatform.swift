import Foundation

/// A platform identifier for pure (render-free) per-platform availability tables.
///
/// Used by atoms whose customization surface fragments across the 5 Cosmos targets (DatePicker,
/// Picker, List, TabView style matrices). A compile-time `#if os()` predicate only answers for the
/// host platform; this enum lets a single test assert the full style × platform matrix on any host.
public enum CosmosPlatform: String, Sendable, Codable, CaseIterable {
    case ios
    case macos
    case watchos
    case visionos
    case tvos

    /// The platform the library is currently being compiled for. `visionOS` is checked before
    /// `iOS` for safety (in case `os(iOS)` is reported true on visionOS in some SDK revision).
    public static var current: CosmosPlatform {
        #if os(macOS)
        return .macos
        #elseif os(visionOS)
        return .visionos
        #elseif os(iOS)
        return .ios
        #elseif os(watchOS)
        return .watchos
        #elseif os(tvOS)
        return .tvos
        #else
        return .macos
        #endif
    }
}