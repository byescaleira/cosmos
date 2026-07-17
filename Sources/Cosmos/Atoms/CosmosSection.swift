import SwiftUI

/// A section atom wrapping `Section` — a primitive structural container whose appearance is fully
/// determined by the enclosing `List`/`Form`/`.listStyle`.
///
/// State and theme are **global**; this atom reads ``CosmosConfiguration`` from the environment.
/// There is **no** `CosmosSectionStyle` selector — `Section` has no style protocol (zero hits in
/// either interface; it is a primitive, `Body == Never`), so this atom wraps a `View` per the
/// Cosmos wrap-view discipline (see `DECISIONS.md`).
///
/// **Platform guard.** None at the type level — `Section` and every init exposed here (the
/// `content:/header:/footer:` forms, the `titleKey`/`String`/`LocalizedStringResource` header forms,
/// and the `isExpanded:` collapsible forms) are `@available` ≤ iOS 17 / visionOS 1, all below the
/// Cosmos 26 floor, so they compile on all 5 platforms with no `#if os()` or `if #available` gate.
/// The **container-driven modifiers** (`.listSectionSpacing`, `.listSectionSeparator`,
/// `.listRowSeparator`, `.sectionActions`, `.listSectionMargins`) are platform-unavailable on
/// some targets — they are exposed as `#if os()`-guarded ``cosmosListSectionSpacing``-style
/// wrappers below (no-op on platforms that lack them), so callers get one uniform Cosmos API.
///
/// **Customization limits.** Appearance is fully determined by the enclosing `List`/`Form`/
/// `.listStyle` — CosmosSection **MUST NOT** set its own background, inset, or separators; it
/// only forwards the documented container modifiers. `Section` is a primitive: it renders nothing
/// meaningful outside a `List`/`Form`/`GroupBox-like` container, so every preview wraps in `List`.
///
/// **`isExpanded`.** The collapsible init (`init(isExpanded:content:header:)`) requires
/// `Footer == EmptyView` — a collapsible section **with a footer is not publicly expressible**
/// (the internal `Section.create` accepts both, but no public init exposes that combination).
/// The `isExpanded` inits below are therefore constrained `where Footer == EmptyView`.
///
/// **Accessibility.** `Section` is structural — no traits of its own. A `Text`/`CosmosLocalizedText`
/// header exposes header semantics automatically; a **custom `View` header** should add
/// `.accessibilityAddTraits(.isHeader)` (and optionally `.accessibilityHeading(.h2)`) at the call
/// site — the atom does not force it (forcing it on a `Text` header would be redundant). Collapsible
/// sections expose expand/collapse via the native disclosure; do not duplicate.
///
/// **Haptics.** None — non-interactive; disclosure/expand is native with its own feedback.
/// `.sectionActions` button haptics belong to those button atoms, not here.
///
/// **Motion.** `none` — the only Section motion is the native expand/collapse (driven internally
/// by SwiftUI with its own animation); do NOT layer `.cosmosAnimation` on top (it would animate
/// the same property with a differing curve and desync — CLAUDE.md). `listInsert`/`listRemove`
/// belong to the List rows inside, not to Section. Callers wanting coordinated expand/collapse
/// wrap their `Binding<Bool>` mutation in a single
/// `withAnimation(theme.motion.spring(for: .containerTransform).animation)` at the call site.
///
/// **Tracking.** None — `Section` is structural/decorative, like ``CosmosDivider``: a `List` of
/// many sections would otherwise emit a noisy appear event per section. Opt-in tracking belongs
/// on the interactive rows/controls inside, not on the container.
///
/// - Note: The spec listed `.headerProminence(_:)` as a modifier to wire. That API does **not**
///   exist in the Xcode 27 SwiftUI SDK (only `badgeProminence` does) — it is omitted here. If a
///   future SDK reintroduces it, add a guarded ``cosmosHeaderProminence`` wrapper then.
public struct CosmosSection<Parent: View, Content: View, Footer: View>: View {
    @ViewBuilder private let header: () -> Parent
    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let footer: () -> Footer
    private let isExpanded: Binding<Bool>?

    @Environment(\.cosmosConfiguration) private var configuration

    /// Creates a section with custom content, header, and footer views.
    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Parent,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.content = content
        self.header = header
        self.footer = footer
        self.isExpanded = nil
    }

    public var body: some View {
        if configuration.enable.isVisible {
            section
                .applyCosmosAccessibility(configuration.accessibility)
        } else {
            EmptyView()
        }
    }

    /// Builds the underlying `Section`. The `isExpanded` branch constructs a fresh `Section` with
    /// an `EmptyContent` footer (ignoring the stored `footer` closure) — correct because the
    /// `isExpanded` inits constrain `Footer == EmptyView`, so nothing is lost. The two branches
    /// yield different concrete `Section` types, unified by `@ViewBuilder` into `_ConditionalContent`.
    @ViewBuilder private var section: some View {
        if let isExpanded {
            Section(isExpanded: isExpanded, content: content, header: header)
        } else {
            Section(content: content, header: header, footer: footer)
        }
    }
}

