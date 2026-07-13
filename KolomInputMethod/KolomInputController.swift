import Foundation
import InputMethodKit

@objc(KolomInputController)
final class KolomInputController: IMKInputController, @unchecked Sendable {

    nonisolated(unsafe) private let session: InputSession
    nonisolated(unsafe) private var candidateWindow: CandidateWindowController

    override init!(server: IMKServer!, delegate: Any!, client sender: Any!) {
        let settings = SettingsStore.shared
        let transliterationEngine = TransliterationEngine()
        let compositionEngine = CompositionEngine()
        let candidateEngine = CandidateEngine(dictionaryServices: [
            JSONDictionaryStore.shared,
            UserDictionaryStore.shared
        ])

        self.session = InputSession(
            transliterationEngine: transliterationEngine,
            compositionEngine: compositionEngine,
            candidateEngine: candidateEngine,
            settings: settings
        )
        var window: CandidateWindowController!
        if Thread.isMainThread {
            MainActor.assumeIsolated {
                window = CandidateWindowController()
            }
        } else {
            DispatchQueue.main.sync {
                MainActor.assumeIsolated {
                    window = CandidateWindowController()
                }
            }
        }
        self.candidateWindow = window
        super.init(server: server, delegate: delegate, client: sender)
    }

    override func recognizedEvents(_ sender: Any!) -> Int {
        return Int(NSEvent.EventTypeMask.keyDown.rawValue | NSEvent.EventTypeMask.flagsChanged.rawValue)
    }

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard let event = event, event.type == .keyDown else { return false }
        guard let client = sender as? IMKTextInput else { return false }

        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if modifiers.contains(.command) || modifiers.contains(.control) || modifiers.contains(.option) {
            return false
        }

