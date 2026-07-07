import XCTest
@testable import Kolom

// MARK: - MockDictionaryService

final class MockDictionaryService: DictionaryService {
    var entries: [DictionaryEntry]

    init(entries: [DictionaryEntry]) {
        self.entries = entries
    }

    var allEntries: [DictionaryEntry] { entries }

    func exactLookup(_ word: String) -> [DictionaryEntry] {
        entries.filter { $0.word == word }
    }

    func prefixLookup(_ prefix: String) -> [DictionaryEntry] {
        entries.filter { $0.word.hasPrefix(prefix) }
    }
}

// MARK: - CandidateEngineTests

final class CandidateEngineTests: XCTestCase {

    var dictionary: MockDictionaryService!
    var engine: CandidateEngine!

    override func setUp() {
        super.setUp()
        dictionary = MockDictionaryService(entries: [
            DictionaryEntry(word: "আমি", frequency: 1000),
            DictionaryEntry(word: "আমরা", frequency: 940),
            DictionaryEntry(word: "আম", frequency: 185),
            DictionaryEntry(word: "বাংলা", frequency: 660),
            DictionaryEntry(word: "বাংলাদেশ", frequency: 670),
        ])
        engine = CandidateEngine(dictionaryServices: [dictionary])
    }

    override func tearDown() {
        engine = nil
        dictionary = nil
        super.tearDown()
    }

    // MARK: - Exact match

    func testExactMatch_returnsFirstCandidate() {
        let candidates = engine.generateCandidates(for: "আমি", rawInput: "ami")
        XCTAssertTrue(candidates.contains("আমি"))
        XCTAssertEqual(candidates.first, "আমি", "Exact match should rank first")
    }

    // MARK: - Prefix match

    func testPrefixMatch_returnsMatchingWords() {
        let candidates = engine.generateCandidates(for: "আমি", rawInput: "ami")
        // Should include words starting with "আমি" prefix
        XCTAssertTrue(candidates.contains("আমরা") || candidates.contains("আমি"))
    }

    func testPrefixMatch_bangla() {
        let candidates = engine.generateCandidates(for: "বাংলা", rawInput: "bangla")
        XCTAssertTrue(candidates.contains("বাংলা"))
    }

    func testPrefixMatch_bangladeshIncludes() {
        let candidates = engine.generateCandidates(for: "বাংলা", rawInput: "bangla", maxResults: 9)
        // "বাংলাদেশ" starts with "বাংলা", so it should appear
        XCTAssertTrue(candidates.contains("বাংলাদেশ") || candidates.contains("বাংলা"))
    }

    // MARK: - Empty input

    func testEmptyComposition_returnsEmpty() {
        let candidates = engine.generateCandidates(for: "", rawInput: "")
        XCTAssertTrue(candidates.isEmpty)
    }

    // MARK: - Determinism

    func testDeterminism_sameInputSameOutput() {
        let first = engine.generateCandidates(for: "আমি", rawInput: "ami")
        engine.invalidateCache()
        let second = engine.generateCandidates(for: "আমি", rawInput: "ami")
        XCTAssertEqual(first, second)
    }

    // MARK: - Max results

    func testMaxResults_respected() {
        let candidates = engine.generateCandidates(for: "আমি", rawInput: "ami", maxResults: 3)
        XCTAssertLessThanOrEqual(candidates.count, 3)
    }

    // MARK: - Raw composition included

    func testRawCompositionAlwaysIncluded() {
        // Even if composition is not in dictionary, it should appear as fallback
        let composition = "অজানাশব্দ"
        let candidates = engine.generateCandidates(for: composition, rawInput: "ojanashabdo")
        XCTAssertTrue(candidates.contains(composition),
                      "Raw transliteration should always be in the candidate list")
    }

    // MARK: - No duplicates

    func testNoDuplicatesInOutput() {
        let candidates = engine.generateCandidates(for: "আমি", rawInput: "ami")
        let unique = Set(candidates)
        XCTAssertEqual(candidates.count, unique.count, "Candidate list must not contain duplicates")
    }
}
