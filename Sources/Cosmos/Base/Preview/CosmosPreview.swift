import SwiftUI

/// Cosmos preview infrastructure namespace. Holds the stable seed and the baseline matrices
/// (locales, RTL locale, Dynamic Type accessibility sizes) used by co-located `#Preview` blocks
/// and by ``CosmosPreviewModifier`` / ``CosmosMock``.
public enum CosmosPreview {
    /// Stable seed so every preview render produces identical mock data (no churn).
    /// Valid hex literal — `0xC05505`.
    public static let defaultSeed: UInt64 = 0xC05505

    /// Baseline locales for the localization matrix (`en` + `pt-BR`).
    public static let locales: [Locale] = [Locale(identifier: "en"), .init(identifier: "pt-BR")]

    /// RTL locale for layout-direction flipping previews.
    public static let rtlLocale: Locale = .init(identifier: "ar")

    /// Dynamic Type sizes for the text matrix (smallest / standard-large / accessibility mid / accessibility max).
    public static let accessibilitySizes: [DynamicTypeSize] = [
        .xSmall, .large, .accessibility3, .accessibility5,
    ]
}

/// Pre-baked environment-override variants. Apply via `.cosmosPreviewVariant(_:)`.
///
/// Layout/orientation are deliberately **not** here — those are `#Preview("…", traits:)` concerns
/// (e.g. `.sizeThatFitsLayout`, `.landscapeLeft`). The display name is the `#Preview("…")` first
/// positional argument, not a variant.
public enum CosmosPreviewVariant: String, CaseIterable, Sendable {
    case `default`
    case dark
    case largestText
    case boldText
    case rtl
    case reduceMotion
    case reduceTransparency
    case increasedContrast
    case differentiateWithoutColor
    case showBorders
}

/// Plain wrapper view injecting default `cosmosConfiguration` + `cosmosTheme` + an optional
/// `locale`. Use for explicit per-preview control; ``CosmosPreviewModifier`` is the shared-context
/// path (`#Preview("…", traits: .modifier(CosmosPreviewModifier()))`).
public struct CosmosPreviewContainer<Content: View>: View {
    private let configuration: CosmosConfiguration
    private let theme: CosmosTheme
    private let locale: Locale?
    @ViewBuilder private let content: () -> Content

    public init(
        configuration: CosmosConfiguration = .default,
        theme: CosmosTheme = .default,
        locale: Locale? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.configuration = configuration
        self.theme = theme
        self.locale = locale
        self.content = content
    }

    public var body: some View {
        // `@ViewBuilder` composition (via `ifLet`) preserves structural identity (`_ConditionalContent`)
        // instead of `AnyView` erasure — view identity (focus/scroll/animation state) survives the
        // optional `locale` override flipping, and SwiftUI diffing stays on the fast path.
        content()
            .environment(\.cosmosConfiguration, configuration)
            .environment(\.cosmosTheme, theme)
            .ifLet(locale) { $0.environment(\.locale, $1) }
    }
}

