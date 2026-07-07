import Foundation
import Combine

// MARK: - SettingsStore
// Persists and provides user-configurable Kolom preferences.
// Uses UserDefaults for simple values. All settings have safe defaults.
// Publishes changes for SwiftUI observation via Combine.
//
// Swift 6 concurrency note:
// @unchecked Sendable is safe here — UserDefaults is itself thread-safe,
// and all reads/writes go through it. objectWillChange is dispatched on
// the main thread by convention (settings UI is always on main actor).

final class SettingsStore: ObservableObject, @unchecked Sendable {

    // MARK: - Shared instance
    static let shared = SettingsStore()

    // MARK: - Keys (namespaced to avoid collisions)

    private enum Keys {
        static let defaultInputMode   = "kolom.defaultInputMode"
        static let maxCandidates      = "kolom.maxCandidates"
        static let candidateCompact   = "kolom.candidateStyleCompact"
        static let userDictEnabled    = "kolom.userDictionaryEnabled"
        static let showStatusBar      = "kolom.showStatusBarIcon"
    }

    private let defaults: UserDefaults

    // MARK: - Initialisation

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        registerDefaults()
    }

    private func registerDefaults() {
        defaults.register(defaults: [
            Keys.defaultInputMode : InputMode.bengali.rawValue,
            Keys.maxCandidates   : 9,
            Keys.candidateCompact: false,
            Keys.userDictEnabled : true,
            Keys.showStatusBar   : true,
        ])
    }

    // MARK: - Settings Properties
    // Each property reads from UserDefaults and publishes via objectWillChange.

    var defaultInputMode: InputMode {
        get {
            let raw = defaults.string(forKey: Keys.defaultInputMode) ?? InputMode.bengali.rawValue
            return InputMode(rawValue: raw) ?? .bengali
        }
        set {
            objectWillChange.send()
            defaults.set(newValue.rawValue, forKey: Keys.defaultInputMode)
        }
    }

    var maxCandidates: Int {
        get { max(1, min(9, defaults.integer(forKey: Keys.maxCandidates))) }
        set {
            objectWillChange.send()
            defaults.set(max(1, min(9, newValue)), forKey: Keys.maxCandidates)
        }
    }

    var candidateStyleCompact: Bool {
        get { defaults.bool(forKey: Keys.candidateCompact) }
        set {
            objectWillChange.send()
            defaults.set(newValue, forKey: Keys.candidateCompact)
        }
    }

    var userDictionaryEnabled: Bool {
        get { defaults.bool(forKey: Keys.userDictEnabled) }
        set {
            objectWillChange.send()
            defaults.set(newValue, forKey: Keys.userDictEnabled)
        }
    }

    var showStatusBarIcon: Bool {
        get { defaults.bool(forKey: Keys.showStatusBar) }
        set {
            objectWillChange.send()
            defaults.set(newValue, forKey: Keys.showStatusBar)
        }
    }

    // MARK: - Reset

    func resetToDefaults() {
        objectWillChange.send()
        [Keys.defaultInputMode, Keys.maxCandidates,
         Keys.candidateCompact, Keys.userDictEnabled, Keys.showStatusBar]
            .forEach { defaults.removeObject(forKey: $0) }
    }
}
