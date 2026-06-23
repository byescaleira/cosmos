import SwiftUI
import CosmosBase

/// A labeled control row molecule for forms and settings.
///
/// `CosmosFormRow` pairs a `CosmosLabel` with a trailing control: toggle,
/// picker, stepper, slider, or read-only value. It reads visibility,
/// enablement, and spacing from the environment and accepts caller-owned
/// state through its initializer.
public struct CosmosFormRow: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let titleKey: String
    let systemImage: String?
    let control: Control

    /// Creates a form row with a label and a control kind.
    public init(
        _ titleKey: String,
        systemImage: String? = nil,
        control: Control
    ) {
        self.titleKey = titleKey
        self.systemImage = systemImage
        self.control = control
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var resolvedTitle: String {
        configuration.localization.string(for: titleKey)
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? resolvedTitle
    }

    public var body: some View {
        if effectiveVisible {
            HStack(spacing: theme.spacing.small) {
                label

                Spacer()

                controlContent
            }
            .padding(.vertical, theme.spacing.small)
            .contentShape(Rectangle())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(resolvedAccessibilityLabel))
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    @ViewBuilder
    private var label: some View {
        if let systemImage {
            CosmosLabel(titleKey, systemImage: systemImage)
        } else {
            Text(resolvedTitle)
                .font(theme.typography.font(for: theme.textStyle))
                .foregroundStyle(theme.colors.primary)
        }
    }

    @ViewBuilder
    private var controlContent: some View {
        switch control {
        case .toggle(let isOn):
            CosmosToggle(isOn: isOn)
        case .picker(let selection, let options):
            CosmosPicker(selection: selection, options: options)
        case .stepper(let value, let bounds, let step):
            CosmosStepper(value: value, in: bounds, step: step)
        case .slider(let value, let bounds, let step):
            CosmosSlider(value: value, in: bounds, step: step)
        case .value(let valueKey):
            Text(configuration.localization.string(for: valueKey))
                .font(theme.typography.font(for: theme.textStyle))
                .foregroundStyle(theme.colors.secondary)
        }
    }
}

extension CosmosFormRow {
    /// The trailing control of a form row.
    public enum Control {
        case toggle(Binding<Bool>)
        case picker(Binding<String>, [CosmosPicker.Option])
        case stepper(Binding<Double>, ClosedRange<Double>, Double)
        case slider(Binding<Double>, ClosedRange<Double>, Double?)
        case value(String)
    }

    /// A serializable description of the trailing control kind.
    ///
    /// Runtime values (bindings, options, bounds) are supplied by the renderer
    /// based on this kind and an optional `CosmosFormRowModel.initialValue`.
    public enum ControlKind: String, Sendable, Codable, Equatable, CaseIterable {
        case toggle
        case picker
        case stepper
        case slider
        case value
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