// MARK: - Two-closure / single-closure inits (one or both generics defaulted to EmptyView)

extension CosmosSection where Parent == EmptyView {
    /// Creates a section with custom content and footer (no header).
    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.content = content
        self.header = { EmptyView() }
        self.footer = footer
        self.isExpanded = nil
    }
}

extension CosmosSection where Footer == EmptyView {
    /// Creates a section with custom content and header (no footer).
    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Parent
    ) {
        self.content = content
        self.header = header
        self.footer = { EmptyView() }
        self.isExpanded = nil
    }
}

extension CosmosSection where Parent == EmptyView, Footer == EmptyView {
    /// Creates a section with custom content only (no header or footer).
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.header = { EmptyView() }
        self.footer = { EmptyView() }
        self.isExpanded = nil
    }
}

// MARK: - Title-key / verbatim / LocalizedStringResource header inits (Parent == Text/Header, Footer == EmptyView)

extension CosmosSection where Parent == CosmosLocalizedText, Footer == EmptyView {
    /// Creates a section from a localized String Catalog key (header), with custom content.
    public init(_ titleKey: String, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.header = { CosmosLocalizedText(key: titleKey) }
        self.footer = { EmptyView() }
        self.isExpanded = nil
    }
}

extension CosmosSection where Parent == Text, Footer == EmptyView {
    /// Creates a section from verbatim (non-localized) header text, with custom content.
    public init<S: StringProtocol>(
        verbatim title: S,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.header = { Text(verbatim: String(title)) }
        self.footer = { EmptyView() }
        self.isExpanded = nil
    }

    /// Creates a section from a `LocalizedStringResource` header (iOS 16+; below the Cosmos 26
    /// floor — available at `.v26`), with custom content.
    public init(
        _ titleResource: LocalizedStringResource,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.header = { Text(titleResource) }
        self.footer = { EmptyView() }
        self.isExpanded = nil
    }
}

// MARK: - Collapsible inits (isExpanded) — requires Footer == EmptyView

extension CosmosSection where Footer == EmptyView {
    /// Creates a collapsible section with a custom header, driven by `isExpanded`.
    public init(
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Parent
    ) {
        self.content = content
        self.header = header
        self.footer = { EmptyView() }
        self.isExpanded = isExpanded
    }
}

extension CosmosSection where Parent == CosmosLocalizedText, Footer == EmptyView {
    /// Creates a collapsible section from a localized String Catalog key header.
    public init(
        _ titleKey: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.header = { CosmosLocalizedText(key: titleKey) }
        self.footer = { EmptyView() }
        self.isExpanded = isExpanded
    }
}

extension CosmosSection where Parent == Text, Footer == EmptyView {
    /// Creates a collapsible section from verbatim (non-localized) header text.
    public init<S: StringProtocol>(
        verbatim title: S,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.header = { Text(verbatim: String(title)) }
        self.footer = { EmptyView() }
        self.isExpanded = isExpanded
    }

    /// Creates a collapsible section from a `LocalizedStringResource` header.
    public init(
        _ titleResource: LocalizedStringResource,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.header = { Text(titleResource) }
        self.footer = { EmptyView() }
        self.isExpanded = isExpanded
    }
}

// MARK: - Section container modifiers (platform-guarded pass-throughs)

extension View {
    /// Section spacing via the `ListSectionSpacing` enum. Available iOS 17+ / watchOS 10+ /
    /// visionOS. The `ListSectionSpacing` **type** itself is unavailable on macOS / tvOS, so this
    /// overload is declared only on iOS / watchOS / visionOS (callers on macOS / tvOS cannot
    /// construct a `ListSectionSpacing` to pass, so no no-op is needed there). The enclosing
    /// `List`/`.listStyle` interprets the value.
    #if os(iOS) || os(watchOS) || os(visionOS)
    @ViewBuilder
    public func cosmosListSectionSpacing(_ spacing: ListSectionSpacing) -> some View {
        self.listSectionSpacing(spacing)
    }
    #endif

