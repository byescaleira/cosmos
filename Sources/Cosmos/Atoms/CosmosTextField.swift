import SwiftUI

/// A text-field atom wrapping `TextField` with token-driven style, tint, typography, focus
/// motion, accessibility, optional submit haptic, and tracking.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. The visual variant
/// comes from ``CosmosTheme/textFieldStyle`` (default `.automatic`).
///
/// **Platform guard.** `TextField` is available on all 5 platforms at the Cosmos 26 floor
/// (visionOS intentionally **not** guarded — it has `TextField` at 1.0). The keyboard modifiers
/// (`.keyboardType`/`.textInputAutocapitalization`) are absent from the macOS/watchOS SDKs and
/// are forwarded only on iOS/tvOS via `#if os(iOS) || os(tvOS)`. `.submitLabel` is available on
/// all 5 (a no-op without a submit keyboard) and needs no guard.
///
/// **Runtime `#available`.** `.bordered` (`BorderedTextFieldStyle`) + `.textInputBorderShape` are
/// `@available(anyAppleOS 27.0)` — the **next** OS above the Cosmos 26 floor (unlike
/// `glassEffect`, which is real OS 26): gated to OS 27 in the applier, falls back to `.automatic`
/// on OS 26, renders on OS 27+ devices. `.roundedBorder` (`RoundedBorderTextFieldStyle`) is
/// deprecated — never used.
///
/// **Customization limits.** `TextFieldStyle._body` is an opaque SPI whose `_Label` has
/// `Body == Never` — a custom style cannot read the text binding, recolor the placeholder directly
/// (only via styling `prompt: Text`), or inspect the native clear button. So the `.cosmos` chrome
/// (padding + `.ultraThinMaterial` background + clipShape + animated focus border) is composed in
/// the atom body where `@FocusState` is visible, **not** via a `TextFieldStyle` conformance.
/// `SecureField` has **no** conformable style protocol at all (``CosmosSecureField``).
///
/// **Accessibility:** the title/prompt string is the default label; the native field auto-exposes
/// editable-text traits and the current text as value. `.textContentType` is forwarded for
/// autofill/QuickType. Dynamic Type via `.font(theme.typography.font(for:))`. Focus via
/// `@FocusState` + `.focused(_:)`.
///
/// **Haptics:** no native haptic for typing; an optional `.selection`-style `.impact(.light)`
/// fires on `.onSubmit` (gated by config + reduce-motion via `.cosmosHaptic`). Default off unless
/// a submit handler is installed.
///
/// **Motion:** `focus` — the focus border emphasis animates through the single chokepoint
/// `.cosmosAnimation(.focus, value: isFocused)` (one `withAnimation` per focus flip). Under
/// reduce-motion the policy substitutes/instantiates. **Do NOT** bind `valueChange` to the text
/// binding (fires every keystroke — noisy/vestibular-hostile); this atom never does.
public struct CosmosTextField<Label: View>: View {
    private let text: Binding<String>
    private let prompt: Text?
    private let axis: Axis?
    private let submitHandler: (() -> Void)?
    @ViewBuilder private let label: () -> Label

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId
    @FocusState private var isFocused: Bool

    /// Creates a text field with a custom label view.
    public init(
        text: Binding<String>,
        prompt: Text? = nil,
        axis: Axis? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.text = text
        self.prompt = prompt
        self.axis = axis
        self.submitHandler = nil
        self.label = label
    }

    /// Creates a text field with a custom label view and a submit handler (fires the submit
    /// haptic + tracking event on submit).
    public init(
        text: Binding<String>,
        prompt: Text? = nil,
        axis: Axis? = nil,
        onSubmit: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.text = text
        self.prompt = prompt
        self.axis = axis
        self.submitHandler = onSubmit
        self.label = label
    }

