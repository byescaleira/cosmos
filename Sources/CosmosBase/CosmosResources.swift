import Foundation

/// Access to the resource bundle shipped with CosmosBase.
///
/// SwiftPM generates a `Bundle.module` accessor for targets with resources,
/// but that accessor is `internal`. This public wrapper lets host apps and
/// library code use the bundled translations, images, and other assets without
/// leaking package-generated internals.
public enum CosmosResources {
    /// The CosmosBase resource bundle.
    public static let bundle: Bundle = .module
}
