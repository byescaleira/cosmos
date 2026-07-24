import SwiftUI
import Foundation

/// A remote-image atom wrapping `AsyncImage` with an explicit **slot architecture**
/// (placeholder / error / retry), policy-gated **phase-transition motion**, optional
/// **cache/performance** via a shared `URLSession`, and cross-cutting error reporting + haptics +
/// tracking — the four concerns flagged for this wave.
///
/// State and theme are **global**: this atom reads ``CosmosConfiguration`` and ``CosmosTheme``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. There is **no**
/// `CosmosAsyncImageStyle` selector — `AsyncImage` has no style protocol (verified in the Xcode 27
/// `.swiftinterface`), so this atom wraps a `View` per the Cosmos wrap-view discipline, like
/// ``CosmosScrollView``. Wave G touches `CosmosTheme` not at all.
///
/// **Phase model.** `AsyncImagePhase` is floor (iOS 15+) with three cases — `.empty` (in-flight or
/// no URL; there is **no** `.loading` case), `.success(Image)`, `.failure(any Error)` — and **no**
/// `.content` accessor (extract the loaded view via `phase.image`). Cosmos maps: `.empty` → the
/// placeholder slot, `.success` → the caller's `content` closure, `.failure` → the failure slot
/// (default: an error glyph + a "Retry" ``CosmosButton``). The phase is **authoritative** for the
/// slot; `configuration.loading.isLoading` is **not** consulted (forcing a placeholder over a
/// loaded image would be wrong). The `configuration.loading.delay` / `minimumDisplayTime`
/// placeholder-flicker gate is a documented Wave-G **refinement**, not this wave.
///
/// **Retry.** `AsyncImage` has no public retry API, so the atom applies `.id(retryToken)` to the
/// underlying `AsyncImage`; the retry affordance increments `retryToken`, which changes the view's
/// identity and forces a fresh fetch. The `retry` closure is handed to the failure slot so a custom
/// retry affordance triggers the same path.
///
/// **Motion (phase transitions).** Each slot carries `.cosmosTransition(.blurReplace)` — the
/// plumbed, reduce-motion-safe preset (substitutes to `.opacity`/`.identity` under Reduce Motion).
/// The phase-change *timing* is driven through the floor `AsyncImage(url:scale:transaction:content:)`
/// `transaction` param with a **motion-policy-gated** animation (the `.cosmosAnimation` chokepoint
/// replicated via `Transaction`, since the phase swap is driven by the init's `transaction`, not a
/// `.animation` modifier). Nil → instant swap (Reduce Motion instant policy).
///
/// **Haptics.** `.error` fires **on failure appear** (via `failureToken`), not on the retry tap —
/// semantically correct (the error occurred). The default retry ``CosmosButton`` fires its own
/// `.impact(.light)` on tap; no double haptic. Gated by ``CosmosHapticsPolicy`` + Reduce Motion.
///
/// **Error reporting / tracking.** On failure appear the atom reports via
/// `configuration.error.report(_:code:)` (atoms describe failures as `message`+`code`, not
/// `any Error` — `any Error` is not `Sendable`) and emits a passive `track(.appear)` event. No
/// appear-tracking on success (a list of many images would be noisy); opt-in tracking belongs on
/// interactive content, per the structural discipline.
///
/// **Cache/performance (OS-27 surface).** `View.asyncImageURLSession(_:)` is
/// `@available(anyAppleOS 27.0, *)` — above-floor on all 5 platforms (no carve-out; verified in
/// the Xcode 27 `.swiftinterface`). Inject a tuned `URLSession` (see ``CosmosImageCache``) at a
/// container via ``View/cosmosAsyncImageURLSession(_:)`` to share one session/cache across many
/// images. OS-26 and Xcode 26/Swift 6.3 fall back to the system default `URLSession` (the applier
/// compiles out / no-ops below the gate). There is **no** SwiftUI `URLCache` symbol — tuning is
/// via `URLSessionConfiguration.urlCache` on the session passed in.
///
/// **Forward compatibility.** `content: (Image) -> Content` takes the loaded `Image` and returns a
/// view, so this atom is a clean building block: the later unified `CosmosImage` (SF Symbols +
/// resource + URL) will delegate its `.url` case to ``CosmosAsyncImage`` and its `.system` /
/// `.resource` cases to ``CosmosIcon``. No `CosmosImage` work in this wave.
///
/// **Accessibility.** Apply `.cosmosAccessibilityLabel` here for the image alt text; it flows onto
/// the image surface via `applyCosmosAccessibility`. The default failure retry ``CosmosButton``
/// carries its own accessibility. Dynamic Type flows through the slot views.
public struct CosmosAsyncImage<Content: View, Placeholder: View, Failure: View>: View {
    private let url: URL?
    private let scale: CGFloat
    @ViewBuilder private let content: (Image) -> Content
    @ViewBuilder private let placeholder: () -> Placeholder
    @ViewBuilder private let failure: (any Error, @escaping () -> Void) -> Failure

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.cosmosAsyncImageURLSession) private var urlSession

    @State private var retryToken: Int = 0
    @State private var failureToken: Int = 0

    /// Creates an async image with Cosmos default placeholder (indeterminate ``CosmosProgress`` on
    /// a `theme.colors.surface` rounded rect) and default failure slot (error glyph + a "Retry"
    /// ``CosmosButton``). `content` transforms the loaded `Image` (e.g. `.resizable().scaledToFill()`).
    public init(
        url: URL?,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> Content
    ) where Placeholder == CosmosAsyncImagePlaceholder, Failure == CosmosAsyncImageFailure {
        self.url = url
        self.scale = scale
        self.content = content
        self.placeholder = { CosmosAsyncImagePlaceholder() }
        self.failure = { error, retry in CosmosAsyncImageFailure(error: error, retry: retry) }
    }

    /// Creates an async image with custom, **typed** placeholder and failure slots. The `retry`
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
        self.url = url
        self.scale = scale
        self.content = content
        self.placeholder = placeholder
        self.failure = failure
    }

    /// Creates an async image with `AnyView`-erased custom slots. **Deprecated** — kept for the
    /// migration runway (per `VERSIONING.md`); prefer the typed generic-slot init above so the
    /// placeholder/failure slots keep their view identity across phase swaps (WWDC21-10022). The
    /// deprecated overload is the more-constrained one, so legacy `AnyView` call sites resolve here
    /// and emit the migration warning; typed call sites resolve to the generic init.
    @available(*, deprecated, message: "Use the typed generic slot inits (placeholder/failure as typed closures, not AnyView) to preserve slot view identity (WWDC21-10022)")
    public init(
        url: URL?,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> AnyView,
        @ViewBuilder failure: @escaping (_ error: any Error, _ retry: @escaping () -> Void) -> AnyView
    ) where Placeholder == AnyView, Failure == AnyView {
        self.url = url
        self.scale = scale
        self.content = content
        self.placeholder = placeholder
        self.failure = failure
    }

    /// The motion-policy-gated animation for the phase transition (the `.cosmosAnimation` chokepoint
    /// replicated via `Transaction`). Nil → instant swap (Reduce Motion instant, or motion disabled).
    private var resolvedAnimation: Animation? {
        let motion = configuration.motion
        guard CosmosMotionPolicy.shouldEmit(
            isEnabled: motion.isEnabled,
            respectReduceMotion: motion.respectReduceMotion,
            reduceMotion: reduceMotion
        ) else { return nil }
        return theme.motion.animation(for: .appear, reduceMotion: reduceMotion, policy: motion.reduceMotionPolicy)
    }

    public var body: some View {
        if configuration.enable.isVisible {
            AsyncImage(url: url, scale: scale, transaction: Transaction(animation: resolvedAnimation)) { phase in
                switch phase {
                case .success(let image):
                    content(image)
                        .cosmosTransition(.blurReplace)
                case .failure(let error):
                    failureSlot(error)
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
        } else {
            EmptyView()
        }
    }

    /// Builds the failure slot, handing it the `retry` closure (increments `retryToken` → re-fetch).
    private func failureSlot(_ error: any Error) -> Failure {
        failure(error, { retryToken &+= 1 })
    }

    /// Side-effects on failure appear: bump the haptic/error/tracking token, report the error, and
    /// emit a passive tracking event. Re-fires on each (re)failure since `failureToken` increments.
    private func reportFailure(_ error: any Error) {
        failureToken &+= 1
        configuration.error.report(error.localizedDescription, code: nil)
        configuration.tracking.track(.init(
            name: "asyncimage_failure",
            component: "CosmosAsyncImage",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}

// MARK: - Default slot views

/// The default placeholder slot: an indeterminate ``CosmosProgress`` centered on a
/// `theme.colors.surface` rounded rect. Reads the theme from the environment. Public so it can
/// serve as the constrained default `Placeholder` of ``CosmosAsyncImage`` and be reused as a
/// custom slot.
public struct CosmosAsyncImagePlaceholder: View {
    @Environment(\.cosmosTheme) private var theme

    public init() {}

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous)
                .fill(theme.colors.surface)
            CosmosProgress()
        }
    }
}

/// The default failure slot: an `exclamationmark.triangle` glyph in `theme.colors.error`
/// (hierarchical rendering, floor) + a localized "Retry" ``CosmosButton`` wired to the atom's
/// `retry` closure. Public so it can serve as the constrained default `Failure` of
/// ``CosmosAsyncImage`` and be reused as a custom slot.
public struct CosmosAsyncImageFailure: View {
    let error: any Error
    let retry: () -> Void

    @Environment(\.cosmosTheme) private var theme

    public init(error: any Error, retry: @escaping () -> Void) {
        self.error = error
        self.retry = retry
    }

    public var body: some View {
        VStack(spacing: CosmosSpacingTokens.small) {
            Image(systemName: "exclamationmark.triangle")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 32))
                .foregroundStyle(theme.colors.error)
            CosmosButton("cosmos.asyncimage.retry", action: retry)
                .cosmosButtonStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous)
                .fill(theme.colors.surface)
        )
    }
}

