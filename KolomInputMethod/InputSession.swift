import Foundation

// MARK: - InputMode

/// The active typing language mode for a session.
enum InputMode: String, CaseIterable {
    case bengali = "Bengali"
    case english = "English"
}

// MARK: - InputSession
// Owns the mutable state of a single typing interaction.
// Delegates language transformation to the engine and candidate generation
// to the CandidateEngine. Keeps orchestration and language logic separate.

final class InputSession {

    // MARK: - Dependencies
    private let transliterationEngine: TransliterationEngine
    private let compositionEngine: CompositionEngine
    private let candidateEngine: CandidateEngine
    private let settings: SettingsStore

    // MARK: - State (read-only outside session)
    private(set) var mode: InputMode
    private(set) var rawBuffer: String = ""
    private(set) var currentComposition: String = ""
    private(set) var currentCandidates: [String] = []
    private(set) var selectedCandidateIndex: Int = 0

    var isComposing: Bool { !rawBuffer.isEmpty }
    var hasCandidates: Bool { !currentCandidates.isEmpty }
    
    var selectedCandidate: String? {
        guard !currentCandidates.isEmpty, selectedCandidateIndex < currentCandidates.count else { return nil }
        return currentCandidates[selectedCandidateIndex]
    }

    // MARK: - Initialisation

    init(
        transliterationEngine: TransliterationEngine,
        compositionEngine: CompositionEngine,
        candidateEngine: CandidateEngine,
        settings: SettingsStore
    ) {
        self.transliterationEngine = transliterationEngine
        self.compositionEngine = compositionEngine
        self.candidateEngine = candidateEngine
        self.settings = settings
        self.mode = settings.defaultInputMode
    }

    // MARK: - Input Processing

    /// Append a Latin character(s) to the composition buffer and re-evaluate.
    func processInput(_ input: String) {
        guard mode == .bengali else { return }
        rawBuffer += input
        reEvaluate()
    }

    /// Remove the last raw character and re-evaluate the full buffer.
    func processBackspace() {
        guard !rawBuffer.isEmpty else { return }
        rawBuffer.removeLast()
        reEvaluate()
    }

    /// Clear all session state.
    func reset() {
        rawBuffer = ""
        currentComposition = ""
        currentCandidates = []
        selectedCandidateIndex = 0
        compositionEngine.reset()
    }

    /// Toggle between Bengali and English modes.
    func toggleMode() {
        mode = (mode == .bengali) ? .english : .bengali
        reset()
    }

    // MARK: - Private

    private func reEvaluate() {
        guard !rawBuffer.isEmpty else {
            currentComposition = ""
            currentCandidates = []
            selectedCandidateIndex = 0
            return
        }

        // 1. Transliterate the full raw buffer to Bengali Unicode
        let bengali = transliterationEngine.transliterate(rawBuffer)
        currentComposition = bengali

        // 2. Update composition engine state
        compositionEngine.update(text: bengali, rawInput: rawBuffer)

        // 3. Generate ranked candidates from the current composition
        currentCandidates = candidateEngine.generateCandidates(
            for: bengali,
            rawInput: rawBuffer,
            maxResults: settings.maxCandidates
        )
        selectedCandidateIndex = 0
    }

    // MARK: - Candidate Selection

    func selectNextCandidate() {
        guard !currentCandidates.isEmpty else { return }
        selectedCandidateIndex = (selectedCandidateIndex + 1) % currentCandidates.count
    }

    func selectPreviousCandidate() {
        guard !currentCandidates.isEmpty else { return }
        let count = currentCandidates.count
        selectedCandidateIndex = (selectedCandidateIndex - 1 + count) % count
    }
}
