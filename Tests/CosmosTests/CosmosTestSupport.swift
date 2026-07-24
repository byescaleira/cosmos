import Foundation

/// Shared test-support helpers used across the per-atom test files.
///
/// `isTvOS` / `isWatchOS` feed Swift Testing's `.disabled(if:)` trait so a platform-gated test
/// stays registered (and is reported as skipped on the unsupported host) rather than invisible —
/// preferred over `#if os()` guards (WWDC24-10179). `ListRow` is the shared `Identifiable` fixture
/// for `CosmosList` / `CosmosSelectableList` construction smoke. Declared `internal` (module
/// scope) so every per-atom file can reach them without redeclaring.
@MainActor
enum CosmosTestSupport {}

// MARK: - Host-platform helpers

var isTvOS: Bool {
    #if os(tvOS)
    return true
    #else
    return false
    #endif
}

var isWatchOS: Bool {
    #if os(watchOS)
    return true
    #else
    return false
    #endif
}

// MARK: - Shared test fixture

struct ListRow: Identifiable, Sendable {
    let id: Int
    let text: String
}