// MARK: - Cache / performance (OS-27 surface)

/// A tuned `URLSession` factory for ``CosmosAsyncImage``. Native `AsyncImage` performs the fetch;
/// Cosmos only configures the transport/cache (there is no SwiftUI `URLCache` symbol — tuning is
/// via `URLSessionConfiguration.urlCache`). `Sendable` namespace with a once-token `static let`
/// default session (no lock primitive — `URLSession` is `Sendable`).
public enum CosmosImageCache: Sendable {
    /// Default cache sizing: 16 MB memory, 128 MB disk, under the `cosmos-async-image` disk path.
    public static let defaultSession: URLSession = session()

    /// Builds a `URLSession` with a tuned `URLCache` and sane request/resource timeouts.
    public static func session(
        memoryCapacity: Int = 16 * 1024 * 1024,
        diskCapacity: Int = 128 * 1024 * 1024
    ) -> URLSession {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity,
            diskPath: "cosmos-async-image"
        )
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.requestCachePolicy = .useProtocolCachePolicy
        return URLSession(configuration: config)
    }
}

// MARK: - Environment + modifier

extension EnvironmentValues {
    /// The shared `URLSession` injected at a container to tune ``CosmosAsyncImage`` fetching/cache.
    /// `URLSession` is `Sendable`, so this `@Entry` value satisfies the Sendable requirement with
    /// zero concurrency warnings. `nil` (default) → the system default `URLSession`.
    @Entry public var cosmosAsyncImageURLSession: URLSession? = nil
}

