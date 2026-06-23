import SwiftUI
import CosmosBase

/// A full-width button row molecule.
///
/// `CosmosButtonRow` wraps a `CosmosButton` with a standardized `CosmosLabel`
/// layout so every list-style or primary CTA button looks the same. It reads
/// visibility, enablement, and theme from the environment.
public struct CosmosButtonRow: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let titleKey: String
    let systemImage: String?
    let variant: Variant
    let action: () throws -> Void

    /// Creates a full-width button row.
    public init(
        _ titleKey: String,
        systemImage: String? = nil,
        variant: Variant = .primary,
        action: @escaping () throws -> Void
    ) {
        self.titleKey = titleKey
        self.systemImage = systemImage
        self.variant = variant
        self.action = action
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    public var body: some View {
        if effectiveVisible {
            CosmosButton(action: action) {
                HStack(spacing: theme.spacing.small) {
                    if let systemImage {
                        CosmosIcon(systemImage)
                    }

                    CosmosLabel(titleKey, systemImage: nil)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(variant.buttonStyle)
            .tint(variant.tintColor(theme: theme))
            .accessibilityElement(children: .combine)
            .accessibilityLabelOrNil(configuration.accessibility.label)
            .accessibilityHintOrNil(configuration.accessibility.hint)
            .accessibilityHidden(configuration.accessibility.isHidden)
            .accessibilitySortPriority(configuration.accessibility.sortPriority)
            .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }
}

extension CosmosButtonRow {
    /// Visual emphasis of a button row.
    public enum Variant: String, Sendable, Codable, Equatable, CaseIterable {
        case primary
        case danger

        fileprivate var buttonStyle: some PrimitiveButtonStyle {
            switch self {
            case .primary, .danger:
                return .borderedProminent
            }
        }

        fileprivate func tintColor(theme: CosmosTheme) -> Color {
            switch self {
            case .primary:
                return theme.colors.accent
            case .danger:
                return theme.colors.error
            }
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
