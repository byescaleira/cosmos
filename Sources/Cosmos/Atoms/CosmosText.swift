import SwiftUI

/// A reference atom wrapping `Text` with token-driven typography/color, localization, and
/// accessibility. Reads ``CosmosTheme`` and ``CosmosConfiguration`` from the environment.
public struct CosmosText: View {
    private let storage: Storage

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum Storage: Sendable {
        case key(String?)
        case verbatim(String?)
    }

    /// Creates text from a localized String Catalog key (resolved via the configuration).
    public init(_ key: String?) {
        self.storage = .key(key)
    }

    /// Creates verbatim (non-localized) text.
    public init(verbatim text: String?) {
        self.storage = .verbatim(text)
    }

    private var resolvedText: String? {
        switch storage {
        case .key(let key): return configuration.localization.string(for: key)
        case .verbatim(let text): return text
        }
    }

    private var isHeading: Bool {
        switch theme.textStyle {
        case .largeTitle, .title, .title2, .title3: return true
        default: return false
        }
    }

    @ViewBuilder
    public var body: some View {
        if let resolvedText {
            Text(resolvedText)
                .font(theme.typography.font(for: theme.textStyle))
                .foregroundStyle(theme.colors.primary)
                .multilineTextAlignment(.leading)
            // Token-driven value-change motion, gated through the motion policy (single chokepoint).
                .cosmosContentTransition(.numeric)
                .cosmosAnimation(.valueChange, value: resolvedText)
                .accessibilityLabelOrNil(configuration.accessibility.label ?? resolvedText)
                .accessibilityHintOrNil(configuration.accessibility.hint)
                .accessibilityValueOrNil(configuration.accessibility.value)
                .accessibilityIdentifierOrNil(configuration.accessibility.identifier)
                .accessibilitySortPriorityOrNil(configuration.accessibility.sortPriority)
                .accessibilityHiddenIf(configuration.accessibility.isHidden)
                .accessibilityTraitsIfPresent(configuration.accessibility.traits.union(isHeading ? .isHeader : []))
                .accessibilityCustomContentIfPresent(configuration.accessibility.customContent)
                .modifier(CosmosRespondsModifier(responds: configuration.accessibility.respondsToUserInteraction))
                .onAppear {
                    configuration.tracking.track(.init(
                        name: "text_appear",
                        component: "CosmosText",
                        componentId: trackingId ?? configuration.accessibility.identifier,
                        action: .appear
                    ))
                    if CosmosMotionPolicy.shouldEmit(
                        isEnabled: configuration.motion.isEnabled,
                        respectReduceMotion: configuration.motion.respectReduceMotion,
                        reduceMotion: reduceMotion
                    ) {
                        configuration.motion.handler(.motion(.valueChange))
                    }
                }
        }
    }
}

// MARK: - Previews

#Preview("Text styles") {
    VStack(alignment: .leading, spacing: 8) {
        CosmosText("preview.title").cosmosTextStyle(.largeTitle)
        CosmosText("preview.description").cosmosTextStyle(.body)
        CosmosText(verbatim: "JetBrains Mono").cosmosTextStyle(.body).cosmosCustomFont("JetBrainsMono-Regular")
    }
    .padding()
}

#Preview("Dark + accessibility size") {
    VStack(alignment: .leading, spacing: 8) {
        CosmosText("preview.title").cosmosTextStyle(.title)
        CosmosText("preview.description").cosmosTextStyle(.body)
    }
    .padding()
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.accessibility5)
}

#Preview("Languages") {
    VStack(alignment: .leading, spacing: 8) {
        CosmosText("welcome.headline").cosmosTextStyle(.headline)
        CosmosText("preview.name").cosmosTextStyle(.body)
    }
    .padding()
    .environment(\.locale, Locale(identifier: "pt-BR"))
}

#Preview("Mock data – randomized strings", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(alignment: .leading, spacing: 8) {
            CosmosText(verbatim: CosmosMock.personName()).cosmosTextStyle(.headline)
            CosmosText(verbatim: CosmosMock.email()).cosmosTextStyle(.body)
            CosmosText(verbatim: CosmosMock.lorem(paragraphs: 1)).cosmosTextStyle(.body)
        }
        .padding()
    }
}
