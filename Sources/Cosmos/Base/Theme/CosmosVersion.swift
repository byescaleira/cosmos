import Foundation

/// Cosmos version, aligned 1:1 with the host OS version.
///
/// A Cosmos major version is the same number as the OS major it targets: **Cosmos 26**
/// is built on the iOS/macOS/tvOS/watchOS/visionOS 26 SDKs and requires OS 26 at runtime.
/// There is no separate version number to maintain — the library version *is* the OS
/// version, so API availability (`@available(iOS 26, *)`) doubles as Cosmos API versioning.
/// See `VERSIONING.md` for the full policy.
///
/// `CosmosVersion` also exists as a **runtime design-language pin** in `CosmosTheme`:
/// apps may fix `theme.version` to render an older design language even when running on
/// a newer OS, mirroring how SwiftUI's appearance adapts per OS but can be pinned.
public enum CosmosVersion: Int, Sendable, Codable, CaseIterable {
    /// Cosmos 26 — targets OS 26 (Liquid Glass era). The baseline of this library.
    case cosmos26 = 26

    /// The version this build of Cosmos targets. The package's deployment target is OS 26,
    /// so the baseline is `.cosmos26`. Future Cosmos majors will add cases as the OS evolves.
    public static let current: CosmosVersion = .cosmos26

    /// The matching OS major version, for `#available`-aligned reasoning.
    public var osMajor: Int { rawValue }
}