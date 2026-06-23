import SwiftUI
import CosmosBase

/// A search input row molecule.
///
/// `CosmosSearchBar` composes a search icon, a `CosmosTextField`, and an
/// optional clear button into a rounded search bar. It reads visibility,
/// enablement, and theme from the environment and accepts the caller-owned
/// text binding through its initializer.
public struct CosmosSearchBar: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    @Binding var text: String
    let placeholderKey: String
    let onClear: (() -> Void)?

    /// Creates a search bar molecule.
    public init(
        text: Binding<String>,
        placeholder placeholderKey: String = "search.placeholder",
        onClear: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholderKey = placeholderKey
        self.onClear = onClear
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var resolvedPlaceholder: String {
        configuration.localization.string(for: placeholderKey)
    }

    public var body: some View {
        if effectiveVisible {
            HStack(spacing: theme.spacing.small) {
                CosmosIcon("magnifyingglass")
                    .foregroundStyle(theme.colors.secondary)

                CosmosTextField(text: $text, prompt: placeholderKey)

                if !text.isEmpty {
                    CosmosButton(action: clear) {
                        CosmosIcon("xmark.circle.fill")
                            .foregroundStyle(theme.colors.secondary)
                    }
                }
            }
            .padding(theme.spacing.small)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radii.medium))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(resolvedPlaceholder))
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    private func clear() {
        text = ""
        onClear?()
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
