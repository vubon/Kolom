import Foundation

// MARK: - TransliterationRule
// Represents a single phonetic mapping rule.
// Vowels have two forms: independent (word-start / after another vowel)
// and dependent (vowel sign / matra, used after a consonant).

struct TransliterationRule {
    let pattern: String

    enum Kind {
        case consonant(String)
        case vowel(independent: String, dependent: String)
        case modifier(String)       // Dependent consonants (anusvara, visarga, chandrabindu)
        case direct(String)         // literal passthrough or special symbol
    }
    let kind: Kind

    var isConsonant: Bool {
        if case .consonant = kind { return true }
        return false
    }
    var isVowel: Bool {
        if case .vowel = kind { return true }
        return false
    }
}

// MARK: - TransliterationRules
// Avro-compatible phonetic rules for Bengali.
// Rules MUST be sorted longest-pattern-first so that multi-char sequences
// (e.g. "kh" → খ) are matched before their prefixes (e.g. "k" → ক).

enum TransliterationRules {

    static let avroRules: [TransliterationRule] = buildRules()

    // swiftlint:disable function_body_length
    private static func buildRules() -> [TransliterationRule] {
        var rules: [TransliterationRule] = []

        // ── 3-character consonant clusters ──────────────────────────────────
        rules += [
            // kSh → ক্ষ (ksha conjunct — very common in Bengali)
            TransliterationRule(pattern: "kSh", kind: .consonant("ক্ষ")),
            // jNG → জ্ঞ (jnya conjunct)
            TransliterationRule(pattern: "jNG", kind: .consonant("জ্ঞ")),
            // chh → ছ
            TransliterationRule(pattern: "chh", kind: .consonant("ছ")),
        ]

        // ── 2-character consonant patterns ──────────────────────────────────
        rules += [
            TransliterationRule(pattern: "kh", kind: .consonant("খ")),
            TransliterationRule(pattern: "gh", kind: .consonant("ঘ")),
            TransliterationRule(pattern: "ng", kind: .modifier("ং")),    // anusvara (nasalised modifier)
            TransliterationRule(pattern: "Ng", kind: .consonant("ঙ")),   // nga (rare standalone)
            TransliterationRule(pattern: "ch", kind: .consonant("চ")),   // ch → চ (Avro standard)
            TransliterationRule(pattern: "Ch", kind: .consonant("ছ")),   // Ch → ছ
            TransliterationRule(pattern: "jh", kind: .consonant("ঝ")),
            TransliterationRule(pattern: "NG", kind: .consonant("ঞ")),   // palatal nasal
            TransliterationRule(pattern: "Th", kind: .consonant("ঠ")),   // retroflex aspirate
            TransliterationRule(pattern: "Dh", kind: .consonant("ঢ")),   // retroflex aspirate
            TransliterationRule(pattern: "th", kind: .consonant("থ")),
            TransliterationRule(pattern: "dh", kind: .consonant("ধ")),
            TransliterationRule(pattern: "ph", kind: .consonant("ফ")),
            TransliterationRule(pattern: "bh", kind: .consonant("ভ")),
            TransliterationRule(pattern: "sh", kind: .consonant("শ")),   // palatal sibilant
            TransliterationRule(pattern: "Sh", kind: .consonant("ষ")),   // retroflex sibilant
            TransliterationRule(pattern: "rr", kind: .consonant("ড়")),   // rr → ড় (ra with dot)
            TransliterationRule(pattern: "Rh", kind: .consonant("ঢ়")),   // Rh → ঢ়
        ]

        // ── 2-character vowel patterns ───────────────────────────────────────
        rules += [
            // aa / A → আ (long a)
            TransliterationRule(pattern: "aa", kind: .vowel(independent: "আ", dependent: "া")),
            // ii / I → ঈ (long i)
            TransliterationRule(pattern: "ii", kind: .vowel(independent: "ঈ", dependent: "ী")),
            // uu / U → ঊ (long u)
            TransliterationRule(pattern: "uu", kind: .vowel(independent: "ঊ", dependent: "ূ")),
            // oi → ঐ (diphthong)
            TransliterationRule(pattern: "oi", kind: .vowel(independent: "ঐ", dependent: "ৈ")),
            // ou → ঔ (diphthong)
            TransliterationRule(pattern: "ou", kind: .vowel(independent: "ঔ", dependent: "ৌ")),
            // rri → ঋ (vocalic r)
            TransliterationRule(pattern: "rri", kind: .vowel(independent: "ঋ", dependent: "ৃ")),
        ]

        // ── 1-character consonants ───────────────────────────────────────────
        rules += [
            TransliterationRule(pattern: "k", kind: .consonant("ক")),
            TransliterationRule(pattern: "g", kind: .consonant("গ")),
            TransliterationRule(pattern: "c", kind: .consonant("চ")),    // c → চ
            TransliterationRule(pattern: "j", kind: .consonant("জ")),
            TransliterationRule(pattern: "T", kind: .consonant("ট")),    // Capital = retroflex
            TransliterationRule(pattern: "t`", kind: .consonant("ৎ")),   // Khanda Ta
            TransliterationRule(pattern: "T`", kind: .consonant("ৎ")),   // Khanda Ta (Capital T variant)
            TransliterationRule(pattern: "D", kind: .consonant("ড")),    // Capital = retroflex
            TransliterationRule(pattern: "N", kind: .consonant("ণ")),    // Capital = retroflex nasal
            TransliterationRule(pattern: "t", kind: .consonant("ত")),
            TransliterationRule(pattern: "d", kind: .consonant("দ")),
            TransliterationRule(pattern: "n", kind: .consonant("ন")),
            TransliterationRule(pattern: "p", kind: .consonant("প")),
            TransliterationRule(pattern: "f", kind: .consonant("ফ")),    // f → ফ
            TransliterationRule(pattern: "b", kind: .consonant("ব")),
            TransliterationRule(pattern: "v", kind: .consonant("ভ")),    // v → ভ
            TransliterationRule(pattern: "m", kind: .consonant("ম")),
            TransliterationRule(pattern: "z", kind: .consonant("য")),    // z → য
            TransliterationRule(pattern: "y", kind: .consonant("য")),    // y → য
            TransliterationRule(pattern: "Y", kind: .consonant("য়")),    // Y → য় (Antastha Ya)
            TransliterationRule(pattern: "r", kind: .consonant("র")),
            TransliterationRule(pattern: "l", kind: .consonant("ল")),
            TransliterationRule(pattern: "S", kind: .consonant("শ")),    // Capital S → শ
            TransliterationRule(pattern: "s", kind: .consonant("স")),
            TransliterationRule(pattern: "h", kind: .consonant("হ")),
            TransliterationRule(pattern: "R", kind: .consonant("ড়")),    // Capital R → ড়
            TransliterationRule(pattern: "q", kind: .consonant("ক")),    // q → ক (loan words)
            TransliterationRule(pattern: "w", kind: .consonant("ও")),    // w → ও (approximation)
            TransliterationRule(pattern: "x", kind: .consonant("ক্স")), // x → ক্স
        ]

        // ── 1-character vowels ───────────────────────────────────────────────
        // Mapping:
        //   a → আ/া  (the dominant long-a sound in Bengali phonetics)
        //   A → আ/া  (alias)
        //   i → ই/ি
        //   I → ঈ/ী
        //   u → উ/ু
        //   U → ঊ/ূ
        //   e → এ/ে
        //   o → অ/  (short-a / schwa, independent = অ, no standard matra)
        //   O → ও/ো (long-O sound)
        rules += [
            TransliterationRule(pattern: "a", kind: .vowel(independent: "আ", dependent: "া")),
            TransliterationRule(pattern: "A", kind: .vowel(independent: "আ", dependent: "া")),
            TransliterationRule(pattern: "i", kind: .vowel(independent: "ই", dependent: "ি")),
            TransliterationRule(pattern: "I", kind: .vowel(independent: "ঈ", dependent: "ী")),
            TransliterationRule(pattern: "u", kind: .vowel(independent: "উ", dependent: "ু")),
            TransliterationRule(pattern: "U", kind: .vowel(independent: "ঊ", dependent: "ূ")),
            TransliterationRule(pattern: "e", kind: .vowel(independent: "এ", dependent: "ে")),
            TransliterationRule(pattern: "o", kind: .vowel(independent: "অ", dependent: "")),
            TransliterationRule(pattern: "O", kind: .vowel(independent: "ও", dependent: "ো")),
        ]

        // ── Special / punctuation ────────────────────────────────────────────
        rules += [
            TransliterationRule(pattern: ":", kind: .modifier("ঃ")), // bisarga
            TransliterationRule(pattern: "^", kind: .modifier("ঁ")), // chandrabindu
            TransliterationRule(pattern: "`", kind: .direct("্")),   // hasanta (explicit)
            TransliterationRule(pattern: "..", kind: .direct("॥")),  // double dari
            TransliterationRule(pattern: ".", kind: .direct("।")),   // dari (full stop)
        ]

        // ── Numbers ──────────────────────────────────────────────────────────
        rules += [
            TransliterationRule(pattern: "0", kind: .direct("০")),
            TransliterationRule(pattern: "1", kind: .direct("১")),
            TransliterationRule(pattern: "2", kind: .direct("২")),
            TransliterationRule(pattern: "3", kind: .direct("৩")),
            TransliterationRule(pattern: "4", kind: .direct("৪")),
            TransliterationRule(pattern: "5", kind: .direct("৫")),
            TransliterationRule(pattern: "6", kind: .direct("৬")),
            TransliterationRule(pattern: "7", kind: .direct("৭")),
            TransliterationRule(pattern: "8", kind: .direct("৮")),
            TransliterationRule(pattern: "9", kind: .direct("৯")),
        ]

        // Sort by pattern length descending — longest match wins
        return rules.sorted { $0.pattern.count > $1.pattern.count }
    }
    // swiftlint:enable function_body_length
}
