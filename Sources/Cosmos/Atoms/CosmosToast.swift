import SwiftUI


public struct CosmosToastContent<Message: View>: View {
    let role: CosmosToastRole
    let title: String?
    let description: String?
    @ViewBuilder let message: (() -> Message)?

    @Environment(\.cosmosTheme) private var theme

    public init(role: CosmosToastRole, @ViewBuilder message: @escaping () -> Message) {
        self.role = role
        self.title = nil
        self.description = nil
        self.message = message
    }
    
    public init(role: CosmosToastRole, title: String?, description: String?) {
        self.role = role
        self.title = title
        self.description = description
        self.message = nil
    }

    public var body: some View {
        HStack(spacing: CosmosSpacingTokens.medium) {
            if let message {
                message()
            } else if let title, let description {
                VStack(spacing: CosmosSpacingTokens.small) {
                    CosmosText(verbatim: title)
                        .cosmosFont(.footnote, weight: .bold)
                        .cosmosForegroundStyle(.primary)
                    
                    CosmosText(verbatim: description)
                        .cosmosFont(.footnote)
                        .cosmosForegroundStyle(.secondary)
                }
            }
            
            Image(systemName: role.icon)
                .font(theme.typography.font(for: theme.textStyle))
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
        }
        .padding(5)
    }
}

// MARK: - Previews

#Preview("Toast – isPresented (top)", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosVStack {
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .cosmosToast(isPresented: .constant(true)) {
            CosmosToastContent<Never>(
                role: .success,
                title: "Heads up!",
                description: "this action can't be undone."
            )
        }
    }
}

#Preview("Toast – item (bottom)", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosVStack {
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .cosmosToast(
            .error,
            item: .constant(ToastMessage(text: "Could not reach the server.")),
            placement: .bottom
        ) { Text(verbatim: $0.text) }
    }
}

#Preview("Toast – roles", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(spacing: 10) {
            ForEach([CosmosToastRole.info, .success, .warning, .error], id: \.self) { role in
                CosmosToastContent(role: role) { CosmosText(verbatim: "Role preview") }
            }
        }
        .padding()
    }
}

#Preview("Toast – dark + Dynamic Type", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosText(verbatim: "Root content").padding()
            .cosmosToast(isPresented: .constant(true)) {
                CosmosToastContent(role: .warning) { CosmosText(verbatim: "Heads up — this action can't be undone.") }
            }
            .cosmosPreviewEnv(colorScheme: .dark, dynamicTypeSize: .accessibility3)
    }
}

#Preview("Toast – reduce motion + reduce transparency", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosText(verbatim: "Root content").padding()
            .cosmosToast(isPresented: .constant(true)) {
                CosmosToastContent(role: .info) { CosmosText(verbatim: "Reduce-transparency falls back to a solid surface.") }
            }
            .cosmosPreviewEnv(reduceMotion: true, reduceTransparency: true)
    }
}

private struct ToastMessage: Identifiable {
    let id = UUID()
    let text: String
}
