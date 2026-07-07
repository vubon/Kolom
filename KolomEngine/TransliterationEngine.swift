import Foundation

// MARK: - TransliterationEngine
// Converts a Latin phonetic string into Unicode Bengali text using
// Avro-compatible rules. The algorithm is a greedy longest-match-first
// scanner that tracks vowel/consonant context to produce correct Bengali
// matra (vowel signs) vs independent vowel forms.
//
// Design principles:
//  - Stateless transformation: same input always produces same output
//  - No side effects or global state
//  - Each stage (tokenize → match → compose) has a single responsibility

final class TransliterationEngine {

    // MARK: - Properties

    private let rules: [TransliterationRule]

    // MARK: - Initialisation

    init(rules: [TransliterationRule] = TransliterationRules.avroRules) {
        self.rules = rules
    }

    // MARK: - Public API

    /// Transliterate a full Latin phonetic string to Bengali Unicode.
    /// - Parameter input: Latin input string (e.g. "ami")
    /// - Returns: Bengali Unicode string (e.g. "আমি")
    func transliterate(_ input: String) -> String {
        guard !input.isEmpty else { return "" }

        var result = ""
        var index = input.startIndex
        // Track context: did the previous token produce a consonant?
        // This determines whether a vowel takes its independent or dependent form.
        var lastTokenWasConsonant = false

        while index < input.endIndex {
            guard let match = findLongestMatch(in: input, from: index) else {
                // No rule matched — pass the character through unchanged
                result += String(input[index])
                lastTokenWasConsonant = false
                index = input.index(after: index)
                continue
            }

            let (rule, endIndex) = match

            switch rule.kind {
            case .consonant(let bengali):
                // Consecutive consonants require hasanta (্) to form conjuncts
                if lastTokenWasConsonant {
                    result += "্"
                }
                result += bengali
                lastTokenWasConsonant = true

            case .vowel(let independent, let dependent):
                if lastTokenWasConsonant {
                    // After a consonant → use the vowel sign (matra/কার)
                    // The 'a' (আ) dependent form আ-কার replaces the inherent 'a'
                    result += dependent
                } else {
                    // At word start or after another vowel → independent form
                    result += independent
                }
                lastTokenWasConsonant = false

            case .modifier(let symbol):
                // Modifiers (like anusvara ং) append without taking a hasanta themselves,
                // and they break the consonant chain so the next consonant doesn't get one.
                result += symbol
                lastTokenWasConsonant = false

            case .direct(let symbol):
                result += symbol
                lastTokenWasConsonant = false
            }

            index = endIndex
        }

        return result
    }

    // MARK: - Private

    /// Find the longest matching rule starting at `from` in `input`.
    /// Returns (matchedRule, endIndex) or nil if no rule matches.
    private func findLongestMatch(
        in input: String,
        from startIndex: String.Index
    ) -> (TransliterationRule, String.Index)? {
        let remaining = input.distance(from: startIndex, to: input.endIndex)

        for rule in rules {
            let patternLength = rule.pattern.count
            guard patternLength <= remaining else { continue }

            let endIndex = input.index(startIndex, offsetBy: patternLength)
            let slice = String(input[startIndex..<endIndex])

            // Rules are case-sensitive (T ≠ t, D ≠ d, etc.)
            if slice == rule.pattern {
                return (rule, endIndex)
            }
        }
        return nil
    }
}