extension View {
    /// Applies environment overrides for preview. Uses directly-settable keys
    /// (`colorScheme`, `dynamicTypeSize`, `locale`, `layoutDirection`, `horizontalSizeClass`,
    /// `verticalSizeClass`, `legibilityWeight`) and the underscore SPI for the get-only
    /// accessibility keys (`._accessibilityReduceMotion`, `._accessibilityReduceTransparency`,
    /// `._accessibilityDifferentiateWithoutColor`, `._accessibilityShowButtonShapes`,
    /// `._colorSchemeContrast`). Apple's own preview tooling uses these SPI forms; they carry no
    /// deprecation attributes (zero-warning). Each parameter is optional; `nil` = no override.
    /// Accepted fragility: if a future SDK removes the underscore keys, the preview matrix
    /// degrades gracefully (the override is simply not applied).
    public func cosmosPreviewEnv(
        colorScheme: ColorScheme? = nil,
        dynamicTypeSize: DynamicTypeSize? = nil,
        locale: Locale? = nil,
        layoutDirection: LayoutDirection? = nil,
        horizontalSizeClass: UserInterfaceSizeClass? = nil,
        verticalSizeClass: UserInterfaceSizeClass? = nil,
        legibilityWeight: LegibilityWeight? = nil,
        reduceMotion: Bool? = nil,
        reduceTransparency: Bool? = nil,
        differentiateWithoutColor: Bool? = nil,
        showButtonShapes: Bool? = nil,
        colorSchemeContrast: ColorSchemeContrast? = nil
    ) -> some View {
        // The 7 directly-settable keys compose via `ifLet` (`_ConditionalContent`) so structural
        // identity survives an override flipping (WWDC21-10022) — these are the keys callers
        // actually toggle (colorScheme/dynamicTypeSize/locale/…). The 5 get-only underscore-SPI
        // accessibility keys are applied *after* erasing to `AnyView`, which caps the generic depth
        // at 7 (a full 12-deep `_ConditionalContent` threading a heavy `Content` explodes the `-O`
        // release type-checker — e.g. `CosmosTabView`'s tab builder). The SPI keys are get-only and
        // rarely toggled, so the `AnyView` erasure on that tail costs nothing meaningful.
        let chained = self
            .ifLet(colorScheme) { $0.environment(\.colorScheme, $1) }
            .ifLet(dynamicTypeSize) { $0.environment(\.dynamicTypeSize, $1) }
            .ifLet(locale) { $0.environment(\.locale, $1) }
            .ifLet(layoutDirection) { $0.environment(\.layoutDirection, $1) }
            .ifLet(horizontalSizeClass) { $0.environment(\.horizontalSizeClass, $1) }
            .ifLet(verticalSizeClass) { $0.environment(\.verticalSizeClass, $1) }
            .ifLet(legibilityWeight) { $0.environment(\.legibilityWeight, $1) }
        // Erase to cap generic depth, then apply the 5 SPI accessibility keys shallowly.
        var view: AnyView = AnyView(chained)
        if let reduceMotion { view = AnyView(view.environment(\._accessibilityReduceMotion, reduceMotion)) }
        if let reduceTransparency { view = AnyView(view.environment(\._accessibilityReduceTransparency, reduceTransparency)) }
        if let differentiateWithoutColor { view = AnyView(view.environment(\._accessibilityDifferentiateWithoutColor, differentiateWithoutColor)) }
        if let showButtonShapes { view = AnyView(view.environment(\._accessibilityShowButtonShapes, showButtonShapes)) }
        if let colorSchemeContrast { view = AnyView(view.environment(\._colorSchemeContrast, colorSchemeContrast)) }
        return view
    }

    /// Applies a pre-baked bundle of environment overrides (see ``CosmosPreviewVariant``).
    ///
    /// Dispatch is a runtime `switch` over a fixed enum, so each call site resolves to exactly
    /// one branch and never flips branches on re-evaluation — `AnyView` erasure here is the
    /// pragmatic choice. (A wide `@ViewBuilder` switch over 10 distinct opaque branches crashes
    /// the Xcode 27 beta SILGen; the per-override `ifLet` chain in ``cosmosPreviewEnv`` is where
    /// structural identity actually matters, since stacked overrides flip at runtime.)
    public func cosmosPreviewVariant(_ variant: CosmosPreviewVariant) -> some View {
        switch variant {
        case .default:
            return AnyView(self)
        case .dark:
            return AnyView(self.cosmosPreviewEnv(colorScheme: .dark))
        case .largestText:
            return AnyView(self.cosmosPreviewEnv(dynamicTypeSize: .accessibility5))
        case .boldText:
            return AnyView(self.cosmosPreviewEnv(legibilityWeight: .bold))
        case .rtl:
            return AnyView(self.cosmosPreviewEnv(locale: CosmosPreview.rtlLocale, layoutDirection: .rightToLeft))
        case .reduceMotion:
            return AnyView(self.cosmosPreviewEnv(reduceMotion: true))
        case .reduceTransparency:
            return AnyView(self.cosmosPreviewEnv(reduceTransparency: true))
        case .increasedContrast:
            return AnyView(self.cosmosPreviewEnv(colorSchemeContrast: .increased))
        case .differentiateWithoutColor:
            return AnyView(self.cosmosPreviewEnv(differentiateWithoutColor: true))
        case .showBorders:
            return AnyView(self.cosmosPreviewEnv(showButtonShapes: true))
        }
    }
}

// MARK: - Conditional-apply helper (keeps structural identity, no `AnyView`)

private extension View {
    /// Applies `transform` only when `value` is non-`nil`, else passes `self` through unchanged.
    /// `@ViewBuilder` produces `_ConditionalContent` (structural identity preserved) rather than
    /// `AnyView` erasure — used by the preview env accumulator so optional overrides don't churn
    /// view identity when toggled (WWDC21-10022: "Require. Infer. Use.").
    @ViewBuilder
    func ifLet<Value>(_ value: Value?, transform: (Self, Value) -> some View) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}