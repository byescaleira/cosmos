import SwiftUI
import Foundation

/// The unified image atom — the single Cosmos surface for SF Symbols, typed asset
/// resources, asset images, custom image content, and remote (URL) images.
///
/// `Image` has **no style protocol** (there is no `ImageStyle`), so this atom wraps a `View`
/// per the Cosmos wrap-view discipline. It supersedes the separate ``CosmosIcon`` and
/// ``CosmosAsyncImage`` atoms (both deprecated; migrate any call site to `CosmosImage`).
///
/// **Sources.** Four primary init families cover every image use case:
/// - SF Symbols — ``init(systemName:)``, ``init(systemName:variableValue:)``, and the
///   decorative ``init(decorativeSystemName:)`` (hidden from VoiceOver; SwiftUI has no
///   `Image(decorativeSystemName:)`, so the atom hides it via the accessibility config).
/// - Typed asset resources — ``init(_:)`` taking an `ImageResource` (the asset-catalog
///   codegen type, **not** a string). `ImageResource` is available on all 5 platforms at
///   the Cosmos 26 floor (iOS 17 / macOS 14 / tvOS 17 / watchOS 10 / visionOS 1, all ≤
///   `.v26`); no `#if os()` or `@available` gate is needed.
/// - Asset images by name — ``init(_:bundle:)`` and the decorative
///   ``init(decorative:bundle:)`` (natively hidden by `Image(decorative:bundle:)`).
/// - Remote images — ``init(url:scale:content:)`` (default slots) and the typed-slot
///   ``init(url:scale:content:placeholder:failure:)``, plus the string-URL convenience
///   ``init(url:scale:content:)`` that parses `URL(string:)` (nil → empty/placeholder).
///   And the custom-content escape hatch ``init(content:)`` for `.resizable` /
///   `.renderingMode` / `.symbolRenderingMode` / `.allowedDynamicRange` (watchOS-guarded
///   by the caller) which return `Image` and must be applied **inside** the content.
///
/// **Color override.** For the static sources the atom applies ``CosmosColorTokens/primary``
/// as the default foreground style. Because `.foregroundStyle` resolves to the *nearest*
/// ancestor that sets it, a color applied inside the content (e.g.
/// `CosmosImage { Image(systemName: "star").foregroundStyle(.red) }`) is closer to the
/// `Image` and wins; the theme color is only the fallback for the plain convenience
/// inits. SF Symbol size follows ``CosmosTheme/textStyle`` via `.font`.
///
/// **Remote (URL) behavior.** `AsyncImagePhase` is floor (iOS 15+) with three cases —
/// `.empty` (in-flight or no URL), `.success(Image)`, `.failure(any Error)` — and **no**
/// `.loading` case or `.content` accessor. Cosmos maps `.empty` → the placeholder slot,
/// `.success` → the caller's `content` closure, `.failure` → the failure slot (default:
/// an error glyph + a localized "Retry" ``CosmosButton``). The phase is authoritative for
/// the slot; `configuration.loading.isLoading` is not consulted. **Retry.** `AsyncImage`
/// has no public retry API, so the atom applies `.id(retryToken)`; the retry affordance
/// increments `retryToken`, changing view identity and forcing a fresh fetch. The
/// `retry` closure is handed to the failure slot so a custom retry affordance shares the
/// same path. **Motion.** Each slot carries `.cosmosTransition(.blurReplace)`; the
/// phase-change timing is driven through the floor `AsyncImage(url:scale:transaction:)`
/// `transaction` param with a motion-policy-gated animation (the `.cosmosAnimation`
/// chokepoint replicated via `Transaction`). Nil → instant swap (Reduce Motion instant).
/// **Haptics.** `.error` fires on failure appear (via `failureToken`), not on the retry
/// tap; the default retry ``CosmosButton`` fires its own `.impact(.light)` — no double
/// haptic. **Error reporting / tracking.** On failure appear the atom reports via
/// `configuration.error.report(_:code:)` and emits a passive tracking event. Static
/// sources emit a single `image_appear` tracking event on appear; remote images emit
/// `image_failure` on failure (no success/appear tracking — noisy for image lists).
///
/// **Cache/performance (OS-27 surface).** Inject a tuned `URLSession` (see
/// ``CosmosImageCache``) at a container via ``View/cosmosAsyncImageURLSession(_:)``
/// (or the ``cosmosImageURLSession(_:)`` alias) to share one session/cache across many
/// images. `View.asyncImageURLSession(_:)` is `@available(anyAppleOS 27.0, *)` — above
/// floor on all 5 platforms; the applier compiles out / no-ops below the gate. The shared
/// cache machinery lives alongside ``CosmosAsyncImage`` for the deprecation runway and
/// relocates to a non-deprecated home when ``CosmosAsyncImage`` is obsoleted.
///
/// **Accessibility.** Set `.cosmosAccessibilityLabel` for meaningful symbols (VoiceOver may
/// otherwise announce the raw SF Symbol name), or use a decorative init for purely
/// decorative ones. Apply `.cosmosAccessibilityLabel` on a remote image for the alt text;
/// it flows onto the image surface via `applyCosmosAccessibility`. The `.isImage` trait
/// is applied natively by `Image`; the atom does not double-apply it.
public struct CosmosImage<Content: View, Placeholder: View, Failure: View>: View {
    /// Discriminates the static (direct) render path from the remote (URL) path. Held as a
    /// single stored value so the static inits can constrain the async slot generics to
    /// `EmptyView` (the no-slot marker) and the URL inits can keep them generic — without
    /// `AnyView` erasure (slot structural identity is preserved, WWDC21-10022) and without
    /// referencing the deprecated ``CosmosIcon`` / ``CosmosAsyncImage`` types internally.
    private enum Source {
        case direct(Content, isDecorativeSymbol: Bool)
        case remote(
            url: URL?,
            scale: CGFloat,
            content: (Image) -> Content,
            placeholder: () -> Placeholder,
            failure: (any Error, @escaping () -> Void) -> Failure
        )
    }

