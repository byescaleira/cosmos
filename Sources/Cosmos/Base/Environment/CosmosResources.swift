import Foundation

/// Access to the compiled Cosmos resource bundle and one-time setup.
///
/// `bundle` is a global `let` of the `Sendable` type `Bundle`, so it is thread-safe without
/// any synchronization (SE-0412). ``prepare()`` registers bundled fonts via the once-token
/// pattern in ``CosmosFont`` — call once at app launch, or let atoms call it lazily.
public enum CosmosResources {
    /// The SwiftPM-generated resource bundle containing compiled String Catalogs and fonts.
    public static let bundle: Bundle = Bundle.module

    /// Registers bundled fonts and performs any other one-time resource setup. Idempotent.
    public static func prepare() {
        CosmosFont.registerIfNeeded()
    }
}