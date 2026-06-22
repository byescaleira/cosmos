import SwiftUI
import CosmosBase

/// A date picker atom.
///
/// `CosmosDatePicker` reads its visibility, enablement, accessibility, and
/// theme from the SwiftUI environment. It accepts a selection binding and
/// displayed components through its initializer. Override state and appearance
/// through the `.cosmos*` modifiers.
public struct CosmosDatePicker: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    @Binding var selection: Date
    let displayedComponents: DatePicker.Components
    let label: String?

    /// Creates a Cosmos date picker atom.
    public init(
        selection: Binding<Date>,
        displayedComponents: DatePicker.Components = [.date, .hourAndMinute],
        _ label: String? = nil
    ) {
        self._selection = selection
        self.displayedComponents = displayedComponents
        self.label = label
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var isEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? label ?? "Date picker"
    }

    public var body: some View {
        if effectiveVisible {
            DatePicker(
                resolvedAccessibilityLabel,
                selection: $selection,
                displayedComponents: displayedComponents
            )
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
