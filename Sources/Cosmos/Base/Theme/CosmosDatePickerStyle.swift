import Foundation

/// Visual variant selectors for ``CosmosDatePicker``.
///
/// Six built-in `DatePickerStyle` cases via SE-0299, each with a **per-platform availability
/// matrix** (see ``CosmosDatePickerAvailability``): `.automatic` (all where DatePicker exists),
/// `.wheel` (iOS/watchOS/visionOS; NOT macOS), `.graphical` (iOS/macOS/visionOS; NOT watchOS),
/// `.compact` (iOS/macOS/visionOS; NOT watchOS), `.field`/`.stepperField` (macOS-only). `DatePicker`
/// is **type-level unavailable on tvOS** (cannot be referenced at all), so the entire atom + this
/// enum + the applier are guarded `#if !os(tvOS)`. `.hourMinuteAndSecond` is watchOS-exclusive and
/// is guarded with `#if os(watchOS)`, not merely `#available`.
public enum CosmosDatePickerStyle: String, Sendable, Codable, CaseIterable {
    case automatic
    case wheel
    case graphical
    case compact
    case field
    case stepperField
}