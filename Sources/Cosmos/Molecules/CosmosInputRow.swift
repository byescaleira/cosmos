import SwiftUI
import CosmosBase

/// A labeled text field molecule.
///
/// `CosmosInputRow` composes a `CosmosLabel` and a `CosmosTextField` into the
/// most common form pattern: a label above an input. It reads visibility,
/// enablement, and spacing from the environment and accepts the caller-owned
/// text binding through its initializer.
public struct CosmosInputRow: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    @Binding var text: String
    let labelKey: String
    let promptKey: String?
    let secure: Bool

    /// Creates a labeled text field row.
    public init(
        text: Binding<String>,
        label labelKey: String,
        prompt promptKey: String? = nil,
        secure: Bool = false
    ) {
        self._text = text
        self.labelKey = labelKey
        self.promptKey = promptKey
        self.secure = secure
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    public var body: some View {
        if effectiveVisible {
            VStack(alignment: .leading, spacing: theme.spacing.small) {
                CosmosLabel(labelKey)
                CosmosTextField(text: $text, prompt: promptKey, secure: secure)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(resolvedAccessibilityLabel))
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label
            ?? configuration.localization.string(for: labelKey)
    }
}

private extension View {
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
