import SwiftUI
import CosmosBase

/// A picker atom rendered as a segmented control.
///
/// `CosmosPicker` reads its visibility, enablement, accessibility, and theme
/// from the SwiftUI environment. It accepts a selection binding and an array of
/// options through its initializer. Override state and appearance through the
/// `.cosmos*` modifiers.
public struct CosmosPicker: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    @Binding var selection: String
    let options: [Option]

    /// Creates a Cosmos picker atom.
    public init(
        selection: Binding<String>,
        options: [Option]
    ) {
        self._selection = selection
        self.options = options
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var isEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? "Picker"
    }

    public var body: some View {
        if effectiveVisible {
            Picker(resolvedAccessibilityLabel, selection: $selection) {
                ForEach(options, id: \.value) { option in
                    Text(option.label)
                        .tag(option.value)
                }
            }
            .pickerStyle(.segmented)
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

extension CosmosPicker {
    /// A labeled option inside a Cosmos picker.
    public struct Option: Sendable, Equatable, Codable {
        public let value: String
        public let label: String

        enum CodingKeys: String, CodingKey {
            case value
            case label
        }

        public init(value: String, label: String) {
            self.value = value
            self.label = label
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
