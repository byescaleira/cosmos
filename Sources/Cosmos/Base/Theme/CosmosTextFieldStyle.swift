import Foundation

/// Visual variant selectors for ``CosmosTextField`` (and the shared text-input chrome).
///
/// `.automatic`/`.plain` resolve to the matching native `TextFieldStyle` on all 5 platforms at
/// the Cosmos 26 floor. `.bordered` (`BorderedTextFieldStyle`) + `.textInputBorderShape` are
/// `@available(anyAppleOS 27.0)` — the **next** OS above the Cosmos 26 floor (unlike
/// `glassProminent`/`glassEffect`, which are real OS 26). It is gated to OS 27 in the applier and
/// falls back to `.automatic` on OS 26 (the floor), rendering on OS 27+ devices. `.cosmos` routes
/// through a token-driven chrome (padding + material background + clipShape + animated focus
/// border) composed in the atom body rather than a `TextFieldStyle` conformance:
/// `TextFieldStyle._body` is an opaque SPI whose `_Label` has `Body == Never` and cannot read the
/// text binding or a `@FocusState`, so the focus-aware border is composed where focus is visible.
public enum CosmosTextFieldStyle: String, Sendable, Codable, CaseIterable {
    case automatic
    case plain
    case bordered
    case cosmos
}