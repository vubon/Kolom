import Foundation

// MARK: - DictionaryService
// Protocol defining the dictionary API used by the CandidateEngine.
// Concrete implementations (JSON, SQLite) are hidden behind this interface.

protocol DictionaryService: AnyObject {
    /// Find all entries that exactly match the given Bengali word.
    func exactLookup(_ word: String) -> [DictionaryEntry]
    /// Find all entries whose word begins with the given prefix.
    func prefixLookup(_ prefix: String) -> [DictionaryEntry]
    /// Return all entries (for testing / export purposes).
    var allEntries: [DictionaryEntry] { get }
}
