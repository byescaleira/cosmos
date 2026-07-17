import Foundation

/// Visual variant selectors for ``CosmosPicker``.
///
/// Nine built-in `PickerStyle` cases via SE-0299, each with a **per-platform availability matrix**
/// (see ``CosmosPickerAvailability``). `PickerStyle` is **opaque / native-bridged** (only
/// underscored `_makeView`/`_makeViewList`, no `makeBody`, no `Configuration` associatedtype), so a
/// Cosmos struct cannot conform to it — this enum is consumed by the applier, which maps each case
/// to the native style with a `#if os()` guard and an `.automatic` fallback (never blindly forwards
/// a user-chosen style that is unavailable on the current platform).
///
/// Availability (derived from the Xcode 27 `.swiftinterface`):
/// - `.automatic` (`DefaultPickerStyle`): all 5 platforms.
/// - `.menu` (`MenuPickerStyle`): iOS/macOS/tvOS/visionOS; **not watchOS** (tvOS 17 ≤ the Cosmos 26
///   floor — no runtime gate).
/// - `.segmented` (`SegmentedPickerStyle`): iOS/macOS/tvOS/visionOS; **not watchOS**.
/// - `.wheel` (`WheelPickerStyle`): iOS/watchOS/visionOS; **not macOS, not tvOS**.
/// - `.inline` (`InlinePickerStyle`): all 5 platforms.
/// - `.palette` (`PalettePickerStyle`): iOS/macOS/visionOS (via `*`); **not tvOS, not watchOS**.
/// - `.navigationLink` (`NavigationLinkPickerStyle`): iOS/tvOS/watchOS/visionOS; **not macOS**.
/// - `.radioGroup` (`RadioGroupPickerStyle`): **macOS only**.
/// - `.tabs` (`TabsPickerStyle`): iOS/macOS/tvOS/visionOS at **OS 27** (above the Cosmos 26 floor);
///   **unavailable watchOS**. This is the **first above-floor (Cosmos-27) surface** in the library:
///   the applier guards it with a **combined compile + runtime gate** — `#if !os(watchOS)` (the
///   `TabsPickerStyle` symbol is `@available(watchOS, unavailable)`, so the reference itself must be
///   compile-time-excluded on watchOS) plus `if #available(iOS 27, macOS 27, tvOS 27, visionOS 27,
///   *)` (the style is OS-27-introduced, so on a floor-26 device it degrades to `.automatic`).
///   "Available since Cosmos 27" on iOS/macOS/tvOS/visionOS; never on watchOS.
public enum CosmosPickerStyle: String, Sendable, Codable, CaseIterable {
    case automatic
    case menu
    case segmented
    case wheel
    case inline
    case palette
    case navigationLink
    case radioGroup
    case tabs
}