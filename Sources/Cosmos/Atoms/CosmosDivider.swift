import SwiftUI
import CosmosBase

/// A visual divider atom.
///
/// `CosmosDivider` reads its visibility, style, thickness, and color from the
/// SwiftUI environment. It accepts no initializer parameters; override the
/// divider appearance through the theme and `.cosmos*` modifiers.
public struct CosmosDivider: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    /// Creates a Cosmos divider atom.
    public init() {}

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    public var body: some View {
        if effectiveVisible {
            Divider()
                .cosmosDividerStyle(theme.dividerStyle, theme: theme)
                .frame(height: theme.spacing.value(for: theme.dividerThickness))
                .foregroundStyle(theme.colors.secondary)
                .background(theme.colors.secondary)
                .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }
}

private extension View {
    @ViewBuilder
    func cosmosDividerStyle(_ style: CosmosDividerStyle, theme: CosmosTheme) -> some View {
        switch style {
        case .default:
            self
        case .inset:
            self.padding(.leading, theme.spacing.large)
        case .bold:
            self
                .frame(height: theme.spacing.value(for: theme.dividerThickness))
                .background(theme.colors.secondary)
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
