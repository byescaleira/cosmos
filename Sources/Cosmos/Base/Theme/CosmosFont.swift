import CoreText
import Foundation

/// Registers bundled `.ttf` fonts with CoreText (no UIKit).
///
/// Call ``registerIfNeeded()`` once at app launch, or rely on atoms to call it lazily.
/// Registration is process-scoped and idempotent.
///
/// **Concurrency:** uses the once-token pattern — a `static let` global is initialized
/// exactly once, thread-safely, by the Swift runtime (`swift_once`). No lock primitive
/// (`NSLock`/`DispatchQueue`/`Mutex`) and no `nonisolated(unsafe)` mutable flag are needed,
/// so this is fully warning-free under Swift 6 language mode.
public enum CosmosFont {

    /// Once-token whose initialization side-effect registers every bundled font exactly once.
    private enum _Registration {
        static let performed: Void = {
            for url in CosmosFont.bundledFontURLs() {
                _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }()
    }

    /// Registers all bundled `.ttf` fonts exactly once, thread-safely. Safe to call
    /// repeatedly from any context.
    public static func registerIfNeeded() {
        // Touching the lazy global triggers `swift_once`; subsequent calls are no-ops.
        _ = _Registration.performed
    }

    /// Locates bundled `.ttf` resources, searching both the `Fonts` subdirectory and the
    /// module bundle root (`.process("Resources")` may flatten the directory).
    static func bundledFontURLs() -> [URL] {
        let bundle = Bundle.module
        var urls = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: "Fonts") ?? []
        if urls.isEmpty {
            urls = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? []
        }
        return urls
    }
}