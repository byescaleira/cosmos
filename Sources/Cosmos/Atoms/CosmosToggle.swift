import SwiftUI
import CosmosBase

/// A toggle atom.
///
/// `CosmosToggle` reads its visibility, enablement, accessibility, and theme
/// from the SwiftUI environment. It accepts a binding and an optional label key
/// through its initializer. Override state and appearance through the
/// `.cosmos*` modifiers.
public struct CosmosToggle: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    @Binding var isOn: Bool
    let titleKey: String?
    let systemImage: String?

    /// Creates a Cosmos toggle atom.
    public init(
        isOn: Binding<Bool>,
        _ titleKey: String? = nil,
        systemImage: String? = nil
    ) {
        self._isOn = isOn
        self.titleKey = titleKey
        self.systemImage = systemImage
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var isEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly
    }

    private var resolvedTitle: String? {
        titleKey.map { configuration.localization.string(for: $0) }
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? resolvedTitle ?? ""
    }

    public var body: some View {
        if effectiveVisible {
            Toggle(isOn: $isOn) {
                if let titleKey, let systemImage {
                    CosmosLabel(titleKey, systemImage: systemImage)
                } else if let titleKey {
                    Text(resolvedTitle ?? titleKey)
                        .font(theme.typography.font(for: theme.textStyle))
                        .foregroundStyle(theme.colors.primary)
                } else {
                    EmptyView()
                }
            }
            .tint(theme.colors.accent)
            .disabled(!isEnabled)
            .controlSizeIfNeeded(theme.controlSize)
            .accessibilityLabel(Text(resolvedAccessibilityLabel))
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
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
