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

    /// The String Catalog `device` variation key for the host platform — one of `iPhone`, `iPad`,
    /// `Mac`, `Apple TV`, `Apple Watch`, `Apple Vision Pro` (WWDC23-10155). iOS is mapped to
    /// `iPhone` (the touch family); the catalog's `iPad` branch, when present, is preferred at
    /// runtime by the compiled-`.lproj` engine, so this compile-time mapping is only used by the
    /// manual `.xcstrings` fallback path for previews/tests.
    public static var localizedTextDeviceKey: String {
        #if os(macOS)
        return "Mac"
        #elseif os(visionOS)
        return "Apple Vision Pro"
        #elseif os(iOS)
        return "iPhone"
        #elseif os(watchOS)
        return "Apple Watch"
        #elseif os(tvOS)
        return "Apple TV"
        #else
        return "Mac"
        #endif
    }
}