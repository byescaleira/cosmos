import SwiftUI
import CosmosBase

/// A reusable list row molecule.
///
/// `CosmosListRow` composes a leading icon, a title/subtitle stack, and a
/// trailing element into the standard iOS list row pattern. It reads visibility,
/// accessibility, and spacing from the environment.
public struct CosmosListRow: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    let titleKey: String
    let subtitleKey: String?
    let systemImage: String?
    let trailing: Trailing

    /// Creates a list row with the given content and trailing element.
    public init(
        _ titleKey: String,
        subtitle subtitleKey: String? = nil,
        systemImage: String? = nil,
        trailing: Trailing = .none
    ) {
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.systemImage = systemImage
        self.trailing = trailing
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var resolvedTitle: String {
        configuration.localization.string(for: titleKey)
    }

    private var resolvedSubtitle: String? {
        subtitleKey.map { configuration.localization.string(for: $0) }
    }

    private var resolvedAccessibilityLabel: String {
        configuration.accessibility.label ?? resolvedTitle
    }

    public var body: some View {
        if effectiveVisible {
            HStack(spacing: theme.spacing.small) {
                if let systemImage {
                    CosmosIcon(systemImage)
                        .foregroundStyle(theme.colors.accent)
                }

                textStack

                Spacer()

                trailingContent
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
    private var textStack: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(resolvedTitle)
                .font(theme.typography.font(for: theme.textStyle))
                .foregroundStyle(theme.colors.primary)

            if let resolvedSubtitle {
                Text(resolvedSubtitle)
                    .font(theme.typography.font(for: .caption2))
                    .foregroundStyle(theme.colors.secondary)
            }
        }
    }

    @ViewBuilder
    private var trailingContent: some View {
        switch trailing {
        case .none:
            EmptyView()
        case .badge(let text, let variant):
            if let text {
                CosmosBadge(text, variant: variant)
            } else {
                CosmosBadge(dot: variant)
            }
        case .chevron:
            CosmosIcon("chevron.right")
                .foregroundStyle(theme.colors.secondary)
        case .text(let valueKey):
            Text(configuration.localization.string(for: valueKey))
                .font(theme.typography.font(for: theme.textStyle))
                .foregroundStyle(theme.colors.secondary)
        }
    }
}

extension CosmosListRow {
    /// Describes the trailing element of a list row.
    public enum Trailing: Sendable, Codable, Equatable {
        case none
        case badge(text: String?, variant: CosmosBadge.Variant)
        case chevron
        case text(String)

        private enum CodingKeys: String, CodingKey {
            case kind
            case text
            case variant
        }

        private enum Kind: String, Sendable, Codable {
            case none
            case badge
            case chevron
            case text
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let kind = try container.decode(Kind.self, forKey: .kind)

            switch kind {
            case .none:
                self = .none
            case .badge:
                let text = try container.decodeIfPresent(String.self, forKey: .text)
                let variant = try container.decode(CosmosBadge.Variant.self, forKey: .variant)
                self = .badge(text: text, variant: variant)
            case .chevron:
                self = .chevron
            case .text:
                let value = try container.decode(String.self, forKey: .text)
                self = .text(value)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .none:
                try container.encode(Kind.none, forKey: .kind)
            case .badge(let text, let variant):
                try container.encode(Kind.badge, forKey: .kind)
                try container.encodeIfPresent(text, forKey: .text)
                try container.encode(variant, forKey: .variant)
            case .chevron:
                try container.encode(Kind.chevron, forKey: .kind)
            case .text(let value):
                try container.encode(Kind.text, forKey: .kind)
                try container.encode(value, forKey: .text)
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