    public var body: some View {
        if configuration.enable.isVisible {
            field
                .modifier(CosmosTextFieldStyleApplier(style: theme.textFieldStyle))
                .tint(theme.colors.accent)
                .font(theme.typography.font(for: theme.textStyle))
                .foregroundStyle(theme.colors.primary)
                .focused($isFocused)
                .applyCosmosAccessibility(configuration.accessibility)
                .onSubmit { handleSubmit() }
                #if os(iOS) || os(tvOS)
                .submitLabel(.done)
                #endif
                .modifier(CosmosTextFieldFocusBorderModifier(
                    style: theme.textFieldStyle,
                    isFocused: isFocused
                ))
                .onAppear { trackAppear() }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder private var field: some View {
        if let axis {
            TextField(text: text, prompt: prompt, axis: axis, label: label)
        } else {
            TextField(text: text, prompt: prompt, label: label)
        }
    }

    private func handleSubmit() {
        if let submitHandler { submitHandler() }
        // Submit haptic: additive (TextField emits no native haptic on submit).
        configuration.haptics.handler(.impact(weight: .light, intensity: nil))
        configuration.tracking.track(.init(
            name: "textfield_submit",
            component: "CosmosTextField",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .tap
        ))
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "textfield_appear",
            component: "CosmosTextField",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}

// MARK: - Convenience inits

extension CosmosTextField where Label == CosmosLocalizedText {
    /// Creates a text field from a localized String Catalog key.
    public init(
        _ titleKey: String,
        text: Binding<String>,
        prompt: Text? = nil,
        axis: Axis? = nil
    ) {
        self.text = text
        self.prompt = prompt
        self.axis = axis
        self.submitHandler = nil
        self.label = { CosmosLocalizedText(key: titleKey) }
    }
}

extension CosmosTextField where Label == Text {
    /// Creates a text field from verbatim (non-localized) title text.
    public init<S: StringProtocol>(
        verbatim title: S,
        text: Binding<String>,
        prompt: Text? = nil,
        axis: Axis? = nil
    ) {
        self.text = text
        self.prompt = prompt
        self.axis = axis
        self.submitHandler = nil
        self.label = { Text(verbatim: String(title)) }
    }
}

// MARK: - Style resolution + focus chrome

/// Resolves a ``CosmosTextFieldStyle`` to a concrete native `TextFieldStyle`. `.cosmos` resolves
/// to `.plain` (the chrome is composed in the atom body via ``CosmosTextFieldFocusBorderModifier``,
/// where `@FocusState` is visible). `.bordered` is `@available(anyAppleOS 27.0)` (== OS 26) —
/// gated and paired with `.textInputBorderShape(.roundedRectangle)`; below 26 it falls back to
/// `.automatic`.
private struct CosmosTextFieldStyleApplier: ViewModifier {
    let style: CosmosTextFieldStyle
    func body(content: Content) -> some View {
        switch style {
        case .automatic:
            content.textFieldStyle(.automatic)
        case .plain:
            content.textFieldStyle(.plain)
        case .bordered:
            // `.bordered` (`BorderedTextFieldStyle`) + `.textInputBorderShape` are
            // `@available(anyAppleOS 27.0)` — the **next** OS above the Cosmos 26 floor (unlike
            // `glassProminent`, which is real OS 26). Gated to 27; falls back to `.automatic` on
            // OS 26 (the floor) and renders on OS 27+ devices.
            if #available(iOS 27, macOS 27, watchOS 27, tvOS 27, visionOS 27, *) {
                content.textFieldStyle(.bordered).textInputBorderShape(.roundedRectangle)
            } else {
                content.textFieldStyle(.automatic)
            }
        case .cosmos:
            content.textFieldStyle(.plain)
        }
    }
}

/// Composes the `.cosmos` chrome (padding + `.ultraThinMaterial` background + clipShape) and the
/// focus-aware accent border, animated through the single `.cosmosAnimation(.focus, value:)`
/// chokepoint. Only renders for the `.cosmos` style; native styles keep their own chrome and
/// focus ring. `Material` collapses under Reduce Transparency via SwiftUI (config-aware collapse
/// is the caller's responsibility via the theme's material choice).
private struct CosmosTextFieldFocusBorderModifier: ViewModifier {
    let style: CosmosTextFieldStyle
    let isFocused: Bool
    @Environment(\.cosmosTheme) private var theme

    func body(content: Content) -> some View {
        switch style {
        case .cosmos:
            content
                .padding(.horizontal, CosmosSpacingTokens.small)
                .padding(.vertical, CosmosSpacingTokens.xs)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous)
                        .strokeBorder(theme.colors.accent.opacity(isFocused ? 1.0 : 0.0), lineWidth: 1.5)
                )
                .cosmosAnimation(.focus, value: isFocused)
        case .automatic, .plain, .bordered:
            content
        }
    }
}

// MARK: - Previews

#Preview("Text field – styles") {
    @Previewable @State var text = ""
    VStack(spacing: 16) {
        CosmosTextField("preview.title", text: $text)
        CosmosTextField("preview.title", text: $text).cosmosTextFieldStyle(.plain)
        CosmosTextField("preview.title", text: $text).cosmosTextFieldStyle(.bordered)
        CosmosTextField("preview.title", text: $text).cosmosTextFieldStyle(.cosmos)
        CosmosTextField(verbatim: CosmosMock.sentence(wordCount: 3), text: $text, axis: .vertical)
            .cosmosTextFieldStyle(.cosmos)
    }
    .padding()
}

#Preview("Text field – dark + accessibility size", traits: .sizeThatFitsLayout) {
    @Previewable @State var text = ""
    CosmosPreviewContainer {
        VStack(spacing: 16) {
            CosmosTextField("preview.title", text: $text, prompt: Text("preview.description"))
                .cosmosTextFieldStyle(.cosmos)
            CosmosTextField(verbatim: CosmosMock.sentence(wordCount: 4), text: $text)
                .cosmosTextFieldStyle(.cosmos)
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}