    private let source: Source

    @Environment(\.cosmosConfiguration) private var configuration

    /// Creates an image from custom image content (apply `.resizable`/`.renderingMode`/
    /// `.symbolRenderingMode`/`.allowedDynamicRange` inside — these return `Image` and must
    /// be applied within the content, not outside the atom).
    public init(@ViewBuilder content: @escaping () -> Content) where Placeholder == EmptyView, Failure == EmptyView {
        self.source = .direct(content(), isDecorativeSymbol: false)
    }

    public var body: some View {
        if configuration.enable.isVisible {
            switch source {
            case .direct(let content, let isDecorative):
                CosmosImageDirect(content: content, isDecorativeSymbol: isDecorative)
            case .remote(let url, let scale, let content, let placeholder, let failure):
                CosmosImageRemote(
                    url: url,
                    scale: scale,
                    content: content,
                    placeholder: placeholder,
                    failure: failure
                )
            }
        } else {
            EmptyView()
        }
    }
}

// MARK: - Static convenience inits (Content == Image)

extension CosmosImage where Content == Image, Placeholder == EmptyView, Failure == EmptyView {
    /// Creates an SF Symbol image. Set an explicit `.cosmosAccessibilityLabel` for meaningful
    /// symbols (VoiceOver may otherwise announce the raw symbol name).
    public init(systemName: String) {
        self.source = .direct(Image(systemName: systemName), isDecorativeSymbol: false)
    }

    /// Creates a variable-color SF Symbol image (iOS 16+). `variableValue` in `[0, 1]`.
    public init(systemName: String, variableValue: Double) {
        self.source = .direct(Image(systemName: systemName, variableValue: variableValue), isDecorativeSymbol: false)
    }

    /// Creates a decorative SF Symbol image — hidden from VoiceOver (no label announced).
    /// SwiftUI has no `Image(decorativeSystemName:)`, so the atom hides it via the
    /// accessibility config.
    public init(decorativeSystemName name: String) {
        self.source = .direct(Image(systemName: name), isDecorativeSymbol: true)
    }

    /// Creates an image from a typed asset resource (the asset-catalog codegen type, not a
    /// string). `ImageResource` is available on all 5 platforms at the Cosmos 26 floor
    /// (iOS 17 / macOS 14 / tvOS 17 / watchOS 10 / visionOS 1).
    public init(_ resource: ImageResource) {
        self.source = .direct(Image(resource), isDecorativeSymbol: false)
    }

