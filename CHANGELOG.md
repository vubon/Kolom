# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-07-14

### Fixed
- **Chrome / Chromium-based browser input freeze**: Replaced async `Task { @MainActor }` dispatching in the critical IMK event path with synchronous `MainActor.assumeIsolated` calls. Chrome's out-of-process text input model blocked waiting for `setMarkedText` to be reflected on the same call stack, causing the browser to freeze until the next run-loop tick.
- **Candidate window UI desync after commit**: `candidateWindow.hide()` was dispatched asynchronously after `commitText()`, creating a brief window where a fast-typed next character arrived with the window still visible but the session already reset. Now hides synchronously.
- **Stale state on tab-switch (Chrome)**: `activateServer` now calls `session.reset()` and hides the candidate window *before* `super.activateServer`, preventing stale preedit state from a previous deactivation race condition when switching browser tabs.

## [1.0.0] - 2026-07-07

### Added
- Initial open-source release of Kolom for Apple Silicon Macs.
- Core phonetic Bengali engine with Avro-compatible typing rules.
- Deterministic Candidate Engine with exact match and frequency sorting.
- macOS Input Method Kit (IMK) integration.
- Custom Candidate Window UI with keyboard selection support.
- Fully offline User Dictionary storage system.
- Strict strict-concurrency architecture to prevent target application freezing.
- `install.sh` utility to build, deploy, and register the IME seamlessly.
- XcodeGen support (`project.yml`) for programmatic Xcode project generation.
