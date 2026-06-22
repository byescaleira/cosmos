import SwiftUI
import CosmosBase

/// The smallest interactive unit in Cosmos.
///
/// `CosmosButton` reads its state, configuration, and theme from the SwiftUI
/// environment. It accepts only content through its initializers: either a
/// localized title key or a custom label view. Override enablement, loading,
/// accessibility, control size, and theme on the surrounding view hierarchy
/// using the `.cosmos*` modifiers.
public struct CosmosButton<Label: View>: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let action: () throws -> Void
    let label: Label

    /// Creates a Cosmos button with a custom label.
    public init(
        action: @escaping () throws -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }

    private var effectiveEnabled: Bool {
        configuration.enable.isEnabled
            && !configuration.enable.isReadOnly
            && !configuration.loading.isLoading
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    public var body: some View {
        if effectiveVisible {
            Button(action: performAction) {
                content
            }
            .disabled(!effectiveEnabled)
            .buttonStyle(theme.buttonStyle)
            .controlSizeIfNeeded(theme.controlSize)
            .padding(theme.spacing.value(for: theme.padding))
            .accessibilityLabelOrNil(configuration.accessibility.label)
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    @ViewBuilder
    private var content: some View {
        if configuration.loading.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        } else {
            label
        }
    }

    private func performAction() {
        guard effectiveEnabled else { return }

        configuration.log.log(
            CosmosLogEvent(
                level: .info,
                message: "Button tapped",
                source: "CosmosButton"
            )
        )

        do {
            try action()
        } catch let caughtError {
            configuration.error.report(
                caughtError,
                source: "CosmosButton.performAction",
                metadata: [:]
            )
        }
    }
}

// MARK: - Convenience initializers

extension CosmosButton where Label == Text {
    /// Creates a Cosmos button that displays a localized string.
    ///
    /// The title key is resolved through the environment's localization
    /// configuration, falling back to the raw key when no translation is found.
    public init(
        _ titleKey: String,
        action: @escaping () throws -> Void
    ) {
        self.init(action: action) {
            Text(titleKey)
        }
    }
}

// MARK: - SwiftUI button style mapping

private extension View {
    @ViewBuilder
    func buttonStyle(_ style: CosmosButtonStyle) -> some View {
        switch style {
        case .primary:
            self.buttonStyle(.borderedProminent)
        case .secondary:
            self.buttonStyle(.bordered)
        case .danger:
            self.buttonStyle(.borderedProminent)
                .tint(.red)
        case .ghost:
            self.buttonStyle(.borderless)
        }
    }

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
