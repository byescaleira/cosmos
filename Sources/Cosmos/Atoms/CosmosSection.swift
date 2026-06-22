import SwiftUI
import CosmosBase

/// A section container atom.
///
/// `CosmosSection` wraps SwiftUI `Section` and reads visibility, enablement,
/// accessibility, and theme from the environment. It accepts header, footer,
/// and content through `@ViewBuilder`. Use it inside `CosmosList` or standalone
/// when the native grouped appearance is desired.
///
/// For the JSON-driven renderer, `CosmosSectionModel` describes header/footer
/// content as arrays of `CosmosComponent`, and `CosmosScreenRenderer` turns those
/// arrays into nested views.
public struct CosmosSection<Header: View, Footer: View, Content: View>: View {
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme

    @ViewBuilder let header: () -> Header
    @ViewBuilder let footer: () -> Footer
    @ViewBuilder let content: () -> Content

    /// Creates a Cosmos section with header, footer, and content.
    public init(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.content = content
    }

    private var effectiveVisible: Bool {
        configuration.enable.isVisible
    }

    private var isEnabled: Bool {
        configuration.enable.isEnabled && !configuration.enable.isReadOnly
    }

    public var body: some View {
        sectionBody
    }

    @ViewBuilder
    private var sectionBody: some View {
        if effectiveVisible {
            sectionContent
                .disabled(!isEnabled)
                .accessibilityLabelOrNil(configuration.accessibility.label)
                .accessibilityHintOrNil(configuration.accessibility.hint)
                .accessibilityHidden(configuration.accessibility.isHidden)
                .accessibilitySortPriority(configuration.accessibility.sortPriority)
                .redactedIfNeeded(configuration.redaction.isRedacted)
        }
    }

    @ViewBuilder
    private var sectionContent: some View {
        Section {
            content()
        } header: {
            header()
        } footer: {
            footer()
        }
    }
}

// MARK: - Convenience initializers

extension CosmosSection where Header == EmptyView, Footer == EmptyView {
    /// Creates a Cosmos section with only content.
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.init(header: { EmptyView() }, footer: { EmptyView() }, content: content)
    }
}

extension CosmosSection where Header == EmptyView {
    /// Creates a Cosmos section with a footer and content.
    public init(
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(header: { EmptyView() }, footer: footer, content: content)
    }
}

extension CosmosSection where Footer == EmptyView {
    /// Creates a Cosmos section with a header and content.
    public init(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(header: header, footer: { EmptyView() }, content: content)
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