    /// Section spacing as a concrete `CGFloat` — a universal no-op on platforms that lack the
    /// native `listSectionSpacing(_:)` (macOS / tvOS). On iOS 17+ / watchOS 10+ / visionOS it
    /// forwards to the native modifier; the enclosing `List`/`.listStyle` interprets the value.
    @ViewBuilder
    public func cosmosListSectionSpacing(_ spacing: CGFloat) -> some View {
        #if os(iOS) || os(watchOS) || os(visionOS)
        self.listSectionSpacing(spacing)
        #else
        self
        #endif
    }

    /// Section separator visibility. Available iOS 15+ / macOS 13+ / visionOS; **unavailable
    /// tvOS / watchOS** — no-op on those platforms.
    @ViewBuilder
    public func cosmosListSectionSeparator(
        _ visibility: Visibility,
        edges: VerticalEdge.Set = .all
    ) -> some View {
        #if !os(tvOS) && !os(watchOS)
        self.listSectionSeparator(visibility, edges: edges)
        #else
        self
        #endif
    }

    /// Section separator tint. Same availability as ``cosmosListSectionSeparator(_:edges:)`` —
    /// iOS 15+ / macOS 13+ / visionOS; no-op tvOS / watchOS.
    @ViewBuilder
    public func cosmosListSectionSeparatorTint(
        _ color: Color?,
        edges: VerticalEdge.Set = .all
    ) -> some View {
        #if !os(tvOS) && !os(watchOS)
        self.listSectionSeparatorTint(color, edges: edges)
        #else
        self
        #endif
    }

    /// Row separator visibility (applies to rows inside this section). Available iOS 15+ /
    /// macOS 13+ / visionOS; **unavailable tvOS / watchOS** — no-op on those platforms.
    @ViewBuilder
    public func cosmosListRowSeparator(
        _ visibility: Visibility,
        edges: VerticalEdge.Set = .all
    ) -> some View {
        #if !os(tvOS) && !os(watchOS)
        self.listRowSeparator(visibility, edges: edges)
        #else
        self
        #endif
    }

    /// Row separator tint. Same availability as ``cosmosListRowSeparator(_:edges:)`` —
    /// iOS 15+ / macOS 13+ / visionOS; no-op tvOS / watchOS.
    @ViewBuilder
    public func cosmosListRowSeparatorTint(
        _ color: Color?,
        edges: VerticalEdge.Set = .all
    ) -> some View {
        #if !os(tvOS) && !os(watchOS)
        self.listRowSeparatorTint(color, edges: edges)
        #else
        self
        #endif
    }

    /// Section actions (trailing header actions). Available iOS 18+ / macOS 15+ / visionOS 2+;
    /// **unavailable tvOS / watchOS** — no-op on those platforms.
    @ViewBuilder
    public func cosmosSectionActions<C: View>(
        @ViewBuilder content: @escaping () -> C
    ) -> some View {
        #if !os(tvOS) && !os(watchOS)
        self.sectionActions(content: content)
        #else
        self
        #endif
    }

    /// Section margins. Available iOS 26+ / visionOS 26+ (at the Cosmos floor); **unavailable macOS
    /// / tvOS / watchOS** — no-op on those platforms.
    @ViewBuilder
    public func cosmosListSectionMargins(
        _ edges: Edge.Set = .all,
        _ length: CGFloat?
    ) -> some View {
        #if os(iOS) || os(visionOS)
        self.listSectionMargins(edges, length)
        #else
        self
        #endif
    }
}

// MARK: - Previews

#Preview("Section – header + content + footer in a List") {
    List {
        CosmosSection {
            CosmosText("preview.row.one")
            CosmosText("preview.row.two")
        } header: {
            CosmosText("preview.title")
        } footer: {
            CosmosText("preview.description")
        }
    }
}

#Preview("Section – title-key + verbatim + custom header") {
    List {
        CosmosSection("preview.title") {
            CosmosText("preview.row.one")
        }
        CosmosSection(verbatim: CosmosMock.sentence(wordCount: 2), content: {
            CosmosText("preview.row.two")
        })
        CosmosSection(content: {
            CosmosText("preview.row.three")
        }, header: {
            Label("preview.title", systemImage: "star")
        })
    }
}

#Preview("Section – collapsible (isExpanded)") {
    @Previewable @State var isExpanded = true
    List {
        CosmosSection("preview.title", isExpanded: $isExpanded) {
            CosmosText("preview.row.one")
            CosmosText("preview.row.two")
        }
    }
}

#Preview("Section – dark + accessibility size", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        List {
            // The title-key init requires Footer == EmptyView, so a section that needs a footer
            // uses the explicit `content:/header:/footer:` form (here with a localized header).
            CosmosSection(content: {
                CosmosText("preview.row.one")
                CosmosText("preview.row.two")
            }, header: {
                CosmosLocalizedText(key: "preview.title")
            }, footer: {
                CosmosText("preview.description")
            })
        }
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}