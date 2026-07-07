import Cocoa

// MARK: - AppDelegate
// Manages the Kolom menu bar presence. The app itself is a LSUIElement
// (no Dock icon) — it lives entirely in the macOS input source system.

@MainActor
@objc(AppDelegate)
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem?
    private var settingsWindowController: SettingsWindowController?

    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBarStatusItem()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep running when the settings window is closed — the IME is a background service.
        return false
    }

    // MARK: - Menu Bar

    private func setupMenuBarStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else { return }
        button.title = "ক"
        button.font = NSFont.systemFont(ofSize: 14, weight: .medium)

        let menu = NSMenu(title: "Kolom")
        menu.addItem(withTitle: "Kolom Bengali IME", action: nil, keyEquivalent: "")
            .isEnabled = false
        menu.addItem(.separator())
        menu.addItem(withTitle: "Preferences…", action: #selector(openPreferences), keyEquivalent: ",")
            .target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "About Kolom", action: #selector(showAbout), keyEquivalent: "")
            .target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Kolom", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        statusItem?.menu = menu
    }

    // MARK: - Actions

    @objc private func openPreferences() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Kolom"
        alert.informativeText = "A native Bengali keyboard for Apple Silicon Macs.\nVersion 0.1.0"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
