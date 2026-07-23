import SwiftUI

/// A picker atom wrapping `Picker` with a token-driven (per-platform-safe) style, tint,
/// accessibility, haptics, tracking — and a per-platform style-availability matrix.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. The visual variant
/// comes from ``CosmosTheme/pickerStyle`` (default `.automatic`).
///
/// **Why a wrap-view, not a style conformance.** `PickerStyle` is **opaque / native-bridged** — its
/// only members are underscored `_makeView`/`_makeViewList`; there is no `makeBody` and no
/// `Configuration` associatedtype, so a Cosmos struct cannot meaningfully conform. Cosmos instead
/// wraps a `View` that configures a native `Picker` and applies a built-in style via the applier.
///
/// **Per-style availability.** Each built-in `PickerStyle` fragments across platforms (see
/// ``CosmosPickerAvailability``). The applier guards each case with `#if os()` and falls back to
/// `.automatic` where a requested style is unavailable on the current platform — never blindly
/// forwards a user-chosen style. All version bounds are ≤ the Cosmos 26 floor, so the guards are
/// compile-time `#if os()` only (no runtime `if #available`); `.menu`'s tvOS 17 bound is below the
/// floor. The **one exception** is `.tabs` (`TabsPickerStyle`, OS 27) — the first above-floor
/// (Cosmos-27) surface — which needs a **combined compile + runtime gate** in the applier (see
/// ``CosmosPickerStyle``).
///
/// **Platform guard.** None at the type level — `Picker` is available on all 5 platforms (via the
/// `*` wildcard). Default style differs per platform (macOS/iOS ≈ menu, watchOS ≈ wheel/list,
/// tvOS ≈ menu); `.automatic` respects that.
///
/// **Customization limits.** No customization-via-protocol path — cannot customize wheel/segment/
/// menu chrome, option-row layout beyond the content closure, placeholder (`Picker` has none), or
/// clear button. Per-option content + `.tag(_:)`/`.tags(_:)` are caller-driven inside the content
/// closure (the atom forwards the closure unchanged).
///
/// **Accessibility:** the `label` becomes the VoiceOver label; VoiceOver announces the current
/// (tagged) selection as the value. For an explicit value, set `.cosmosAccessibilityValue` at the
/// call site (the atom cannot inspect the opaque content closure to mirror it). Do NOT add
/// `.isButton` (native styles set appropriate traits). Dynamic Type scales the label/per-option Text.
///
/// **Haptics:** `.selection` on selection change (debounced by the actual `selection.wrappedValue`
/// change via `.cosmosHaptic(_:trigger:)`, gated through ``CosmosHapticsPolicy`` — no-op on
/// platforms without haptic hardware). `Picker` emits no native selection haptic, so this is
/// additive. `SelectionValue` is constrained `Sendable` so it can drive the `Equatable & Sendable`
/// haptic trigger.
///
/// **Motion:** `valueChange` — but, like ``CosmosDatePicker``, a Cosmos motion kind is **not**
/// applied to the `Picker` itself (its native selection animation — wheel spin, segment slide, menu
/// highlight — is system-driven and would desync under a differing curve). Callers may add
/// `.cosmosAnimation(.valueChange, value:)` to *dependent* surrounding content. `tabSwitch` is
/// reserved for ``CosmosTabView``.
public struct CosmosPicker<Label: View, SelectionValue: Hashable & Sendable, Content: View>: View {
    private let selection: Binding<SelectionValue>
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let label: () -> Label

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    /// Creates a picker with a custom label view and custom per-option content.
    public init(
        selection: Binding<SelectionValue>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.selection = selection
        self.content = content
        self.label = label
    }

    public var body: some View {
        if configuration.enable.isVisible {
            Picker(selection: selection, content: content, label: label)
                .modifier(CosmosPickerStyleApplier(style: theme.pickerStyle))
                .controlSize(theme.controlSize.controlSize)
                .tint(theme.colors.accent)
                .applyCosmosAccessibility(configuration.accessibility)
                .cosmosHaptic(.selection, trigger: selection.wrappedValue)
                .onChange(of: selection.wrappedValue) { _, _ in trackChange() }
                .onAppear { trackAppear() }
        } else {
            EmptyView()
        }
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "picker_appear",
            component: "CosmosPicker",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }

    private func trackChange() {
        configuration.tracking.track(.init(
            name: "picker_change",
            component: "CosmosPicker",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .valueChange
        ))
    }
}

// MARK: - Convenience inits

extension CosmosPicker where Label == CosmosLocalizedText {
    /// Creates a picker from a localized String Catalog key, with custom per-option content.
    public init(
        _ titleKey: String,
        selection: Binding<SelectionValue>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.selection = selection
        self.content = content
        self.label = { CosmosLocalizedText(key: titleKey) }
    }
}