        switch event.keyCode {
        case KeyCode.returnKey, KeyCode.enter:
            return handleCommit(client: client)
        case KeyCode.backspace:
            return handleBackspace(client: client)
        case KeyCode.escape:
            return handleCancel(client: client)
        case KeyCode.space:
            return handleSpace(client: client)
        case KeyCode.downArrow, KeyCode.rightArrow:
            guard session.hasCandidates else { return false }
            session.selectNextCandidate()
            updateCompositionDisplay(client: client)
            return true
        case KeyCode.upArrow, KeyCode.leftArrow:
            guard session.hasCandidates else { return false }
            session.selectPreviousCandidate()
            updateCompositionDisplay(client: client)
            return true
        case KeyCode.tab:
            guard session.hasCandidates else { return false }
            session.selectNextCandidate()
            updateCompositionDisplay(client: client)
            return true
        default:
            guard let characters = event.characters, !characters.isEmpty else { return false }
            
            if session.hasCandidates, let num = Int(characters), num >= 1 && num <= 9 {
                let index = num - 1
                if index < session.currentCandidates.count {
                    let candidate = session.currentCandidates[index]
                    commitText(candidate + " ", client: client)
                    return true
                }
            }

            return handleCharacterInput(characters, client: client)
        }
    }

    private func handleCharacterInput(_ characters: String, client: IMKTextInput) -> Bool {
        guard let scalar = characters.unicodeScalars.first,
              scalar.value >= 32, scalar.value < 127 else { return false }

        let char = characters.first!
        let isAlpha = char.isLetter
        let isNumber = char.isNumber
        let isSpecial = [":", "^", "`", "."].contains(char)
        let isAllowed = isAlpha || isNumber || isSpecial

        guard isAllowed else {
            if session.isComposing {
                let text = session.selectedCandidate ?? session.currentComposition
                commitText(text, client: client)
            }
            return false
        }

        session.processInput(characters)
        updateCompositionDisplay(client: client)
        return true
    }

    private func handleBackspace(client: IMKTextInput) -> Bool {
        guard session.isComposing else { return false }
        session.processBackspace()
        if session.isComposing {
            updateCompositionDisplay(client: client)
        } else {
            clearCompositionDisplay(client: client)
        }
        return true
    }

    private func handleSpace(client: IMKTextInput) -> Bool {
        guard session.isComposing else { return false }
        let text = session.selectedCandidate ?? session.currentComposition
        commitText(text + " ", client: client)
        return true
    }

    private func handleCommit(client: IMKTextInput) -> Bool {
        guard session.isComposing else { return false }
        let text = session.selectedCandidate ?? session.currentComposition
        commitText(text, client: client)
        return true
    }

    private func handleCancel(client: IMKTextInput) -> Bool {
        guard session.isComposing else { return false }
        clearCompositionDisplay(client: client)
        return true
    }

    private func updateCompositionDisplay(client: IMKTextInput) {
        let composition = session.currentComposition
        guard !composition.isEmpty else {
            clearCompositionDisplay(client: client)
            return
        }

        // SYNC: setMarkedText MUST be called synchronously on the same call stack
        // that returned `true` from handle(_:client:). Chrome's out-of-process text
        // input model blocks waiting for this update — dispatching it async causes
        // the browser to freeze until the next run-loop tick.
        let attrs: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: NSColor.gray
        ]
        let attributed = NSAttributedString(string: composition, attributes: attrs)
        client.setMarkedText(
            attributed,
            selectionRange: NSRange(location: composition.utf16.count, length: 0),
            replacementRange: NSRange(location: NSNotFound, length: 0)
        )

        // The candidate window is cosmetic-only — it is safe to update async.
        let candidates = session.currentCandidates
        if candidates.isEmpty {
            // IMK always invokes handle() on the main thread, so we can call
            // candidateWindow directly without dispatching.
            MainActor.assumeIsolated { candidateWindow.hide() }
        } else {
            let selectedIndex = self.session.selectedCandidateIndex
            let sendableClient = SendableClient(client)
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                var cursorRect = NSRect.zero
                sendableClient.client.attributes(forCharacterIndex: 0, lineHeightRectangle: &cursorRect)
                self.candidateWindow.show(
                    candidates: candidates,
                    selectedIndex: selectedIndex,
                    near: cursorRect
                )
            }
        }
    }

    private func clearCompositionDisplay(client: IMKTextInput) {
        session.reset()
        // SYNC: clear the marked text immediately so the host application
        // (especially Chrome) does not see a stale preedit region.
        client.setMarkedText(
            "",
            selectionRange: NSRange(location: 0, length: 0),
            replacementRange: NSRange(location: NSNotFound, length: 0)
        )
        // Hide window synchronously — we are on the main thread here.
        MainActor.assumeIsolated { candidateWindow.hide() }
    }

    private func commitText(_ text: String, client: IMKTextInput) {
        client.insertText(text, replacementRange: NSRange(location: NSNotFound, length: 0))

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            UserDictionaryStore.shared.saveWord(trimmed)
        }

        session.reset()
        // SYNC: hide immediately so state (session.isComposing == false) and
        // the UI (window hidden) are always in sync. Async hiding caused a
        // brief window where a fast-typed next character arrived with the
        // window still visible but the session already reset.
        MainActor.assumeIsolated { candidateWindow.hide() }
    }

    override func activateServer(_ sender: Any!) {
        // FIX: Reset session BEFORE calling super so any stale preedit state
        // from a previous deactivateServer (e.g., tab-switch race in Chrome)
        // is fully cleared before the new client starts receiving events.
        session.reset()
        MainActor.assumeIsolated { candidateWindow.hide() }
        super.activateServer(sender)
    }

    override func deactivateServer(_ sender: Any!) {
        // Commit any pending preedit before handing control back to the system.
        if let client = sender as? IMKTextInput, session.isComposing {
            commitText(session.currentComposition, client: client)
        }
        // SYNC: hide window synchronously so the state is clean before
        // activateServer fires on the next focused client.
        MainActor.assumeIsolated { candidateWindow.hide() }
        super.deactivateServer(sender)
    }

    override func commitComposition(_ sender: Any!) {
        if let client = sender as? IMKTextInput, session.isComposing {
            commitText(session.currentComposition, client: client)
        }
    }

    override func candidates(_ sender: Any!) -> [Any]! {
        return session.currentCandidates
    }
}

private enum KeyCode {
    static let returnKey: UInt16 = 36
    static let enter: UInt16 = 76
    static let backspace: UInt16 = 51
    static let escape: UInt16 = 53
    static let space: UInt16 = 49
    static let leftArrow: UInt16 = 123
    static let rightArrow: UInt16 = 124
    static let downArrow: UInt16 = 125
    static let upArrow: UInt16 = 126
    static let tab: UInt16 = 48
}

private final class SendableClient: @unchecked Sendable {
    let client: IMKTextInput
    init(_ client: IMKTextInput) {
        self.client = client
    }
}

