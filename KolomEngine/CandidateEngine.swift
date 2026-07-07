import Foundation

// MARK: - Candidate

/// A ranked word suggestion produced by the CandidateEngine.
struct Candidate: Equatable {
    let word: String
    let source: CandidateSource
    let score: Int
    let matchType: MatchType

    enum CandidateSource { case core, user }
    enum MatchType { case exact, prefix, partial }
}

// MARK: - CandidateEngine
// Produces a deterministic, ranked list of Bengali word candidates
// from the current composition and dictionary.
//
// Pipeline: Normalize → Exact lookup → Prefix lookup → Merge → Filter → Rank → Output
//
// IMPORTANT: This engine is stateless (except for a simple result cache).
// identical input always produces identical output.

final class CandidateEngine {

    // MARK: - Dependencies

    private let dictionaryServices: [DictionaryService]

    // MARK: - Simple result cache (purely for performance)

    private var lastInput: String = ""
    private var cachedResult: [String] = []

    // MARK: - Init

    init(dictionaryServices: [DictionaryService]) {
        self.dictionaryServices = dictionaryServices
    }

    // MARK: - Public API

    /// Generate a ranked candidate list for the given Bengali composition text.
    /// - Parameters:
    ///   - composition: Bengali Unicode text from the transliteration engine
    ///   - rawInput: Original Latin input (used for scoring)
    ///   - maxResults: Maximum number of candidates to return
    /// - Returns: Ordered list of Bengali candidate strings
    func generateCandidates(
        for composition: String,
        rawInput: String,
        maxResults: Int = 9
    ) -> [String] {
        guard !composition.isEmpty else { return [] }

        // Cache hit
        if composition == lastInput {
            return Array(cachedResult.prefix(maxResults))
        }

        // 1. Gather candidates from dictionary
        var candidates: [Candidate] = []

        let exactMatches = dictionaryServices.flatMap { service in
            service.exactLookup(composition).map { entry in
                Candidate(word: entry.word, source: .core, score: entry.frequency + 1000, matchType: .exact)
            }
        }

        var prefixMatches = dictionaryServices.flatMap { service in
            service.prefixLookup(composition).compactMap { entry -> Candidate? in
                // Exclude exact matches already covered above
                guard entry.word != composition else { return nil }
                return Candidate(word: entry.word, source: .core, score: entry.frequency, matchType: .prefix)
            }
        }

        // Handle ambiguous nasals: 'ng' defaults to 'ং' (anusvara), but users often expect
        // prefix matches for words using 'ঙ' (nga) like "বাঙালী" (bangali).
        if composition.hasSuffix("ং") {
            let altComposition = String(composition.dropLast()) + "ঙ"
            let altMatches = dictionaryServices.flatMap { service in
                service.prefixLookup(altComposition).compactMap { entry -> Candidate? in
                    return Candidate(word: entry.word, source: .core, score: entry.frequency, matchType: .prefix)
                }
            }
            prefixMatches += altMatches
        }

        // Handle Khanda Ta (ৎ) ambiguity: users often type 't' (ত) instead of 't`' (ৎ) at the end of words
        if composition.hasSuffix("ত") {
            let altComposition = String(composition.dropLast()) + "ৎ"
            let altMatches = dictionaryServices.flatMap { service in
                service.prefixLookup(altComposition).compactMap { entry -> Candidate? in
                    return Candidate(word: entry.word, source: .core, score: entry.frequency, matchType: .prefix)
                }
            }
            prefixMatches += altMatches
        }

        candidates += exactMatches
        candidates += prefixMatches

        // 2. Deduplication by word
        var seen = Set<String>()
        candidates = candidates.filter { seen.insert($0.word).inserted }

        // 3. Rank
        candidates.sort { lhs, rhs in
            // Exact match first
            if lhs.matchType == .exact && rhs.matchType != .exact { return true }
            if rhs.matchType == .exact && lhs.matchType != .exact { return false }
            // User dictionary preference
            if lhs.source == .user && rhs.source != .user { return true }
            if rhs.source == .user && lhs.source != .user { return false }
            // Higher frequency first
            if lhs.score != rhs.score { return lhs.score > rhs.score }
            // Shorter word for tie-breaking (deterministic)
            return lhs.word.count < rhs.word.count
        }

        // 4. Always ensure the exact phonetic transliteration is the FIRST option (default).
        //    Dictionary matches follow it. This guarantees that typing "e" defaults to "এ",
        //    typing "bangla" defaults to "বাংলা", etc.
        var result = [composition]
        for c in candidates {
            if result.count >= maxResults { break }
            if c.word != composition {
                result.append(c.word)
            }
        }

        // Update cache
        lastInput = composition
        cachedResult = result

        return result
    }

    /// Invalidate internal cache (e.g. when dictionary updates).
    func invalidateCache() {
        lastInput = ""
        cachedResult = []
    }
}
