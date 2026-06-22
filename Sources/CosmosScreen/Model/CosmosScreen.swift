import Foundation

/// A serializable description of a screen.
///
/// `CosmosScreen` is a `Sendable`, `Codable` value type. It carries an
/// identifier, an optional title key, a root layout, and an array of
/// components. The host app renders it with `CosmosScreenRenderer` and
/// supplies an action registry for interactive components.
public struct CosmosScreen: Sendable, Codable, Equatable {
    /// Unique identifier for the screen.
    public let id: String

    /// Optional localized title key.
    public let titleKey: String?

    /// Root layout description.
    public let layout: CosmosLayout

    /// Top-level components.
    public let components: [CosmosComponent]

    /// Creates a screen description.
    public init(
        id: String,
        titleKey: String? = nil,
        layout: CosmosLayout = .default,
        components: [CosmosComponent] = []
    ) {
        self.id = id
        self.titleKey = titleKey
        self.layout = layout
        self.components = components
    }
}
