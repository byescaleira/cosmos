import SwiftUI

/// A date picker atom wrapping `DatePicker` with token-driven style, tint, accessibility,
/// haptics, tracking, and a per-platform style-availability matrix.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. The visual variant
/// comes from ``CosmosTheme/datePickerStyle`` (default `.automatic`).
///
/// **Platform guard.** `DatePicker` is **type-level unavailable on tvOS** (`@available(tvOS,
/// unavailable)` — it cannot be referenced at all), so the entire atom, its inits, and the style
/// applier are guarded `#if !os(tvOS)`. There is no in-place tvOS fallback — app-level code
/// chooses a `CosmosPicker` or a custom navigation-based date chooser there. (The style selector
/// enum + the availability table are platform-agnostic and live outside the guard so they remain
/// testable.) `CosmosPlatform.current` resolves to `.tvos` there for the matrix.
///
/// **Per-style availability.** Each built-in `DatePickerStyle` fragments across platforms (see
/// ``CosmosDatePickerAvailability``): `.wheel` is macOS-unavailable; `.graphical`/`.compact` are
/// watchOS-unavailable; `.field`/`.stepperField` are macOS-only. The applier guards each style with
/// `#if os()` and falls back to `.automatic` where a requested style is unavailable on the current
/// platform (never blanket-applies). `.hourMinuteAndSecond` is watchOS-exclusive and is guarded
/// with `#if os(watchOS)` at the call site (not merely `#available`).
///
/// **Haptics:** `.selection` on selection change (debounced by actual `selection` change — not
/// wheel scroll — because `.cosmosHaptic(_:trigger:)` fires on `selection.wrappedValue` change;
/// `DatePicker` emits no native haptic so this is additive), gated by ``CosmosHapticsPolicy``.
/// **Motion:** `valueChange` — but, mirroring the Picker rule, a Cosmos motion kind is NOT applied
/// directly to the `DatePicker` (it would desync the native wheel/graphical scroll + popover, which
/// are system-controlled and auto-respect Reduce Motion). `.cosmosContentTransition(.numeric)` is
/// applied for the compact/field text reflow (a no-op where irrelevant); callers may add
/// `.cosmosAnimation(.valueChange, value:)` to *dependent* content.
#if !os(tvOS)
public struct CosmosDatePicker<Label: View>: View {
    private let selection: Binding<Date>
    private let range: Range
    private let displayedComponents: DatePickerComponents
    @ViewBuilder private let label: () -> Label

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    private enum Range {
        case none
        case closed(ClosedRange<Date>)
        case from(PartialRangeFrom<Date>)
        case through(PartialRangeThrough<Date>)
    }

    /// Creates a date picker with a custom label view.
    public init(
        selection: Binding<Date>,
        displayedComponents: DatePickerComponents = [.hourAndMinute, .date],
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.selection = selection
        self.range = .none
        self.displayedComponents = displayedComponents
        self.label = label
    }

    /// Creates a date picker constrained to a closed date range, with a custom label view.
    public init(
        selection: Binding<Date>,
        in range: ClosedRange<Date>,
        displayedComponents: DatePickerComponents = [.hourAndMinute, .date],
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.selection = selection
        self.range = .closed(range)
        self.displayedComponents = displayedComponents
        self.label = label
    }

    /// Creates a date picker constrained to a one-sided `PartialRangeFrom` range.
    public init(
        selection: Binding<Date>,
        in range: PartialRangeFrom<Date>,
        displayedComponents: DatePickerComponents = [.hourAndMinute, .date],
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.selection = selection
        self.range = .from(range)
        self.displayedComponents = displayedComponents
        self.label = label
    }

    /// Creates a date picker constrained to a one-sided `PartialRangeThrough` range.
    public init(
        selection: Binding<Date>,
        in range: PartialRangeThrough<Date>,
        displayedComponents: DatePickerComponents = [.hourAndMinute, .date],
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.selection = selection
        self.range = .through(range)
        self.displayedComponents = displayedComponents
        self.label = label
    }

