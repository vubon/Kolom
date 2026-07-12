import XCTest
@testable import Kolom

final class PerformanceTests: XCTestCase {

    var engine: TransliterationEngine!
    var candidateEngine: CandidateEngine!

    override func setUp() {
        super.setUp()
        engine = TransliterationEngine()
        candidateEngine = CandidateEngine(dictionaryServices: [
            JSONDictionaryStore.shared,
            UserDictionaryStore.shared
        ])
    }

    override func tearDown() {
        engine = nil
        candidateEngine = nil
        super.tearDown()
    }

    func testTransliterationMemoryPerformance() throws {
        // Measure the memory allocated when rapidly transliterating thousands of characters.
        // This simulates a very heavy, fast typing session to ensure the state machine
        // does not leak memory or grow infinitely.
        let metrics: [XCTMetric] = [XCTMemoryMetric(), XCTCPUMetric(), XCTClockMetric()]
        
        let testString = "ami bangla bhalobashi ebar amra ki korbo jani na kintu amra chest kore jabo"
        let repeatCount = 100
        var massiveInput = ""
        for _ in 0..<repeatCount {
            massiveInput += testString + " "
        }
        
        measure(metrics: metrics) {
            let _ = engine.transliterate(massiveInput)
        }
    }
    
    func testCandidateEngineMemoryPerformance() throws {
        // Measure memory usage when suggesting candidates.
        let metrics: [XCTMetric] = [XCTMemoryMetric(), XCTCPUMetric(), XCTClockMetric()]
        
        measure(metrics: metrics) {
            let candidates = candidateEngine.generateCandidates(for: "বাংলা", rawInput: "bangla")
            // Make sure we have a result so the compiler doesn't optimize it away
            XCTAssertFalse(candidates.isEmpty, "Should have suggestions for 'bangla'")
        }
    }
}
