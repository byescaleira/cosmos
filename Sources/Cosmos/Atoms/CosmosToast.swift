import SwiftUI

/// The icon + message row rendered inside a toast by the role conveniences
/// (``View/cosmosToast(_:isPresented:)`` / ``View/cosmosToast(_:item:)``). The toast **modifier**
/// supplies the chrome (material surface, radius, padding, shadow, transition, tap-to-dismiss,
/// auto-dismiss, haptic, tracking); this view is just the role-tinted content the caller drops in.
///
/// `CosmosIcon` pins `.foregroundStyle(theme.colors.primary)` in its body, so a role-tinted glyph
/// uses a raw `Image(systemName:)` here (a SwiftUI primitive — no UIKit) instead of fighting that
/// override. The icon is decorative for accessibility (`.accessibilityHidden`); the `message`
/// carries the VoiceOver label, combined into one element by the modifier's
/// `.accessibilityElement(children: .combine)`.
public struct CosmosToastContent<Message: View>: View {
    let role: CosmosToastRole
    @ViewBuilder let message: () -> Message

    @Environment(\.cosmosTheme) private var theme

    public init(role: CosmosToastRole, @ViewBuilder message: @escaping () -> Message) {
        self.role = role
        self.message = message
    }

    public var body: some View {
        HStack(spacing: CosmosSpacingTokens.small) {
            Image(systemName: role.icon)
                .font(theme.typography.font(for: theme.textStyle))
                .foregroundStyle(roleColor)
                .accessibilityHidden(true)
            message()
        }
    }

    private var roleColor: Color {
        switch role.tint {
        case .primary: theme.colors.primary
        case .success: theme.colors.success
        case .warning: theme.colors.warning
        case .error: theme.colors.error
        }
    }
}

extension CosmosToastContent where Message == CosmosText {
    /// Creates a toast content row from a localized String Catalog key.
    public init(role: CosmosToastRole, _ key: String) {
        self.role = role
        self.message = { CosmosText(key) }
    }

    /// Creates a toast content row from verbatim (non-localized) text.
    public init(role: CosmosToastRole, verbatim text: String) {
        self.role = role
        self.message = { CosmosText(verbatim: text) }
    }
}

// MARK: - Previews

#Preview("Toast – isPresented (top)", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosText(verbatim: "Root content").padding()
            .cosmosToast(isPresented: .constant(true)) {
                CosmosToastContent(role: .success, verbatim: "Saved to your library.")
            }
    }
}

#Preview("Toast – item (bottom)", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosText(verbatim: "Root content").padding()
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
                CosmosToastContent(role: role, verbatim: "Role preview")
            }
        }
        .padding()
    }
}

#Preview("Toast – dark + Dynamic Type", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosText(verbatim: "Root content").padding()
            .cosmosToast(isPresented: .constant(true)) {
                CosmosToastContent(role: .warning, verbatim: "Heads up — this action can't be undone.")
            }
            .cosmosPreviewEnv(colorScheme: .dark, dynamicTypeSize: .accessibility3)
    }
}

#Preview("Toast – reduce motion + reduce transparency", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosText(verbatim: "Root content").padding()
            .cosmosToast(isPresented: .constant(true)) {
                CosmosToastContent(role: .info, verbatim: "Reduce-transparency falls back to a solid surface.")
            }
            .cosmosPreviewEnv(reduceMotion: true, reduceTransparency: true)
    }
}

private struct ToastMessage: Identifiable {
    let id = UUID()
    let text: String
}