    public var body: some View {
        if configuration.enable.isVisible {
            datePicker
                .modifier(CosmosDatePickerStyleApplier(style: theme.datePickerStyle))
                .controlSize(theme.controlSize.controlSize)
                .tint(theme.colors.accent)
                .applyCosmosAccessibility(configuration.accessibility)
                .cosmosContentTransition(.numeric)
                .cosmosHaptic(.selection, trigger: selection.wrappedValue)
                .onAppear { trackAppear() }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder private var datePicker: some View {
        switch range {
        case .none:
            DatePicker(selection: selection, displayedComponents: displayedComponents, label: label)
        case .closed(let r):
            DatePicker(selection: selection, in: r, displayedComponents: displayedComponents, label: label)
        case .from(let r):
            DatePicker(selection: selection, in: r, displayedComponents: displayedComponents, label: label)
        case .through(let r):
            DatePicker(selection: selection, in: r, displayedComponents: displayedComponents, label: label)
        }
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "datepicker_appear",
            component: "CosmosDatePicker",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}

// MARK: - Convenience inits

extension CosmosDatePicker where Label == CosmosLocalizedText {
    /// Creates a date picker from a localized String Catalog key.
    public init(
        _ titleKey: String,
        selection: Binding<Date>,
        displayedComponents: DatePickerComponents = [.hourAndMinute, .date]
    ) {
        self.selection = selection
        self.range = .none
        self.displayedComponents = displayedComponents
        self.label = { CosmosLocalizedText(key: titleKey) }
    }
}

extension CosmosDatePicker where Label == Text {
    /// Creates a date picker from verbatim (non-localized) title text.
    public init<S: StringProtocol>(
        verbatim title: S,
        selection: Binding<Date>,
        displayedComponents: DatePickerComponents = [.hourAndMinute, .date]
    ) {
        self.selection = selection
        self.range = .none
        self.displayedComponents = displayedComponents
        self.label = { Text(verbatim: String(title)) }
    }
}

// MARK: - Per-platform availability table (pure, platform-agnostic, testable)
#endif // !os(tvOS) — atom struct + inits above; availability table below is platform-agnostic.

/// Pure per-platform availability table for ``CosmosDatePickerStyle`` at the Cosmos 26 floor.
/// `DatePicker` is type-level unavailable on tvOS, so every style returns `false` there.
///
/// Derived from the Xcode 27 `.swiftinterface`:
/// - `.automatic` (`DefaultDatePickerStyle`): iOS/macOS/watchOS/visionOS.
/// - `.wheel` (`WheelDatePickerStyle`): iOS/watchOS/visionOS; **not macOS**.
/// - `.graphical` (`GraphicalDatePickerStyle`): iOS/macOS/visionOS; **not watchOS**.
/// - `.compact` (`CompactDatePickerStyle`): iOS/macOS/visionOS; **not watchOS**.
/// - `.field`/`.stepperField` (`FieldDatePickerStyle`/`StepperFieldDatePickerStyle`): **macOS only**.
public enum CosmosDatePickerAvailability {
    public static func isAvailable(_ style: CosmosDatePickerStyle, on platform: CosmosPlatform) -> Bool {
        switch platform {
        case .tvos:
            return false
        case .ios:
            switch style {
            case .automatic, .wheel, .graphical, .compact: return true
            case .field, .stepperField: return false
            }
        case .macos:
            switch style {
            case .automatic, .graphical, .compact, .field, .stepperField: return true
            case .wheel: return false
            }
        case .watchos:
            switch style {
            case .automatic, .wheel: return true
            case .graphical, .compact, .field, .stepperField: return false
            }
        case .visionos:
            switch style {
            case .automatic, .wheel, .graphical, .compact: return true
            case .field, .stepperField: return false
            }
        }
    }

    /// Resolves a requested style to itself when available on `platform`, else `.automatic`.
    public static func resolve(_ style: CosmosDatePickerStyle, on platform: CosmosPlatform) -> CosmosDatePickerStyle {
        isAvailable(style, on: platform) ? style : .automatic
    }
}

// MARK: - Style resolution (native platforms — tvOS guard at file level below)

#if !os(tvOS)
/// Resolves a ``CosmosDatePickerStyle`` to a concrete `DatePickerStyle`, guarding each style with
/// `#if os()` for its per-platform availability and falling back to `.automatic` where the
/// requested style is unavailable on the current platform (never blanket-applies).
private struct CosmosDatePickerStyleApplier: ViewModifier {
    let style: CosmosDatePickerStyle
    func body(content: Content) -> some View {
        switch style {
        case .automatic:
            content.datePickerStyle(.automatic)
        case .wheel:
            #if os(macOS)
            // .wheel is unavailable on macOS — fall back to .automatic.
            content.datePickerStyle(.automatic)
            #else
            content.datePickerStyle(.wheel)
            #endif
        case .graphical:
            #if os(watchOS)
            // .graphical is unavailable on watchOS — fall back to .automatic.
            content.datePickerStyle(.automatic)
            #else
            content.datePickerStyle(.graphical)
            #endif
        case .compact:
            #if os(watchOS)
            // .compact is unavailable on watchOS — fall back to .automatic.
            content.datePickerStyle(.automatic)
            #else
            content.datePickerStyle(.compact)
            #endif
        case .field:
            #if os(macOS)
            content.datePickerStyle(.field)
            #else
            // .field is macOS-only — fall back to .automatic elsewhere.
            content.datePickerStyle(.automatic)
            #endif
        case .stepperField:
            #if os(macOS)
            content.datePickerStyle(.stepperField)
            #else
            // .stepperField is macOS-only — fall back to .automatic elsewhere.
            content.datePickerStyle(.automatic)
            #endif
        }
    }
}
#endif

// MARK: - Previews (DatePicker is unavailable on tvOS — guard the preview blocks)

#if !os(tvOS)
#Preview("Date picker – styles") {
    @Previewable @State var date = Date()
    VStack(spacing: 16) {
        CosmosDatePicker("preview.title", selection: $date)
        CosmosDatePicker(selection: $date) { CosmosText("preview.description") }
            .cosmosDatePickerStyle(.graphical)
        CosmosDatePicker(selection: $date) { Label("preview.title", systemImage: "calendar") }
            .cosmosDatePickerStyle(.compact)
    }
    .padding()
}

#Preview("Date picker – ranged + dark", traits: .sizeThatFitsLayout) {
    @Previewable @State var date = Date()
    let range = (Date()...Date(timeIntervalSinceNow: 365 * 24 * 3600))
    CosmosPreviewContainer {
        VStack(spacing: 16) {
            CosmosDatePicker(selection: $date, in: range) { CosmosText("preview.description") }
            CosmosDatePicker(verbatim: CosmosMock.sentence(), selection: $date)
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}
#endif