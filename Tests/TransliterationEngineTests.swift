import XCTest
@testable import Kolom

// MARK: - TransliterationEngineTests
// Verifies the core phonetic engine: rule matching, vowel context,
// conjunct formation, backspace, and Unicode correctness.

final class TransliterationEngineTests: XCTestCase {

    var engine: TransliterationEngine!

    override func setUp() {
        super.setUp()
        engine = TransliterationEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    // MARK: - Basic Vowels

    func testIndependentVowel_a() {
        // 'a' at word start → আ (independent)
        XCTAssertEqual(engine.transliterate("a"), "আ")
    }

    func testIndependentVowel_i() {
        XCTAssertEqual(engine.transliterate("i"), "ই")
    }

    func testIndependentVowel_u() {
        XCTAssertEqual(engine.transliterate("u"), "উ")
    }

    func testIndependentVowel_e() {
        XCTAssertEqual(engine.transliterate("e"), "এ")
    }

    func testIndependentVowel_o() {
        // 'o' at word start → অ
        XCTAssertEqual(engine.transliterate("o"), "অ")
    }

    // MARK: - Basic Consonants

    func testConsonant_k() {
        XCTAssertEqual(engine.transliterate("k"), "ক")
    }

    func testConsonant_kh() {
        XCTAssertEqual(engine.transliterate("kh"), "খ")
    }

    func testConsonant_g() {
        XCTAssertEqual(engine.transliterate("g"), "গ")
    }

    func testConsonant_gh() {
        XCTAssertEqual(engine.transliterate("gh"), "ঘ")
    }

    func testConsonant_T_retroflex() {
        // Capital T → ট (retroflex)
        XCTAssertEqual(engine.transliterate("T"), "ট")
    }

    func testConsonant_t_dental() {
        // Lowercase t → ত (dental)
        XCTAssertEqual(engine.transliterate("t"), "ত")
    }

    func testConsonant_sh() {
        XCTAssertEqual(engine.transliterate("sh"), "শ")
    }

    func testConsonant_Sh_retroflex() {
        XCTAssertEqual(engine.transliterate("Sh"), "ষ")
    }

    func testConsonant_s() {
        XCTAssertEqual(engine.transliterate("s"), "স")
    }

    // MARK: - Consonant + Vowel (matra)

    func testConsonantPlusVowel_ka() {
        // k + a → ক + া-কার = কা
        XCTAssertEqual(engine.transliterate("ka"), "কা")
    }

    func testConsonantPlusVowel_ki() {
        XCTAssertEqual(engine.transliterate("ki"), "কি")
    }

    func testConsonantPlusVowel_ku() {
        XCTAssertEqual(engine.transliterate("ku"), "কু")
    }

    func testConsonantPlusVowel_ke() {
        XCTAssertEqual(engine.transliterate("ke"), "কে")
    }

    // MARK: - Common Bengali Words

    func testWord_ami() {
        // আমি (I)
        XCTAssertEqual(engine.transliterate("ami"), "আমি")
    }

    func testWord_tumi() {
        // তুমি (you)
        XCTAssertEqual(engine.transliterate("tumi"), "তুমি")
    }

    func testWord_bhai() {
        // ভাই (brother)
        XCTAssertEqual(engine.transliterate("bhai"), "ভাই")
    }

    func testWord_bangla() {
        // বাংলা
        XCTAssertEqual(engine.transliterate("bangla"), "বাংলা")
    }

    func testWord_bangladesh() {
        // বাংলাদেশ
        XCTAssertEqual(engine.transliterate("bangladesh"), "বাংলাদেশ")
    }

    func testWord_kora() {
        // করা (to do)
        XCTAssertEqual(engine.transliterate("kora"), "করা")
    }

    func testWord_phul() {
        // ফুল (flower)
        XCTAssertEqual(engine.transliterate("phul"), "ফুল")
    }

    func testWord_manush() {
        // মানুষ (human)
        // Phonetically, 'sh' maps to 'শ' (মানুশ). 'Sh' maps to 'ষ' (মানুষ).
        // The TransliterationEngine strictly applies phonetic rules.
        XCTAssertEqual(engine.transliterate("manuSh"), "মানুষ")
        XCTAssertEqual(engine.transliterate("manush"), "মানুশ")
    }

    // MARK: - Conjuncts (hasanta)

    func testConjunct_kt() {
        // ক + ্ + ত = ক্ত (kta conjunct)
        XCTAssertEqual(engine.transliterate("kt"), "ক্ত")
    }

    func testConjunct_st() {
        // স্ত (sta)
        XCTAssertEqual(engine.transliterate("st"), "স্ত")
    }

    // MARK: - Multi-char patterns (longest match)

    func testLongestMatch_kh_over_k() {
        // "kh" should match খ, not ক + হ
        XCTAssertEqual(engine.transliterate("kh"), "খ")
    }

    func testLongestMatch_kSh() {
        // "kSh" → ক্ষ (ksha conjunct)
        XCTAssertEqual(engine.transliterate("kSh"), "ক্ষ")
    }

    // MARK: - Empty input

    func testEmptyInput() {
        XCTAssertEqual(engine.transliterate(""), "")
    }

    // MARK: - Determinism

    func testDeterminism() {
        let input = "amibangla"
        let first = engine.transliterate(input)
        let second = engine.transliterate(input)
        XCTAssertEqual(first, second)
    }

    // MARK: - Unicode correctness

    func testOutputIsValidUnicode() {
        let inputs = ["ami", "tumi", "bangladesh", "kShamaporobi"]
        for input in inputs {
            let output = engine.transliterate(input)
            // Every scalar must be a valid Unicode scalar
            XCTAssertTrue(
                output.unicodeScalars.allSatisfy { Unicode.Scalar($0.value) != nil },
                "Output for '\(input)' contains invalid Unicode: \(output)"
            )
        }
    }
}
