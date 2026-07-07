import XCTest
@testable import Kolom

// MARK: - CompositionEngineTests

final class CompositionEngineTests: XCTestCase {

    var engine: CompositionEngine!

    override func setUp() {
        super.setUp()
        engine = CompositionEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialState_isIdle() {
        XCTAssertEqual(engine.status, .idle)
        XCTAssertTrue(engine.isEmpty)
        XCTAssertEqual(engine.currentText, "")
        XCTAssertEqual(engine.caretPosition, 0)
    }

    // MARK: - Update

    func testUpdate_setsActiveStatus() {
        engine.update(text: "আমি", rawInput: "ami")
        XCTAssertEqual(engine.status, .active)
        XCTAssertEqual(engine.currentText, "আমি")
        XCTAssertEqual(engine.currentRawInput, "ami")
    }

    func testUpdate_withEmptyText_isIdle() {
        engine.update(text: "আমি", rawInput: "ami")
        engine.update(text: "", rawInput: "")
        XCTAssertEqual(engine.status, .idle)
        XCTAssertTrue(engine.isEmpty)
    }

    func testUpdate_caretAtEndOfText() {
        engine.update(text: "আমি", rawInput: "ami")
        // Caret should be at the end of the composition
        XCTAssertEqual(engine.caretPosition, "আমি".count)
    }

    // MARK: - Commit

    func testCommit_resetsToIdle() {
        engine.update(text: "ভালো", rawInput: "bhalo")
        engine.commit()
        XCTAssertEqual(engine.status, .idle)
        XCTAssertTrue(engine.isEmpty)
    }

    // MARK: - Cancel

    func testCancel_resetsToIdle() {
        engine.update(text: "করা", rawInput: "kora")
        engine.cancel()
        XCTAssertEqual(engine.status, .idle)
        XCTAssertTrue(engine.isEmpty)
        XCTAssertEqual(engine.currentText, "")
    }

    // MARK: - Reset

    func testReset_clearsAllState() {
        engine.update(text: "মানুষ", rawInput: "manush")
        engine.reset()
        XCTAssertTrue(engine.isEmpty)
        XCTAssertEqual(engine.status, .idle)
        XCTAssertEqual(engine.caretPosition, 0)
    }

    // MARK: - Rapid updates

    func testRapidUpdates_maintainCorrectState() {
        let inputs = [("আ", "a"), ("আম", "am"), ("আমি", "ami")]
        for (text, raw) in inputs {
            engine.update(text: text, rawInput: raw)
        }
        XCTAssertEqual(engine.currentText, "আমি")
        XCTAssertEqual(engine.currentRawInput, "ami")
        XCTAssertEqual(engine.status, .active)
    }

    // MARK: - Snapshot equality

    func testSnapshot_equality() {
        engine.update(text: "কলম", rawInput: "kolom")
        let snap1 = engine.snapshot
        engine.update(text: "কলম", rawInput: "kolom")
        let snap2 = engine.snapshot
        XCTAssertEqual(snap1, snap2)
    }
}