extension CosmosPicker where Label == Text {
    /// Creates a picker from verbatim (non-localized) title text, with custom per-option content.
    public init<S: StringProtocol>(
        verbatim title: S,
        selection: Binding<SelectionValue>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.selection = selection
        self.content = content
        self.label = { Text(verbatim: String(title)) }
    }
}

extension CosmosPicker where Label == SwiftUI.Label<CosmosLocalizedText, Image> {
    /// Creates a picker from a localized String Catalog key + system image, with custom per-option
    /// content (`Label` header). The generic param is named `Label`, which shadows SwiftUI's
    /// `Label` struct — so the constraint and the constructor are qualified `SwiftUI.Label`.
    public init(
        _ titleKey: String,
        systemImage: String,
        selection: Binding<SelectionValue>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.selection = selection
        self.content = content
        self.label = { SwiftUI.Label { CosmosLocalizedText(key: titleKey) } icon: { Image(systemName: systemImage) } }
    }
}

// MARK: - Per-platform availability table (pure, platform-agnostic, testable)

/// Pure per-platform availability table for ``CosmosPickerStyle`` at the Cosmos 26 floor.
///
/// Derived from the Xcode 27 `.swiftinterface` `@available` clauses:
/// - `.automatic` (`DefaultPickerStyle`): all 5 platforms.
/// - `.menu` (`MenuPickerStyle`): iOS/macOS/tvOS/visionOS; **not watchOS**.
/// - `.segmented` (`SegmentedPickerStyle`): iOS/macOS/tvOS/visionOS; **not watchOS**.
/// - `.wheel` (`WheelPickerStyle`): iOS/watchOS/visionOS; **not macOS, not tvOS**.
/// - `.inline` (`InlinePickerStyle`): all 5 platforms.
/// - `.palette` (`PalettePickerStyle`): iOS/macOS/visionOS (via `*`); **not tvOS, not watchOS**.
/// - `.navigationLink` (`NavigationLinkPickerStyle`): iOS/tvOS/watchOS/visionOS; **not macOS**.
/// - `.radioGroup` (`RadioGroupPickerStyle`): **macOS only**.
/// - `.tabs` (`TabsPickerStyle`): iOS/macOS/tvOS/visionOS (OS 27, above floor); **not watchOS**
///   (`@available(watchOS, unavailable)`). The table reports the **platform** gate only — the
///   OS-27 version gate is applied at runtime in the applier (the table is host-agnostic and cannot
///   know the OS version), so `isAvailable(.tabs, on: .ios)` is `true` meaning "usable on iOS at
///   all (on OS 27+)"; `resolve(.tabs, on:)` returns `.tabs` and the applier degrades to
///   `.automatic` below OS 27.
public enum CosmosPickerAvailability {
    public static func isAvailable(_ style: CosmosPickerStyle, on platform: CosmosPlatform) -> Bool {
        switch platform {
        case .ios, .visionos:
            // visionOS gets every style via the `*` wildcard that the iOS interface declares.
            switch style {
            case .automatic, .menu, .segmented, .wheel, .inline, .palette, .navigationLink, .tabs:
                return true
            case .radioGroup:
                return false // radioGroup is macOS-only (unavailable on iOS + visionOS)
            }
        case .macos:
            switch style {
            case .automatic, .menu, .segmented, .inline, .palette, .radioGroup, .tabs:
                return true
            case .wheel, .navigationLink:
                return false
            }
        case .tvos:
            switch style {
            case .automatic, .menu, .segmented, .inline, .navigationLink, .tabs:
                return true
            case .wheel, .palette, .radioGroup:
                return false
            }
        case .watchos:
            switch style {
            case .automatic, .wheel, .inline, .navigationLink:
                return true
            case .menu, .segmented, .palette, .radioGroup, .tabs:
                return false // .tabs is @available(watchOS, unavailable)
            }
        }
    }

    /// Resolves a requested style to itself when available on `platform`, else `.automatic`.
    public static func resolve(_ style: CosmosPickerStyle, on platform: CosmosPlatform) -> CosmosPickerStyle {
        isAvailable(style, on: platform) ? style : .automatic
    }
}

// MARK: - Style resolution

