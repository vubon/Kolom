import Cocoa
import InputMethodKit

// MARK: - IMK Server Bootstrap
// Must be created before the run loop starts.
// The name must exactly match Info.plist key "InputMethodConnectionName".
let kIMKConnectionName = "com.kolom.inputmethod.Kolom_Connection"

// IMKServer manages all KolomInputController instances — one per text field.
let server = IMKServer(
    name: kIMKConnectionName,
    bundleIdentifier: Bundle.main.bundleIdentifier
)

// Prevent dead code stripping in Release builds
// IMKServer uses reflection (NSClassFromString) to instantiate the controller based on Info.plist.
// Without this explicit reference, Swift will strip the class from the Release binary.
_ = KolomInputController.self

// Standard Swift app bootstrap — set delegate then run the event loop
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
