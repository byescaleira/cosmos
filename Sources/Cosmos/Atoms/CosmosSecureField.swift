import SwiftUI

/// A secure-field atom wrapping `SecureField` with token-driven tint, typography, focus motion,
/// accessibility, and tracking.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. There is **no**
/// `CosmosSecureFieldStyle` selector — `SecureField` has no conformable style protocol, so
/// `.textFieldStyle(_:)` is effectively a no-op on it; customization is limited to the modifiers
/// applied here (tint/font/accessibility) plus caller modifiers (keyboard/content-type via
/// `#if os(iOS) || os(tvOS)` guards).
///
/// **Platform guard.** `SecureField` is available on all 5 platforms at the Cosmos 26 floor
/// (visionOS not guarded). The keyboard modifiers are forwarded only on iOS/tvOS. `.submitLabel`
/// is available on all 5.
///
/// **Accessibility:** the title/prompt string is the default label; the native field auto-exposes
/// secure editable-text traits and the current text length (not contents) as value. `.textContentType`
/// is forwarded for autofill (e.g. passwords). Dynamic Type via `.font(theme.typography.font(for:))`.
/// Focus via `@FocusState` + `.focused(_:)`.
///
/// **Haptics:** none — typing emits no native haptic and Cosmos adds none (a secure field firing
/// haptics per keystroke would be vestibular-hostile; submit haptic is caller-driven via the
/// submit handler). **Motion:** `focus` — the `.cosmosAnimation(.focus, value: isFocused)`
/// chokepoint drives any focus-dependent chrome; no `valueChange` on the secure binding.
public struct CosmosSecureField<Label: View>: View {
    private let text: Binding<String>
    private let prompt: Text?
    @ViewBuilder private let label: () -> Label

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId
    @FocusState private var isFocused: Bool

    /// Creates a secure field with a custom label view.
    public init(text: Binding<String>, prompt: Text? = nil, @ViewBuilder label: @escaping () -> Label) {
        self.text = text
        self.prompt = prompt
        self.label = label
    }

    public var body: some View {
        if configuration.enable.isVisible {
            SecureField(text: text, prompt: prompt, label: label)
                .tint(theme.colors.accent)
                .font(theme.typography.font(for: theme.textStyle))
                .foregroundStyle(theme.colors.primary)
                .focused($isFocused)
                .applyCosmosAccessibility(configuration.accessibility)
                .cosmosAnimation(.focus, value: isFocused)
                #if os(iOS) || os(tvOS)
                .submitLabel(.done)
                #endif
                .onAppear { trackAppear() }
        } else {
            EmptyView()
        }
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "securefield_appear",
            component: "CosmosSecureField",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}

// MARK: - Convenience inits

extension CosmosSecureField where Label == CosmosLocalizedText {
    /// Creates a secure field from a localized String Catalog key.
    public init(_ titleKey: String, text: Binding<String>, prompt: Text? = nil) {
        self.text = text
        self.prompt = prompt
        self.label = { CosmosLocalizedText(key: titleKey) }
    }
}

extension CosmosSecureField where Label == Text {
    /// Creates a secure field from verbatim (non-localized) title text.
    public init<S: StringProtocol>(verbatim title: S, text: Binding<String>, prompt: Text? = nil) {
        self.text = text
        self.prompt = prompt
        self.label = { Text(verbatim: String(title)) }
    }
}

// MARK: - Previews

#Preview("Secure field") {
    @Previewable @State var text = ""
    VStack(spacing: 16) {
        CosmosSecureField("preview.title", text: $text)
        CosmosSecureField("preview.title", text: $text, prompt: Text("preview.description"))
        CosmosSecureField(verbatim: CosmosMock.sentence(wordCount: 3), text: $text)
    }
    .padding()
}

#Preview("Secure field – dark + accessibility size", traits: .sizeThatFitsLayout) {
    @Previewable @State var text = ""
    CosmosPreviewContainer {
        VStack(spacing: 16) {
            CosmosSecureField("preview.title", text: $text, prompt: Text("preview.description"))
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}