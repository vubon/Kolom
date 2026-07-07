import Foundation

// MARK: - CompositionStatus

enum CompositionStatus {
    case idle
    case active
    case committed
    case cancelled
}

// MARK: - CompositionSnapshot
// Immutable value type representing the state of a composition at a point in time.

struct CompositionSnapshot: Equatable {
    let text: String
    let rawInput: String
    let caretPosition: Int
    let status: CompositionStatus

    static func == (lhs: CompositionSnapshot, rhs: CompositionSnapshot) -> Bool {
        return lhs.text == rhs.text && lhs.rawInput == rhs.rawInput
    }
}

// MARK: - CompositionEngine
// Manages the evolving preedit buffer between raw input and committed text.
// Owns: current composition text, caret position, and lifecycle state.
// Does NOT own: transliteration rules, dictionary data, or candidate logic.

final class CompositionEngine {

    // MARK: - State

    private(set) var snapshot: CompositionSnapshot = .init(
        text: "",
        rawInput: "",
        caretPosition: 0,
        status: .idle
    )

    var currentText: String { snapshot.text }
    var currentRawInput: String { snapshot.rawInput }
    var caretPosition: Int { snapshot.caretPosition }
    var status: CompositionStatus { snapshot.status }
    var isActive: Bool { status == .active }
    var isEmpty: Bool { snapshot.text.isEmpty }

    // MARK: - Updates

    /// Update composition with new transliterated text and its raw input.
    func update(text: String, rawInput: String) {
        let caret = text.count
        snapshot = CompositionSnapshot(
            text: text,
            rawInput: rawInput,
            caretPosition: caret,
            status: text.isEmpty ? .idle : .active
        )
    }

    /// Mark composition as committed and clear state.
    func commit() {
        snapshot = CompositionSnapshot(
            text: snapshot.text,
            rawInput: snapshot.rawInput,
            caretPosition: snapshot.caretPosition,
            status: .committed
        )
        reset()
    }

    /// Discard composition and return to idle.
    func cancel() {
        snapshot = CompositionSnapshot(text: "", rawInput: "", caretPosition: 0, status: .cancelled)
        reset()
    }

    /// Reset to idle state.
    func reset() {
        snapshot = CompositionSnapshot(text: "", rawInput: "", caretPosition: 0, status: .idle)
    }
}
