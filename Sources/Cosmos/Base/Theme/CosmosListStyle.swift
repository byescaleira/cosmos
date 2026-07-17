import Foundation

/// Visual variant selectors for ``CosmosList``.
///
/// Nine built-in `ListStyle` cases via SE-0299, each with a **per-platform availability matrix**
/// (see ``CosmosListAvailability``). `ListStyle` is **opaque / native-bridged** (only underscored
/// `_makeView`/`_makeViewList`, no `makeBody`), so a Cosmos struct cannot conform to it — this enum
/// is consumed by the applier, which maps each case to the native style with a `#if os()` guard and
/// an `.automatic` fallback (never blindly forwards a style unavailable on the current platform).
///
/// Availability (derived from the Xcode 27 `.swiftinterface`):
/// - `.automatic` (`DefaultListStyle`): all 5 platforms.
/// - `.plain` (`PlainListStyle`): all 5 platforms.
/// - `.grouped` (`GroupedListStyle`): iOS/tvOS/visionOS; **not macOS, not watchOS**.
/// - `.inset` (`InsetListStyle`): iOS/macOS/visionOS; **not tvOS, not watchOS**.
/// - `.insetGrouped` (`InsetGroupedListStyle`): iOS/visionOS; **not macOS, not tvOS, not watchOS**
///   (Xcode 27 correction: it IS visionOS-available via the `*` wildcard — the old
///   "visionOS-unavailable" claim is outdated).
/// - `.sidebar` (`SidebarListStyle`): iOS/macOS/visionOS; **not tvOS, not watchOS**.
/// - `.bordered` (`BorderedListStyle`): **macOS only**.
/// - `.elliptical` (`EllipticalListStyle`): **watchOS only**.
/// - `.carousel` (`CarouselListStyle`): **watchOS only**.
///
/// All version bounds are ≤ the Cosmos 26 floor → the guards are compile-time `#if os()` only
/// (no runtime `if #available`). `AccessoryBarListStyle` does not exist in the Xcode 27 SDK and is
/// not exposed.
public enum CosmosListStyle: String, Sendable, Codable, CaseIterable {
    case automatic
    case plain
    case grouped
    case inset
    case insetGrouped
    case sidebar
    case bordered
    case elliptical
    case carousel
}