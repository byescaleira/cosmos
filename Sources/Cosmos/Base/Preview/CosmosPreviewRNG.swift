import Foundation

/// Deterministic SplitMix64 RNG for reproducible previews and tests. Same seed → same sequence
/// on every render, so previews do not churn between canvas refreshes.
///
/// Value type that threads `inout` (the stdlib `RandomNumberGenerator` pattern): the primary API
/// therefore has zero shared state and `Sendable` is derived (no `@unchecked`). The shared
/// convenience source lives behind a `Mutex` in ``CosmosMock`` — never a raw mutable `static var`,
/// per the project's concurrency rules (no `nonisolated(unsafe)` globals, no raw locks).
public struct CosmosPreviewRNG: RandomNumberGenerator, Sendable {
    private var state: UInt64

    public init(seed: UInt64 = CosmosPreview.defaultSeed) {
        // Mix the seed once so sequential seeds (0, 1, 2 …) do not produce correlated streams.
        self.state = seed &+ 0x9E3779B97F4A7C15
    }

    public mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}