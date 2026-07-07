import Foundation

// MARK: - DictionaryEntry
// Immutable value type representing a single word in the Kolom dictionary.

struct DictionaryEntry: Codable, Equatable, Hashable {
    /// The Bengali Unicode word string.
    let word: String
    /// Usage frequency — higher values are more common.
    let frequency: Int
    /// Origin of the entry: "core" (project-maintained) or "user" (user-added).
    let source: String

    // MARK: - Codable keys (tolerant of missing optional fields)

    enum CodingKeys: String, CodingKey {
        case word
        case frequency
        case source
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        word = try container.decode(String.self, forKey: .word)
        frequency = try container.decodeIfPresent(Int.self, forKey: .frequency) ?? 1
        source = try container.decodeIfPresent(String.self, forKey: .source) ?? "core"
    }

    init(word: String, frequency: Int = 1, source: String = "core") {
        self.word = word
        self.frequency = frequency
        self.source = source
    }
}