    /// Creates an image from a bundled asset image name.
    public init(_ name: String, bundle: Bundle? = nil) {
        self.source = .direct(Image(name, bundle: bundle), isDecorativeSymbol: false)
    }

    /// Creates a decorative asset image — natively hidden from VoiceOver (no label announced).
    public init(decorative name: String, bundle: Bundle? = nil) {
        self.source = .direct(Image(decorative: name, bundle: bundle), isDecorativeSymbol: false)
    }
}

// MARK: - Remote (URL) inits

extension CosmosImage where Placeholder == CosmosAsyncImagePlaceholder, Failure == CosmosAsyncImageFailure {
    /// Creates a remote image with Cosmos default placeholder (indeterminate ``CosmosProgress``
    /// on a `theme.colors.surface` rounded rect) and default failure slot (error glyph + a
    /// localized "Retry" ``CosmosButton``). `content` transforms the loaded `Image` (e.g.
    /// `.resizable().scaledToFill()`).
    public init(
        url: URL?,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.source = .remote(
            url: url,
            scale: scale,
            content: content,
            placeholder: { CosmosAsyncImagePlaceholder() },
            failure: { error, retry in CosmosAsyncImageFailure(error: error, retry: retry) }
        )
    }

    /// Creates a remote image from a URL **string**, parsed via `URL(string:)` (a `nil` parse
    /// behaves as `url: nil` → the placeholder/empty slot, matching `AsyncImage(url: nil)`).
    /// Otherwise identical to ``init(url:scale:content:)``.
    public init(
        url: String,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(url: URL(string: url), scale: scale, content: content)
    }
}

extension CosmosImage {
    /// Creates a remote image with custom, **typed** placeholder and failure slots. The `retry`
    /// closure handed to `failure` increments the atom's retry token (re-fetches); a custom retry
    /// affordance should call it so it shares the same re-fetch + haptic path. Slots are typed
    /// generics (`Placeholder`/`Failure`), not `AnyView`-erased, so each slot keeps its structural
    /// identity across phase swaps — the diffing win `AnyView` would forfeit (WWDC21-10022).
    public init(
        url: URL?,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder failure: @escaping (_ error: any Error, _ retry: @escaping () -> Void) -> Failure
    ) {
        self.source = .remote(url: url, scale: scale, content: content, placeholder: placeholder, failure: failure)
    }

    /// Creates a remote image from a URL **string** with custom, typed slots. See
    /// ``init(url:scale:content:placeholder:failure:)``; a `nil` `URL(string:)` parse behaves as
    /// `url: nil` → the placeholder slot.
    public init(
        url: String,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder failure: @escaping (_ error: any Error, _ retry: @escaping () -> Void) -> Failure
    ) {
        self.init(url: URL(string: url), scale: scale, content: content, placeholder: placeholder, failure: failure)
    }

    /// Creates a remote image with `AnyView`-erased custom slots. **Deprecated** — kept for the
    /// migration runway (per `VERSIONING.md`); prefer the typed generic-slot inits above so the
    /// placeholder/failure slots keep their view identity across phase swaps (WWDC21-10022).
    /// The deprecated overload is the more-constrained one, so legacy `AnyView` call sites resolve
    /// here and emit the migration warning; typed call sites resolve to the generic init.
    @available(*, deprecated, message: "Use the typed generic slot inits (placeholder/failure as typed closures, not AnyView) to preserve slot view identity (WWDC21-10022)")
    public init(
        url: URL?,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> AnyView,
        @ViewBuilder failure: @escaping (_ error: any Error, _ retry: @escaping () -> Void) -> AnyView
    ) where Placeholder == AnyView, Failure == AnyView {
        self.source = .remote(url: url, scale: scale, content: content, placeholder: placeholder, failure: failure)
    }

