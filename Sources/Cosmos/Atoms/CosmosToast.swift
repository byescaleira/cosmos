import SwiftUI


/// The content view rendered inside a ``CosmosToast``: a role-tinted SF Symbol beside (or, when
/// the toast width is constrained, above) a title/description or a custom message. Honors
/// Differentiate Without Color (collapses to a monochrome, shape-only icon) and reflows via
/// ``CosmosViewThatFits`` so the icon and message stay legible at accessibility Dynamic Type /
/// narrow placements. Drive it directly, or via the ``View/cosmosToast(_:isPresented:placement:)``
/// family which wires the appear haptic in one call.
public struct CosmosToastContent<Message: View>: View {
    let role: CosmosToastRole
    let title: String?
    let description: String?
    @ViewBuilder let message: (() -> Message)?

    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

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

    /// When the Differentiate Without Color gate is active (and respected), the role icon stops
    /// communicating via color and relies on its distinct SF Symbol shape (`checkmark` /
    /// `exclamationmark.triangle` / `xmark` / `info`) — the non-color differentiator the HIG
    /// requires. Otherwise the role tint is applied (the default, sighted experience).
    private var differentiatesWithoutColor: Bool {
        CosmosAccessibilityPolicy.shouldDifferentiateWithoutColor(
            respectDifferentiateWithoutColor: configuration.accessibility.respectDifferentiateWithoutColor,
            differentiateWithoutColor: differentiateWithoutColor
        )
    }

    /// Under Increased Contrast (config-aware), the role icon renders monochrome against the
    /// role tint at full opacity so the symbol shape stays the legible signal — the same
    /// non-color intent as Differentiate Without Color, driven here by contrast rather than the
    /// color-difference gate.
    private var increasesContrast: Bool {
        CosmosAccessibilityPolicy.shouldIncreaseContrast(
            respectIncreaseContrast: configuration.accessibility.respectIncreaseContrast,
            contrast: colorSchemeContrast
        )
    }

    public var body: some View {
        // Reflow by available width: the icon sits beside the message when there's room
        // (default, sighted), and stacks above it when the toast width is constrained
        // (accessibility Dynamic Type, narrow placements). `ViewThatFits` preserves view
        // identity across the choice — no state reset when the layout flips (WWDC21-10022).
        CosmosViewThatFits(in: .horizontal) {
            toastRow
            toastStack
        }
        .padding(5)
        .overlay {
            // Increased Contrast adds a hairline outline so the toast stays a distinct shape
            // against the surface — the chrome part the role tint alone doesn't reinforce.
            if increasesContrast {
                RoundedRectangle(cornerRadius: CosmosRadiusTokens.small, style: .continuous)
                    .stroke(theme.colors.outline, lineWidth: 1)
            }
        }
    }

    /// Horizontal layout — icon beside the message (default when width allows).
    @ViewBuilder
    private var toastRow: some View {
        HStack(spacing: CosmosSpacingTokens.medium) {
            toastMessage
            toastIcon
        }
    }

    /// Vertical fallback — icon above the message (constrained width / accessibility sizes).
    @ViewBuilder
    private var toastStack: some View {
        VStack(spacing: CosmosSpacingTokens.small) {
            toastIcon
            toastMessage
        }
    }

    @ViewBuilder
    private var toastMessage: some View {
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
    }

    private var toastIcon: some View {
        Image(systemName: role.icon)
            .font(theme.typography.font(for: theme.textStyle))
            .symbolRenderingMode(differentiatesWithoutColor ? .monochrome : .hierarchical)
            .foregroundStyle(differentiatesWithoutColor ? theme.colors.primary : role.tint.color(in: theme.colors))
            .accessibilityHidden(true)
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

#Preview("Toast – landscape reflow", traits: .landscapeLeft) {
    CosmosPreviewContainer {
        CosmosText(verbatim: "Root content").padding()
            .cosmosToast(isPresented: .constant(true)) {
                CosmosToastContent(role: .warning) { CosmosText(verbatim: "Heads up — this action can't be undone.") }
            }
            .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}

private struct ToastMessage: Identifiable {
    let id = UUID()
    let text: String
}
