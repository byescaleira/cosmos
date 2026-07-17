import Foundation
import SwiftUI
import Synchronization

/// Deterministic scalar fixtures for previews and tests. No third-party dependencies, no UIKit.
///
/// The **primary** API takes `inout CosmosPreviewRNG` (pure, zero shared state; `Sendable` is
/// derived). Convenience overloads draw from ``shared``, a `Mutex`-protected generator — the
/// project-compliant mutable-state pattern (CLAUDE.md: no raw locks, no `nonisolated(unsafe)`
/// mutable globals). Call ``reset(seed:)`` at the top of a preview block to make it reproducible
/// from its start.
public enum CosmosMock {
    /// Shared `Mutex`-protected generator for the convenience overloads.
    public static let shared = Mutex<CosmosPreviewRNG>(CosmosPreviewRNG())

    /// Re-seeds the shared generator so a preview block is reproducible from its top.
    public static func reset(seed: UInt64 = CosmosPreview.defaultSeed) {
        shared.withLock { $0 = CosmosPreviewRNG(seed: seed) }
    }

    // MARK: - String / text

    public static func word(using g: inout CosmosPreviewRNG) -> String {
        CosmosMockWordlists.lorem.randomElement(using: &g) ?? "cosmos"
    }

    public static func words(_ count: Int, using g: inout CosmosPreviewRNG) -> [String] {
        guard count > 0 else { return [] }
        return (0..<count).map { _ in word(using: &g) }
    }

    public static func sentence(wordCount: Int = 8, using g: inout CosmosPreviewRNG) -> String {
        guard wordCount > 0 else { return "" }
        var words = words(wordCount, using: &g)
        words[0] = capitalize(words[0])
        return words.joined(separator: " ") + "."
    }

    public static func paragraph(sentenceCount: Int = 4, using g: inout CosmosPreviewRNG) -> String {
        guard sentenceCount > 0 else { return "" }
        return (0..<sentenceCount).map { _ in sentence(wordCount: 5 + Int.random(in: 0...8, using: &g), using: &g) }
            .joined(separator: " ")
    }

    public static func lorem(paragraphs: Int = 2, using g: inout CosmosPreviewRNG) -> String {
        guard paragraphs > 0 else { return "" }
        return (0..<paragraphs).map { _ in paragraph(using: &g) }
            .joined(separator: "\n\n")
    }

    /// Random string of `length` characters drawn from `charset` (ASCII range 0..<128 is scanned,
    /// which covers `.alphanumerics`, `.letters`, `.punctuationCharacters`, etc. — sufficient for
    /// mock data).
    public static func string(
        length: Int,
        charset: CharacterSet = .alphanumerics,
        using g: inout CosmosPreviewRNG
    ) -> String {
        guard length > 0 else { return "" }
        let pool = scalars(in: charset)
        guard !pool.isEmpty else { return "" }
        return String((0..<length).map { _ in pool.randomElement(using: &g)! })
    }

    // MARK: - Numbers (range-aware, Locale-aware)

    public static func int(in range: Range<Int> = 0..<100, using g: inout CosmosPreviewRNG) -> Int {
        Int.random(in: range, using: &g)
    }

    public static func double(in range: ClosedRange<Double> = 0...1, using g: inout CosmosPreviewRNG) -> Double {
        Double.random(in: range, using: &g)
    }

    public static func decimal(
        in range: ClosedRange<Decimal> = 0...1_000,
        using g: inout CosmosPreviewRNG
    ) -> Decimal {
        let lo = doubleValue(range.lowerBound)
        let hi = doubleValue(range.upperBound)
        guard lo <= hi else { return range.lowerBound }
        return Decimal(Double.random(in: lo...hi, using: &g))
    }

