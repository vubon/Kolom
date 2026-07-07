import Cocoa
import SwiftUI

// MARK: - SettingsWindowController
// Hosts the SwiftUI SettingsView inside a native NSWindow.
// Accessible from the Kolom menu bar icon.

final class SettingsWindowController: NSWindowController {

    convenience init() {
        let hostingController = NSHostingController(rootView: SettingsView())
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Kolom Preferences"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(width: 420, height: 340))
        window.center()
        self.init(window: window)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(sender)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - SettingsView

struct SettingsView: View {

    @ObservedObject private var settings = SettingsStore.shared

    var body: some View {
        Form {
            // ── Input Mode ────────────────────────────────────────────────
            Section("Input") {
                Picker("Default Mode", selection: $settings.defaultInputMode) {
                    ForEach(InputMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            // ── Candidate Suggestions ─────────────────────────────────────
            Section("Candidate Suggestions") {
                Stepper(
                    "Show up to \(settings.maxCandidates) candidates",
                    value: $settings.maxCandidates,
                    in: 1...9
                )
                Toggle("Compact candidate window", isOn: $settings.candidateStyleCompact)
            }

            // ── Dictionary ────────────────────────────────────────────────
            Section("Dictionary") {
                Toggle("Enable user dictionary", isOn: $settings.userDictionaryEnabled)
            }

            // ── Appearance ────────────────────────────────────────────────
            Section("Appearance") {
                Toggle("Show status bar icon", isOn: $settings.showStatusBarIcon)
            }

            Divider()

            // ── Reset ─────────────────────────────────────────────────────
            HStack {
                Spacer()
                Button("Restore Defaults") {
                    settings.resetToDefaults()
                }
                .foregroundColor(.red)
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 420)
    }
}