    /// String-URL `AnyView`-slot overload (deprecated; see the URL-typed overload above).
    @available(*, deprecated, message: "Use the typed generic slot inits (placeholder/failure as typed closures, not AnyView) to preserve slot view identity (WWDC21-10022)")
    public init(
        url: String,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> AnyView,
        @ViewBuilder failure: @escaping (_ error: any Error, _ retry: @escaping () -> Void) -> AnyView
    ) where Placeholder == AnyView, Failure == AnyView {
        self.init(url: URL(string: url), scale: scale, content: content, placeholder: placeholder, failure: failure)
    }
}

// MARK: - Render paths

/// The static render path: applies the token-driven foreground style + typography, the
/// decorative-SF-Symbol VoiceOver hide, the accessibility config, and an `image_appear`
/// tracking event. No `@State` — the static path carries no retry/failure state.
private struct CosmosImageDirect<Content: View>: View {
    let content: Content
    let isDecorativeSymbol: Bool

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    var body: some View {
        content
            .foregroundStyle(theme.colors.primary)
            .font(theme.typography.font(for: theme.textStyle))
            .accessibilityHiddenIf(isDecorativeSymbol)
            .applyCosmosAccessibility(configuration.accessibility)
            .onAppear { trackAppear() }
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "image_appear",
            component: "CosmosImage",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}

/// The remote render path: mirrors ``CosmosAsyncImage`` — `AsyncImage` phase switch with
/// `.cosmosTransition(.blurReplace)` per slot, a motion-policy-gated `Transaction`,
/// `.id(retryToken)` identity-reset retry, the OS-27 session applier, the `.error` haptic
/// on failure appear, error reporting, and tracking.
private struct CosmosImageRemote<Content: View, Placeholder: View, Failure: View>: View {
    let url: URL?
    let scale: CGFloat
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    @ViewBuilder let failure: (any Error, @escaping () -> Void) -> Failure

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.cosmosAsyncImageURLSession) private var urlSession

    @State private var retryToken: Int = 0
    @State private var failureToken: Int = 0

    /// The motion-policy-gated animation for the phase transition (the `.cosmosAnimation`
    /// chokepoint replicated via `Transaction`). Nil → instant swap (Reduce Motion instant,
    /// or motion disabled).
    private var resolvedAnimation: Animation? {
        let motion = configuration.motion
        guard CosmosMotionPolicy.shouldEmit(
            isEnabled: motion.isEnabled,
            respectReduceMotion: motion.respectReduceMotion,
            reduceMotion: reduceMotion
        ) else { return nil }
        return theme.motion.animation(for: .appear, reduceMotion: reduceMotion, policy: motion.reduceMotionPolicy)
    }

    var body: some View {
        AsyncImage(url: url, scale: scale, transaction: Transaction(animation: resolvedAnimation)) { phase in
            switch phase {
            case .success(let image):
                content(image)
                    .cosmosTransition(.blurReplace)
            case .failure(let error):
                failure(error, { retryToken &+= 1 })
                    .cosmosTransition(.blurReplace)
                    .onAppear { reportFailure(error) }
            case .empty:
                placeholder()
                    .cosmosTransition(.blurReplace)
            @unknown default:
                // `AsyncImagePhase` is a non-frozen library enum; an unknown future phase is
                // treated as the neutral placeholder slot (no loaded image, no error).
                placeholder()
                    .cosmosTransition(.blurReplace)
            }
        }
        .id(retryToken)
        .modifier(CosmosAsyncImageSessionApplier(session: urlSession))
        .cosmosHaptic(.error, trigger: failureToken)
        .applyCosmosAccessibility(configuration.accessibility)
    }

