import SwiftUI
import CosmosBase

/// A slider atom.
///
/// `CosmosSlider` reads its visibility, enablement, accessibility, and accent
/// color from the SwiftUI environment. It accepts a value binding, bounds, and
/// an optional step through its initializer. Override state and appearance
/// through the `.cosmos*` modifiers.
public struct CosmosSlider: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    @Binding var value: Double
    let bounds: ClosedRange<Double>
    let step: Double?

    /// Creates a Cosmos slider atom.
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...1,
        step: Double? = nil
    ) {
        self._value = value
        self.bounds = bounds
        self.step = step
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var isEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? "Slider"
    }

    public var body: some View {
        if effectiveVisible {
            slider
                .tint(theme.colors.accent)
                .disabled(!isEnabled)
                .accessibilityLabel(Text(resolvedAccessibilityLabel))
                .accessibilityHintOrNil(configuration.accessibility.hint)
                .accessibilityHidden(configuration.accessibility.isHidden)
                .accessibilitySortPriority(configuration.accessibility.sortPriority)
                .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    @ViewBuilder
    private var slider: some View {
        if let step {
            Slider(value: $value, in: bounds, step: step)
        } else {
            Slider(value: $value, in: bounds)
        }
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
