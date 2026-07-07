import Foundation

// MARK: - UserDictionaryStore
// Manages words typed by the user that are not in the core dictionary.
// Conforms to DictionaryService.

final class UserDictionaryStore: DictionaryService, @unchecked Sendable {

    static let shared = UserDictionaryStore()

    private(set) var allEntries: [DictionaryEntry] = []
    private var exactIndex: [String: [DictionaryEntry]] = [:]
    private var prefixIndex: [String: [DictionaryEntry]] = [:]

    private let saveQueue = DispatchQueue(label: "com.kolom.userdict.save", qos: .background)
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appDir = paths[0].appendingPathComponent("KolomIME")
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        return appDir.appendingPathComponent("user-dictionary.json")
    }

    private init() {
        loadDictionary()
    }

    // MARK: - DictionaryService

    func exactLookup(_ word: String) -> [DictionaryEntry] {
        return exactIndex[word] ?? []
    }

    func prefixLookup(_ prefix: String) -> [DictionaryEntry] {
        guard prefix.count >= 1 else { return [] }
        return prefixIndex[prefix] ?? []
    }

    // MARK: - API

    func saveWord(_ word: String) {
        guard !word.isEmpty, exactIndex[word] == nil else { return }
        
        // Also check core dictionary so we don't save duplicates
        if !JSONDictionaryStore.shared.exactLookup(word).isEmpty { return }
        
        let entry = DictionaryEntry(word: word, frequency: 1000, source: "user")
        allEntries.append(entry)
        exactIndex[word] = [entry]
        
        var prefixChars = ""
        for char in word.unicodeScalars {
            prefixChars += String(char)
            prefixIndex[prefixChars, default: []].append(entry)
            prefixIndex[prefixChars]!.sort { $0.frequency > $1.frequency }
        }

        let entriesToSave = allEntries // Thread-safe copy
        saveQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try JSONEncoder().encode(entriesToSave)
                try data.write(to: self.fileURL, options: .atomic)
            } catch {
                print("[Kolom] Failed to save user dictionary: \(error)")
            }
        }
    }

    // MARK: - Loading

    private func loadDictionary() {
        do {
            let data = try Data(contentsOf: fileURL)
            let entries = try JSONDecoder().decode([DictionaryEntry].self, from: data)
            allEntries = entries
            
            for entry in entries {
                exactIndex[entry.word] = [entry]
                var prefixChars = ""
                for char in entry.word.unicodeScalars {
                    prefixChars += String(char)
                    prefixIndex[prefixChars, default: []].append(entry)
                }
            }
            
            for key in prefixIndex.keys {
                prefixIndex[key]!.sort { $0.frequency > $1.frequency }
            }
        } catch {
            print("[Kolom] Note: No user dictionary found or failed to load. \(error.localizedDescription)")
        }
    }
}