/// Resolves a ``CosmosPickerStyle`` to a concrete `PickerStyle`, guarding each case with `#if os()`
/// for its per-platform availability and falling back to `.automatic` where the requested style is
/// unavailable on the current platform (never blanket-applies). The `.tabs` case is the first
/// above-floor surface and uses a **combined compile + runtime gate**: `#if !os(watchOS)` (the
/// `TabsPickerStyle` symbol is itself `@available(watchOS, unavailable)`) plus
/// `if #available(iOS 27, macOS 27, tvOS 27, visionOS 27, *)` (OS-27-introduced → `.automatic`
/// below OS 27).
private struct CosmosPickerStyleApplier: ViewModifier {
    let style: CosmosPickerStyle
    func body(content: Content) -> some View {
        switch style {
        case .automatic:
            content.pickerStyle(.automatic)
        case .menu:
            // iOS/macOS/tvOS/visionOS; not watchOS.
            #if os(watchOS)
            content.pickerStyle(.automatic)
            #else
            content.pickerStyle(.menu)
            #endif
        case .segmented:
            // iOS/macOS/tvOS/visionOS; not watchOS.
            #if os(watchOS)
            content.pickerStyle(.automatic)
            #else
            content.pickerStyle(.segmented)
            #endif
        case .wheel:
            // iOS/watchOS/visionOS; not macOS, not tvOS.
            #if os(iOS) || os(watchOS) || os(visionOS)
            content.pickerStyle(.wheel)
            #else
            content.pickerStyle(.automatic)
            #endif
        case .inline:
            // All 5 platforms.
            content.pickerStyle(.inline)
        case .palette:
            // iOS/macOS/visionOS; not tvOS, not watchOS.
            #if os(tvOS) || os(watchOS)
            content.pickerStyle(.automatic)
            #else
            content.pickerStyle(.palette)
            #endif
        case .navigationLink:
            // iOS/tvOS/watchOS/visionOS; not macOS.
            #if os(macOS)
            content.pickerStyle(.automatic)
            #else
            content.pickerStyle(.navigationLink)
            #endif
        case .radioGroup:
            // macOS only.
            #if os(macOS)
            content.pickerStyle(.radioGroup)
            #else
            content.pickerStyle(.automatic)
            #endif
        case .tabs:
            // iOS/macOS/tvOS/visionOS at OS 27 (above the Cosmos 26 floor); unavailable watchOS.
            // Three-way compile + runtime gate: watchOS never references the symbol
            // (`TabsPickerStyle` is @available(watchOS, unavailable)); the symbol is OS-27 SDK
            // only, so `#elseif swift(>=6.4)` compiles it in under Xcode 27 / Swift 6.4 and out
            // (→ .automatic) on Xcode 26 / Swift 6.3; under Xcode 27, `if #available(...27...)`
            // further degrades to .automatic on an OS-26 device.
            #if os(watchOS)
            content.pickerStyle(.automatic)
            #elseif swift(>=6.4)
            if #available(iOS 27, macOS 27, tvOS 27, visionOS 27, *) {
                content.pickerStyle(.tabs)
            } else {
                content.pickerStyle(.automatic)
            }
            #else
            content.pickerStyle(.automatic) // OS-27 SDK unavailable on this toolchain (Swift < 6.4)
            #endif
        }
    }
}

// MARK: - Previews

#Preview("Picker – styles") {
    @Previewable @State var option = "a"
    VStack(spacing: 16) {
        CosmosPicker("preview.title", selection: $option) {
            Text("A").tag("a")
            Text("B").tag("b")
            Text("C").tag("c")
        }
        CosmosPicker("preview.title", selection: $option) {
            Text("A").tag("a"); Text("B").tag("b")
        }
        .cosmosPickerStyle(.segmented)
        CosmosPicker("preview.title", systemImage: "gear", selection: $option) {
            Text("A").tag("a"); Text("B").tag("b")
        }
        .cosmosPickerStyle(.menu)
    }
    .padding()
}

#Preview("Picker – .tabs (OS 27)", traits: .sizeThatFitsLayout) {
    @Previewable @State var option = "a"
    // .tabs is the first above-floor (Cosmos-27) surface: degrades to .automatic below OS 27 /
    // on watchOS via the applier's combined compile + runtime gate.
    CosmosPicker("preview.title", selection: $option) {
        Text("A").tag("a"); Text("B").tag("b"); Text("C").tag("c")
    }
    .cosmosPickerStyle(.tabs)
    .padding()
}

#Preview("Picker – dark + accessibility size", traits: .sizeThatFitsLayout) {
    @Previewable @State var option = "a"
    CosmosPreviewContainer {
        VStack(spacing: 16) {
            CosmosPicker(verbatim: CosmosMock.sentence(wordCount: 2), selection: $option) {
                Text("A").tag("a"); Text("B").tag("b")
            }
            .cosmosPickerStyle(.segmented)
            CosmosPicker(selection: $option) {
                Text("A").tag("a"); Text("B").tag("b")
            } label: {
                Label("preview.title", systemImage: "circle.grid.2x2")
            }
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}