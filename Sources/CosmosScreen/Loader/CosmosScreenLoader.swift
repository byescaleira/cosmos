import Foundation

/// Loads a `CosmosScreen` from serialized data.
///
/// `CosmosScreenLoader` is a small convenience wrapper around `JSONDecoder`.
/// It exists so host apps do not need to remember the decoder configuration
/// when building screens from API responses or local JSON files.
public struct CosmosScreenLoader: Sendable {
    private let decoder: JSONDecoder

    /// Creates a loader with a custom decoder.
    public init(decoder: JSONDecoder = .cosmos) {
        self.decoder = decoder
    }

    /// Decodes a `CosmosScreen` from JSON `Data`.
    ///
    /// - Throws: Any `DecodingError` produced by the underlying decoder.
    public func screen(from data: Data) throws -> CosmosScreen {
        try decoder.decode(CosmosScreen.self, from: data)
    }

    /// Decodes a `CosmosScreen` from a JSON string.
    ///
    /// - Throws: Any `DecodingError` or a UTF-8 encoding failure.
    public func screen(from json: String) throws -> CosmosScreen {
        guard let data = json.data(using: .utf8) else {
            throw CosmosScreenLoaderError.invalidUTF8
        }
        return try screen(from: data)
    }
}

// MARK: - Errors

/// Errors thrown by `CosmosScreenLoader` before decoding begins.
public enum CosmosScreenLoaderError: Error, Sendable {
    /// The provided string could not be encoded as UTF-8.
    case invalidUTF8
}

// MARK: - JSON convenience

public extension JSONDecoder {
    /// A decoder configured for Cosmos screen JSON.
    ///
    /// Uses the standard JSON decoder; `CosmosScreen` models define their own
    /// coding keys. Apps can customize this further if their API uses
    /// snake_case or other conventions.
    static let cosmos: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

public extension JSONEncoder {
    /// An encoder configured for Cosmos screen JSON.
    ///
    /// Matches the snake-case strategy used by `JSONDecoder.cosmos` so that
    /// round-trips to JSON files or APIs are symmetric.
    static let cosmos: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()
}

// MARK: - Encoding

public extension CosmosScreenLoader {
    /// Encodes a `CosmosScreen` to JSON `Data`.
    ///
    /// - Throws: Any `EncodingError` produced by the underlying encoder.
    func encode(screen: CosmosScreen, encoder: JSONEncoder = .cosmos) throws -> Data {
        try encoder.encode(screen)
    }

    /// Encodes a `CosmosScreen` to a JSON string.
    ///
    /// - Throws: Any `EncodingError` or a UTF-8 decoding failure.
    func jsonString(for screen: CosmosScreen, encoder: JSONEncoder = .cosmos) throws -> String {
        let data = try encode(screen: screen, encoder: encoder)
        guard let string = String(data: data, encoding: .utf8) else {
            throw CosmosScreenLoaderError.invalidUTF8
        }
        return string
    }
}