    /// Currency-formatted string for a random amount in `range`, using `locale`'s currency
    /// formatter (`NumberFormatter` — UIKit-free).
    public static func currency(
        amountIn range: ClosedRange<Double> = 0...1_000,
        locale: Locale = .current,
        using g: inout CosmosPreviewRNG
    ) -> String {
        let amount = Double.random(in: range, using: &g)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: NSNumber(value: amount)) ?? String(amount)
    }

    /// Percent-formatted string for a random ratio in `range` (0...1 → 0%…100%).
    public static func percentage(
        in range: ClosedRange<Double> = 0...1,
        using g: inout CosmosPreviewRNG
    ) -> String {
        let value = Double.random(in: range, using: &g)
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.locale = .current
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    /// A random large magnitude (e.g. for counters/stats), in 1_000…10_000_000.
    public static func largeValue(using g: inout CosmosPreviewRNG) -> Double {
        Double.random(in: 1_000...10_000_000, using: &g)
    }

    // MARK: - Date / UUID

    public static func date(
        in range: ClosedRange<Date> = .distantPast...Date(timeIntervalSinceNow: 365 * 24 * 3600),
        using g: inout CosmosPreviewRNG
    ) -> Date {
        let span = range.upperBound.timeIntervalSince(range.lowerBound)
        guard span > 0 else { return range.lowerBound }
        let offset = Double.random(in: 0...span, using: &g)
        return Date(timeIntervalSince1970: range.lowerBound.timeIntervalSince1970 + offset)
    }

    public static func uuid(using g: inout CosmosPreviewRNG) -> UUID {
        var bytes = [UInt8](repeating: 0, count: 16)
        for i in 0..<16 { bytes[i] = UInt8.random(in: 0...255, using: &g) }
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }

    // MARK: - Color (no UIKit — Color(hue:saturation:brightness:opacity:))

    public static func color(using g: inout CosmosPreviewRNG) -> Color {
        color(brightnessIn: 0.6...0.95, using: &g)
    }

    public static func color(
        brightnessIn b: ClosedRange<Double> = 0.2...0.9,
        using g: inout CosmosPreviewRNG
    ) -> Color {
        let hue = Double.random(in: 0...1, using: &g)
        let saturation = Double.random(in: 0.45...0.9, using: &g)
        let brightness = Double.random(in: b, using: &g)
        return Color(hue: hue, saturation: saturation, brightness: brightness, opacity: 1)
    }

    // MARK: - Network-shaped scalars

    public static func url(using g: inout CosmosPreviewRNG) -> URL {
        let domain = CosmosMockWordlists.domains.randomElement(using: &g) ?? "example.com"
        let path = word(using: &g)
        return URL(string: "https://\(domain)/\(path)") ?? URL(string: "https://example.com")!
    }

    public static func email(using g: inout CosmosPreviewRNG) -> String {
        let a = word(using: &g)
        let b = word(using: &g)
        let domain = CosmosMockWordlists.domains.randomElement(using: &g) ?? "example.com"
        return "\(a).\(b)@\(domain)"
    }

    public static func personName(using g: inout CosmosPreviewRNG) -> String {
        let first = CosmosMockWordlists.firstNames.randomElement(using: &g) ?? "Aria"
        let last = CosmosMockWordlists.lastNames.randomElement(using: &g) ?? "Sterling"
        return "\(first) \(last)"
    }

    /// Naive locale-flavored phone number (random digits; BR vs. US pattern, else generic).
    public static func phone(locale: Locale = .current, using g: inout CosmosPreviewRNG) -> String {
        let digits = (0..<10).map { _ in Int.random(in: 0...9, using: &g) }
        let id = locale.identifier
        if id.hasPrefix("pt") || id.hasPrefix("55") {
            return "+55 (\(digits[0])\(digits[1])) \(digits[2])\(digits[3])\(digits[4])\(digits[5])\(digits[6])-\(digits[7])\(digits[8])\(digits[9])"
        } else {
            return "+1 (\(digits[0])\(digits[1])\(digits[2])) \(digits[3])\(digits[4])\(digits[5])-\(digits[6])\(digits[7])\(digits[8])\(digits[9])"
        }
    }

    public static func addressLine(using g: inout CosmosPreviewRNG) -> String {
        let number = Int.random(in: 1...9999, using: &g)
        let street = capitalize(word(using: &g))
        return "\(number) \(street) St"
    }

    // MARK: - Convenience overloads (draw from the shared Mutex-protected generator)

    public static func word() -> String { shared.withLock { word(using: &$0) } }
    public static func words(_ count: Int) -> [String] { shared.withLock { words(count, using: &$0) } }
    public static func sentence(wordCount: Int = 8) -> String { shared.withLock { sentence(wordCount: wordCount, using: &$0) } }
    public static func paragraph(sentenceCount: Int = 4) -> String { shared.withLock { paragraph(sentenceCount: sentenceCount, using: &$0) } }
    public static func lorem(paragraphs: Int = 2) -> String { shared.withLock { lorem(paragraphs: paragraphs, using: &$0) } }
    public static func string(length: Int, charset: CharacterSet = .alphanumerics) -> String {
        shared.withLock { string(length: length, charset: charset, using: &$0) }
    }
    public static func int(in range: Range<Int> = 0..<100) -> Int { shared.withLock { int(in: range, using: &$0) } }
    public static func double(in range: ClosedRange<Double> = 0...1) -> Double { shared.withLock { double(in: range, using: &$0) } }
    public static func decimal(in range: ClosedRange<Decimal> = 0...1_000) -> Decimal { shared.withLock { decimal(in: range, using: &$0) } }
    public static func currency(amountIn range: ClosedRange<Double> = 0...1_000, locale: Locale = .current) -> String {
        shared.withLock { currency(amountIn: range, locale: locale, using: &$0) }
    }
    public static func percentage(in range: ClosedRange<Double> = 0...1) -> String {
        shared.withLock { percentage(in: range, using: &$0) }
    }
    public static func largeValue() -> Double { shared.withLock { largeValue(using: &$0) } }
    public static func date(in range: ClosedRange<Date> = .distantPast...Date(timeIntervalSinceNow: 365 * 24 * 3600)) -> Date {
        shared.withLock { date(in: range, using: &$0) }
    }
    public static func uuid() -> UUID { shared.withLock { uuid(using: &$0) } }
    public static func color() -> Color { shared.withLock { color(using: &$0) } }
    public static func color(brightnessIn b: ClosedRange<Double> = 0.2...0.9) -> Color {
        shared.withLock { color(brightnessIn: b, using: &$0) }
    }
    public static func url() -> URL { shared.withLock { url(using: &$0) } }
    public static func email() -> String { shared.withLock { email(using: &$0) } }
    public static func personName() -> String { shared.withLock { personName(using: &$0) } }
    public static func phone(locale: Locale = .current) -> String { shared.withLock { phone(locale: locale, using: &$0) } }
    public static func addressLine() -> String { shared.withLock { addressLine(using: &$0) } }
    public static func sfSymbol() -> String {
        shared.withLock { g in CosmosMockWordlists.sfSymbols.randomElement(using: &g) ?? "gearshape" }
    }

    // MARK: - Private helpers

    private static func capitalize(_ s: String) -> String {
        guard let first = s.first else { return s }
        return String(first).uppercased() + s.dropFirst()
    }

    /// ASCII scalars (0..<128) contained in `charset` — covers the common mock charsets.
    private static func scalars(in charset: CharacterSet) -> [Character] {
        (0..<128).compactMap { code in
            guard let scalar = Unicode.Scalar(code), charset.contains(scalar) else { return nil }
            return Character(scalar)
        }
    }

    private static func doubleValue(_ d: Decimal) -> Double {
        NSDecimalNumber(decimal: d).doubleValue
    }
}