extension View {
    /// Injects a shared `URLSession` (e.g. ``CosmosImageCache/defaultSession``) for the
    /// ``CosmosAsyncImage`` instances in this subtree. Applied at a container, this shares one
    /// session/cache across many images. The native `View.asyncImageURLSession(_:)` it routes to is
    /// `@available(anyAppleOS 27.0, *)`; below OS 27 the applier no-ops (system default).
    public func cosmosAsyncImageURLSession(_ session: URLSession?) -> some View {
        environment(\.cosmosAsyncImageURLSession, session)
    }
}

/// Applies the OS-27 `View.asyncImageURLSession(_:)` when a session is injected, else passthrough.
/// Dual-gated like the ``CosmosTextFieldStyle`` `.bordered` applier: `#if swift(>=6.4)` compiles the
/// OS-27 SDK symbol in under Xcode 27 / Swift 6.4 and out on Xcode 26 / Swift 6.3; `if #available`
/// degrades to passthrough on an OS-26 device under Xcode 27.
private struct CosmosAsyncImageSessionApplier: ViewModifier {
    let session: URLSession?

    func body(content: Content) -> some View {
        #if swift(>=6.4)
        if let session {
            if #available(iOS 27, macOS 27, watchOS 27, tvOS 27, visionOS 27, *) {
                content.asyncImageURLSession(session)
            } else {
                content
            }
        } else {
            content
        }
        #else
        // OS-27 SDK unavailable on this toolchain (Swift < 6.4 / Xcode 26) — system default URLSession.
        content
        #endif
    }
}

