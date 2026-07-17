import Foundation

/// Visual variant selectors for ``CosmosTabView``.
///
/// Six built-in `TabViewStyle` cases via SE-0299, each with a **per-platform availability matrix**
/// (see ``CosmosTabViewAvailability``). `TabViewStyle` is **opaque / native-bridged** (only
/// underscored `_makeView`/`_makeViewList`, no `makeBody`, no `Configuration` associatedtype), so a
/// Cosmos struct cannot conform to it — this enum is consumed by the applier, which maps each case
/// to the native style with a `#if os()` guard and an `.automatic` fallback (never blindly forwards
/// a user-chosen style that is unavailable on the current platform).
///
/// Availability (derived from the Xcode 27 `.swiftinterface`):
/// - `.automatic` (`DefaultTabViewStyle`): all 5 platforms (iOS 14 / macOS 11 / tvOS 14 / watchOS 7,
///   visionOS implicit — all ≤ the Cosmos 26 floor).
/// - `.page` (`PageTabViewStyle`): iOS/tvOS/watchOS/visionOS; **not macOS**.
/// - `.sidebarAdaptable` (`SidebarAdaptableTabViewStyle`): iOS/macOS/tvOS/visionOS; **not watchOS**.
/// - `.tabBarOnly` (`TabBarOnlyTabViewStyle`): iOS/macOS/tvOS/visionOS; **not watchOS**.
/// - `.verticalPage` (`VerticalPageTabViewStyle`): **watchOS only** (watchOS 10; renamed from the
///   deprecated `CarouselTabViewStyle` — never reference Carousel).
/// - `.grouped` (`GroupedTabViewStyle`): **macOS only** (macOS 15).
///
/// All version bounds are ≤ the Cosmos 26 floor → the guards are compile-time `#if os()` only
/// (no runtime `if #available`). `CarouselTabViewStyle` is `@available(... deprecated: 100000.0,
/// renamed: "VerticalTabViewStyle")` and is **never** referenced — `.verticalPage` is its
/// replacement.
public enum CosmosTabViewStyle: String, Sendable, Codable, CaseIterable {
    case automatic
    case page
    case sidebarAdaptable
    case tabBarOnly
    case verticalPage
    case grouped
}