    /// Side-effects on failure appear: bump the haptic/error/tracking token, report the error, and
    /// emit a passive tracking event. Re-fires on each (re)failure since `failureToken` increments.
    private func reportFailure(_ error: any Error) {
        failureToken &+= 1
        configuration.error.report(error.localizedDescription, code: nil)
        configuration.tracking.track(.init(
            name: "image_failure",
            component: "CosmosImage",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}

// MARK: - Ergonomic aliases (the shared OS-27 surface stays with CosmosAsyncImage this minor)

/// Alias for the default placeholder slot type (defined alongside ``CosmosAsyncImage``).
public typealias CosmosImagePlaceholder = CosmosAsyncImagePlaceholder

/// Alias for the default failure slot type (defined alongside ``CosmosAsyncImage``).
public typealias CosmosImageFailure = CosmosAsyncImageFailure

extension View {
    /// Alias for ``View/cosmosAsyncImageURLSession(_:)`` — injects a shared `URLSession`
    /// (e.g. ``CosmosImageCache/defaultSession``) for the ``CosmosImage`` remote instances in
    /// this subtree. The native `View.asyncImageURLSession(_:)` it routes to is
    /// `@available(anyAppleOS 27.0, *)`; below OS 27 the applier no-ops (system default).
    public func cosmosImageURLSession(_ session: URLSession?) -> some View {
        environment(\.cosmosAsyncImageURLSession, session)
    }
}

// MARK: - Previews

#Preview("CosmosImage – SF Symbols + text styles") {
    VStack(spacing: 12) {
        CosmosImage(systemName: "star.fill").cosmosFont(.largeTitle)
        CosmosImage(systemName: "gearshape").cosmosFont(.title)
        CosmosImage(systemName: "bell.badge.fill").cosmosFont(.headline)
        CosmosImage(systemName: "battery.25", variableValue: 0.25).cosmosFont(.title)
        // Decorative SF Symbol — hidden from VoiceOver.
        CosmosImage(decorativeSystemName: "chevron.right").cosmosFont(.headline)
    }
    .padding()
}

#Preview("CosmosImage – color override inside content") {
    VStack(spacing: 12) {
        // Default theme color.
        CosmosImage(systemName: "heart.fill")
        // Override wins (foregroundStyle inside the content is closer to the Image).
        CosmosImage { Image(systemName: "heart.fill").foregroundStyle(.red) }
        // Resizable asset-style + symbol rendering mode, configured inside the content.
        CosmosImage { Image(systemName: "person.crop.circle.fill").resizable().symbolRenderingMode(.hierarchical) }
            .frame(width: 48, height: 48)
    }
    .padding()
}

#Preview("CosmosImage – remote (default load)") {
    CosmosImage(url: CosmosMock.imageURL(seed: "cosmos-g", width: 480, height: 320)) { image in
        image.resizable().scaledToFill()
    }
    .frame(width: 320, height: 220)
    .clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
    .padding()
}

#Preview("CosmosImage – remote (string URL + custom slots)") {
    CosmosImage(
        url: "https://picsum.photos/seed/cosmos-custom/480/320",
        content: { $0.resizable().scaledToFill() },
        placeholder: { Color.gray.opacity(0.15) },
        failure: { _, retry in
            VStack(spacing: 8) {
                Image(systemName: "photo.badge.exclamation")
                    .font(.system(size: 28))
                CosmosButton("cosmos.asyncimage.retry", action: retry)
                    .cosmosButtonStyle(.secondary)
            }
        }
    )
    .frame(width: 320, height: 220)
    .clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
    .padding()
}

#Preview("CosmosImage – error + retry", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosImage(url: CosmosMock.badImageURL()) { image in
            image.resizable().scaledToFill()
        }
        .frame(width: 280, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
        .padding()
    }
}

#Preview("CosmosImage – dark + accessibility size", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosImage(url: CosmosMock.imageURL(seed: "cosmos-dark", width: 480, height: 320)) { image in
            image.resizable().scaledToFill()
        }
        .frame(width: 280, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
        .padding()
    }
}

#Preview("CosmosImage – reduce motion", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosImage(url: CosmosMock.imageURL(seed: "cosmos-rm", width: 480, height: 320)) { image in
            image.resizable().scaledToFill()
        }
        .frame(width: 280, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
        .cosmosPreviewVariant(.reduceMotion)
        .padding()
    }
}

#Preview("CosmosImage – RTL + dark + accessibility (static)", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(spacing: 12) {
            CosmosImage(systemName: "wand.and.stars")
                .cosmosFont(.title)
                .cosmosAccessibilityLabel("Magic")
            CosmosImage { Image(systemName: "trophy.fill").foregroundStyle(.yellow) }
                .cosmosFont(.largeTitle)
        }
        .padding()
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3, layoutDirection: .rightToLeft)
    }
}