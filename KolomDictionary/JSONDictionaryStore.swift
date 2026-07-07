import Foundation

// MARK: - JSONDictionaryStore
// Loads the bundled kolom-dictionary.json file and builds an in-memory
// index for O(1) exact lookup and O(k) prefix search.
// Conforms to DictionaryService — the rest of the system never sees this class.
//
// Swift 6 concurrency note:
// @unchecked Sendable is safe here because all mutable state is written
// exactly once inside init() — before the instance is ever shared across
// concurrency boundaries. After init() returns, the store is read-only.

final class JSONDictionaryStore: DictionaryService, @unchecked Sendable {

    // MARK: - Shared singleton
    // nonisolated(unsafe): Swift 6 requires this for global lets whose type
    // is Sendable via @unchecked — we guarantee safety through initialisation order.
    static let shared = JSONDictionaryStore()

    // MARK: - Storage

    private(set) var allEntries: [DictionaryEntry] = []

    /// Exact word → entry index for O(1) exact lookup
    private var exactIndex: [String: [DictionaryEntry]] = [:]

    /// Prefix trie (simplified: prefix string → matching entries)
    /// Rebuilt once at load time from the full word list.
    private var prefixIndex: [String: [DictionaryEntry]] = [:]

    // MARK: - Initialisation

    private init() {
        loadDictionary()
    }

    // MARK: - DictionaryService

    func exactLookup(_ word: String) -> [DictionaryEntry] {
        return exactIndex[word] ?? []
    }

    func prefixLookup(_ prefix: String) -> [DictionaryEntry] {
        guard prefix.count >= 1 else { return [] }
        return prefixIndex[prefix] ?? []
    }

    // MARK: - Loading

    private func loadDictionary() {
        guard let url = Bundle.main.url(forResource: "kolom-dictionary", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            // Fail silently in production — the engine still works without dictionary
            print("[Kolom] Warning: kolom-dictionary.json not found in bundle.")
            return
        }

        do {
            let entries = try JSONDecoder().decode([DictionaryEntry].self, from: data)
            allEntries = entries
            buildIndex(from: entries)
        } catch {
            print("[Kolom] Warning: Failed to parse dictionary: \(error.localizedDescription)")
        }
    }

    private func buildIndex(from entries: [DictionaryEntry]) {
        // Build exact index
        for entry in entries {
            exactIndex[entry.word, default: []].append(entry)
        }

        // Build prefix index: for every word, register all its prefixes
        for entry in entries {
            var prefixChars = ""
            for char in entry.word.unicodeScalars {
                prefixChars += String(char)
                prefixIndex[prefixChars, default: []].append(entry)
            }
        }

        // Sort each prefix bucket by frequency (descending) for deterministic output
        for key in prefixIndex.keys {
            prefixIndex[key]!.sort { $0.frequency > $1.frequency }
        }
    }
}
