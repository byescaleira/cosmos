import SwiftUI
import CosmosBase

/// A text field atom.
///
/// `CosmosTextField` reads its visibility, enablement, accessibility, and
/// theme from the SwiftUI environment. It accepts a text binding and an
/// optional prompt key through its initializer. Override state and appearance
/// through the `.cosmos*` modifiers.
public struct CosmosTextField: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    @Binding var text: String
    let promptKey: String?
    let secure: Bool

    /// Creates a Cosmos text field atom.
    public init(
        text: Binding<String>,
        prompt promptKey: String? = nil,
        secure: Bool = false
    ) {
        self._text = text
        self.promptKey = promptKey
        self.secure = secure
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var isEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly
    }

    private var resolvedPrompt: String? {
        promptKey.map { configuration.localization.string(for: $0) }
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? resolvedPrompt ?? ""
    }

    public var body: some View {
        if effectiveVisible {
            field
                .font(theme.typography.font(for: theme.textStyle))
                .foregroundStyle(theme.colors.primary)
                .disabled(!isEnabled)
                .controlSizeIfNeeded(theme.controlSize)
                .accessibilityLabel(Text(resolvedAccessibilityLabel))
                .accessibilityHintOrNil(configuration.accessibility.hint)
                .accessibilityHidden(configuration.accessibility.isHidden)
                .accessibilitySortPriority(configuration.accessibility.sortPriority)
                .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    @ViewBuilder
    private var field: some View {
        if secure {
            if let resolvedPrompt {
                SecureField(resolvedPrompt, text: $text)
            } else {
                SecureField("", text: $text)
            }
        } else {
            if let resolvedPrompt {
                TextField(resolvedPrompt, text: $text)
            } else {
                TextField("", text: $text)
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func controlSizeIfNeeded(_ size: CosmosControlSize) -> some View {
        if #available(iOS 15, macOS 11, tvOS 16, watchOS 9, visionOS 1, *) {
            self.controlSize(size.swiftUIValue)
        } else {
            self
        }
    }

    @ViewBuilder
    @available(iOS 14, macOS 11, tvOS 14, watchOS 7, visionOS 1, *)
    func redactedIfNeeded(_ isRedacted: Bool) -> some View {
        if isRedacted {
            self.redacted(reason: .placeholder)
        } else {
            self
        }
    }
}
