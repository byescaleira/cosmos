import SwiftUI

/// A Cosmos selector for the native `TabRole` passed to `Tab(role:)`.
///
/// `TabRole` tags a `Tab` with a behavioral role inside a ``CosmosTabView``: `.search` (a
/// search-experience tab) and `.prominent` (a visually emphasized tab). Cosmos mirrors the two
/// non-nil roles plus an explicit `.none` (no role → `nil`), so callers do not handle `nil`
/// literally.
///
/// **Why a resolver, not a `.cosmosTabRole(_:)` modifier.** There is **no native `.tabRole(_:)` View
/// modifier** — `TabRole` is a `Tab(role:)` **init parameter**, set when the `Tab` is constructed,
/// not applied after the fact. (Verified in the Xcode 27 `.swiftinterface`: only `Tab(role:)`
/// inits, no `tabRole` modifier, no `tabRole` environment key.) So Cosmos exposes
/// ``CosmosTabRole/nativeRole()``, which returns the native `TabRole?` to pass straight into
/// `Tab(role:)`:
/// ```swift
/// CosmosTabView {
///     Tab("search", systemImage: "magnifyingglass", role: .search.nativeRole()) { … }
///     Tab("featured", systemImage: "star", role: .prominent.nativeRole()) { … }
/// }
/// ```
///
/// **`.prominent` is the first above-floor (Cosmos-27) surface** alongside ``CosmosPickerStyle/tabs``.
/// Native availability (Xcode 27 `.swiftinterface`): `TabRole` itself is
/// `@available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *)` — ≤ the Cosmos 26 floor, so
/// referencing `TabRole` / `.search` is universal. `TabRole.prominent` is
/// `@available(anyAppleOS 27.0, *)` — **OS 27 on all 5 platforms** (above floor). ``nativeRole()``
/// gates `.prominent` with `if #available(iOS 27, macOS 27, tvOS 27, watchOS 27, visionOS 27, *)`
/// and **degrades to `nil`** below OS 27 (the `Tab` renders without the prominent role rather than
/// crashing or failing to compile). `.search` and `.none` need no gate. "Available since Cosmos 27"
/// for `.prominent`; `.search` since Cosmos 26.
public enum CosmosTabRole: String, Sendable, Codable, CaseIterable {
    /// No role — maps to `nil` (the `Tab` is a plain tab).
    case none
    /// A search-experience tab (`TabRole.search`, available since Cosmos 26 on all 5 platforms).
    case search
    /// A visually emphasized tab (`TabRole.prominent`, OS 27 / Cosmos 27 on all 5 platforms;
    /// degrades to `nil` below OS 27).
    case prominent

    /// Resolves to the native `TabRole?` for `Tab(role:)`, gating `.prominent` to `nil` below OS 27.
    public func nativeRole() -> TabRole? {
        switch self {
        case .none:
            return nil
        case .search:
            return .search
        case .prominent:
            // Compile + runtime gate. `TabRole.prominent` is an OS-27 SDK symbol, so the
            // reference itself only exists under Xcode 27 / Swift 6.4 — `#if swift(>=6.4)`
            // compiles it out (→ nil) on Xcode 26 / Swift 6.3, and the `if #available` degrades
            // to nil at runtime on an OS-26 device under Xcode 27.
            #if swift(>=6.4)
            if #available(iOS 27, macOS 27, tvOS 27, watchOS 27, visionOS 27, *) {
                return .prominent
            } else {
                return nil // degrade: no prominent role below OS 27
            }
            #else
            return nil // OS-27 SDK unavailable on this toolchain (Swift < 6.4 / Xcode 26)
            #endif
        }
    }
}

// MARK: - Availability table (pure, platform-agnostic, testable)

/// Pure per-platform availability table for ``CosmosTabRole`` at the Cosmos 26 floor, derived from
/// the Xcode 27 `.swiftinterface`:
/// - `.search` (`TabRole.search`): all 5 platforms (iOS 18 / macOS 15 / tvOS 18 / watchOS 11 /
///   visionOS 2 — all ≤ floor).
/// - `.prominent` (`TabRole.prominent`): `@available(anyAppleOS 27.0, *)` — **all 5 platforms** at
///   OS 27 (above floor; no platform is excluded, unlike ``CosmosPickerStyle/tabs`` which drops
///   watchOS). The table reports the **platform** gate only (true on all 5); the OS-27 version gate
///   is applied at runtime in ``CosmosTabRole/nativeRole()``.
public enum CosmosTabRoleAvailability {
    /// `true` on all 5 platforms (`.search` is ≤ floor).
    public static func searchAvailable(on platform: CosmosPlatform) -> Bool {
        true
    }

    /// `true` on all 5 platforms (`.prominent` is `@available(anyAppleOS 27, *)` — no platform is
    /// excluded; the OS-27 version gate is runtime, in ``CosmosTabRole/nativeRole()``).
    public static func prominentAvailable(on platform: CosmosPlatform) -> Bool {
        true
    }
}

// MARK: - Previews

#Preview("TabRole – .search + .prominent") {
    // .prominent is the first Cosmos-27 surface: it degrades to nil (no role) below OS 27 via
    // nativeRole()'s runtime `if #available` gate. .search is floor-available.
    CosmosTabView {
        Tab("preview.tab.search", systemImage: "magnifyingglass", role: CosmosTabRole.search.nativeRole()) {
            CosmosText("preview.tab.search")
        }
        Tab("preview.tab.featured", systemImage: "star", role: CosmosTabRole.prominent.nativeRole()) {
            CosmosText("preview.tab.featured")
        }
        Tab("preview.tab.settings", systemImage: "gear", role: CosmosTabRole.none.nativeRole()) {
            CosmosText("preview.tab.settings")
        }
    }
}