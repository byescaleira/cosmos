import Testing

/// Shared `Tag` categories for the Cosmos test suite.
///
/// Swift Testing `@Tag`s (Xcode 26 / Swift Testing 6.0) let the suite be filtered at run time
/// with `--tag` / `--skip-tag` (and in Xcode's test navigator) without recompiling — useful for a
/// 5-platform library where a fast smoke gate or a platform-availability subset is wanted on CI.
/// Declare tags once here as the single source; apply them per-test via `@Test(.tags(.smoke))`.
///
/// - `smoke`: fast happy-path construction tests — run first as a gate before the full suite.
/// - `selector`: tests iterating a selector/variant enumeration (`@Test(arguments:)`).
/// - `availability`: tests gating platform-availability behavior via `.disabled(if:)` (the test
///   stays registered and is reported as skipped on the unsupported host, rather than invisible —
///   WWDC24-10179). Preferred over `#if os()` guards that hide tests entirely.
extension Tag {
    @Tag static var smoke: Tag
    @Tag static var selector: Tag
    @Tag static var availability: Tag
}