// MARK: - Per-platform availability table (pure, platform-agnostic, testable)

/// Pure per-platform availability table for the OS-27 ``CosmosAsyncImage`` cache surface, derived
/// from the Xcode 27 `.swiftinterface`:
/// - `View.asyncImageURLSession(_:)` is `@available(anyAppleOS 27.0, *)` — **all 5 platforms** at
///   OS 27 (above floor; no platform is excluded). The table reports the **platform** gate only
///   (true on all 5); the OS-27 version gate is applied at runtime in
///   ``CosmosAsyncImageSessionApplier``.
public enum CosmosAsyncImageAvailability {
    /// `true` on all 5 platforms (`asyncImageURLSession` is `@available(anyAppleOS 27, *)` — no
    /// platform is excluded; the OS-27 version gate is runtime, in the session applier).
    public static func urlSessionInjectionAvailable(on platform: CosmosPlatform) -> Bool {
        true
    }
}

// MARK: - Previews

#Preview("AsyncImage – default load") {
    CosmosAsyncImage(url: CosmosMock.imageURL(seed: "cosmos-g", width: 480, height: 320)) { image in
        image.resizable().scaledToFill()
    }
    .frame(width: 320, height: 220)
    .clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
    .padding()
}

#Preview("AsyncImage – custom slots") {
    CosmosAsyncImage(
        url: CosmosMock.imageURL(seed: "cosmos-custom", width: 480, height: 320),
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

#Preview("AsyncImage – error + retry", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosAsyncImage(url: CosmosMock.badImageURL()) { image in
            image.resizable().scaledToFill()
        }
        .frame(width: 280, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
        .padding()
    }
}

#Preview("AsyncImage – dark + accessibility size", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosAsyncImage(url: CosmosMock.imageURL(seed: "cosmos-dark", width: 480, height: 320)) { image in
            image.resizable().scaledToFill()
        }
        .frame(width: 280, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
        .cosmosPreviewVariant(.dark)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
        .padding()
    }
}

#Preview("AsyncImage – reduce motion", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosAsyncImage(url: CosmosMock.imageURL(seed: "cosmos-rm", width: 480, height: 320)) { image in
            image.resizable().scaledToFill()
        }
        .frame(width: 280, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
        .cosmosPreviewVariant(.reduceMotion)
        .padding()
    }
}

#Preview("AsyncImage – RTL", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        CosmosAsyncImage(url: CosmosMock.imageURL(seed: "cosmos-rtl", width: 480, height: 320)) { image in
            image.resizable().scaledToFill()
        }
        .frame(width: 280, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: CosmosRadiusTokens.medium, style: .continuous))
        .cosmosPreviewVariant(.rtl)
        .padding()
    }
}