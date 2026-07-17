import Foundation

/// Access to the compiled Cosmos resource bundle.
///
/// `bundle` is a global `let` of the `Sendable` type `Bundle`, so it is thread-safe without any
/// synchronization (SE-0412). The bundle carries the compiled String Catalog
/// (`Localizable.xcstrings`); Cosmos ships **no bundled fonts** — register custom fonts in your
/// app and pass the PostScript name to ``CosmosTheme/withCustomFont(_:)``.
public enum CosmosResources {
    /// The SwiftPM-generated resource bundle containing compiled String Catalogs.
    public static let bundle: Bundle = Bundle.module
}