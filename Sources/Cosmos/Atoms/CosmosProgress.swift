import SwiftUI
import CosmosBase

/// A progress atom.
///
/// `CosmosProgress` reads its visibility, accessibility, and color from the
/// SwiftUI environment. It accepts an optional value through its initializer;
/// omit the value to render an indeterminate spinner. Override state and
/// appearance through the `.cosmos*` modifiers.
public struct CosmosProgress: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let value: Double?

    /// Creates a Cosmos progress atom.
    ///
    /// - Parameter value: A value between `0.0` and `1.0`. Pass `nil` for an
    ///   indeterminate spinner.
    public init(value: Double? = nil) {
        self.value = value
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var resolvedAccessibilityLabel: String {
        if let label = configuration.accessibility.label { return label }
        if let value { return "Progress: \(Int(value * 100))%" }
        return "In progress"
    }

    public var body: some View {
        if effectiveVisible {
            progressView
                .tint(theme.colors.accent)
                .accessibilityLabel(Text(resolvedAccessibilityLabel))
                .accessibilityHintOrNil(configuration.accessibility.hint)
                .accessibilityHidden(configuration.accessibility.isHidden)
                .accessibilitySortPriority(configuration.accessibility.sortPriority)
                .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    @ViewBuilder
    private var progressView: some View {
        if let value {
            ProgressView(value: value)
        } else {
            ProgressView()
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
