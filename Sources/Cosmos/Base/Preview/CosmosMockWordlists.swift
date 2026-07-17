import Foundation

/// Bundled, `Sendable` word lists for deterministic mock generation: a public-domain Lorem
/// corpus plus first/last-name, domain, and SF Symbol arrays. No PII, no network.
public enum CosmosMockWordlists {
    /// Classic public-domain Lorem ipsum corpus (~60 words).
    public static let lorem: [String] = [
        "lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit",
        "sed", "eiusmod", "tempor", "incididunt", "labore", "magna", "aliqua", "enim",
        "minim", "veniam", "quis", "nostrud", "exercitation", "ullamco", "laboris", "nisi",
        "aliquip", "commodo", "consequat", "duis", "aute", "irure", "reprehenderit", "voluptate",
        "velit", "esse", "cillum", "fugiat", "nulla", "pariatur", "excepteur", "sint",
        "occaecat", "cupidatat", "proident", "sunt", "culpa", "officia", "deserunt", "mollit",
        "anim", "laborum", "vivamus", "vestibulum", "fermentum", "pretium", "sapien", "tincidunt",
        "semper", "porttitor", "curabitur", "mattis",
    ]

    /// Generic, fabricated first names (no real-person PII).
    public static let firstNames: [String] = [
        "Aria", "Bran", "Cove", "Dax", "Eliot", "Fern", "Glen", "Harlow",
        "Indigo", "Jules", "Kai", "Lior", "Marlow", "Niko", "Oz", "Pax",
        "Quinn", "Remy", "Sage", "Tova", "Uri", "Vesper", "Wren", "Yael",
    ]

    /// Generic, fabricated last names (no real-person PII).
    public static let lastNames: [String] = [
        "Aldrin", "Bellweather", "Carrick", "Drift", "Elwood", "Fairbank", "Garrison", "Holloway",
        "Ironwood", "Jovanovic", "Kettering", "Larkspur", "Marsh", "Northgate", "Ortega", "Pemberton",
        "Quill", "Renwick", "Sterling", "Thackeray", "Underhill", "Vance", "Whitford", "Yardley",
    ]

    /// Reserved/example domains (RFC 2606 `.example`/`.test`-style) — safe for fixtures.
    public static let domains: [String] = ["example.com", "cosmos.dev", "preview.test", "mail.example"]

    /// A small set of SF Symbol names available across all 5 platforms.
    public static let sfSymbols: [String] = [
        "gearshape", "star", "heart", "bell", "bookmark", "calendar", "cart", "clock",
        "cloud", "flag", "folder", "gift", "globe", "house", "magnifyingglass", "map",
    ]
}