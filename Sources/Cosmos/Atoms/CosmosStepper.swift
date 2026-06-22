import SwiftUI
import CosmosBase

/// A stepper atom.
///
/// `CosmosStepper` reads its visibility, enablement, accessibility, and theme
/// from the SwiftUI environment. It accepts a value binding, bounds, and an
/// optional label through its initializer. Override state and appearance through
/// the `.cosmos*` modifiers.
public struct CosmosStepper: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    @Binding var value: Double
    let bounds: ClosedRange<Double>
    let step: Double
    let label: String?

    /// Creates a Cosmos stepper atom with a `Double` binding.
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double>,
        step: Double = 1,
        _ label: String? = nil
    ) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.label = label
    }

    /// Creates a Cosmos stepper atom with an `Int` binding.
    public init(
        value: Binding<Int>,
        in bounds: ClosedRange<Int>,
        step: Int = 1,
        _ label: String? = nil
    ) {
        self._value = Binding(
            get: { Double(value.wrappedValue) },
            set: { value.wrappedValue = Int($0) }
        )
        self.bounds = Double(bounds.lowerBound)...Double(bounds.upperBound)
        self.step = Double(step)
        self.label = label
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var isEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? label ?? "Stepper"
    }

    public var body: some View {
        if effectiveVisible {
            Stepper(
                value: $value,
                in: bounds,
                step: step
            ) {
                if let label {
                    Text(configuration.localization.string(for: label))
                        .font(theme.typography.font(for: theme.textStyle))
                        .foregroundStyle(theme.colors.primary)
                }
            }
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
