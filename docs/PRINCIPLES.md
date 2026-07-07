# Engineering Principles

**File:** `docs/PRINCIPLES.md`

---

# Kolom Engineering Principles

> These principles define how Kolom is designed, implemented, tested, and maintained.

---

# 1. Native First
Kolom is a macOS application, not a cross-platform application. Every implementation should embrace Apple's frameworks (Swift, SwiftUI, Input Method Kit, AppKit).

# 2. Apple Silicon Only
Kolom targets Apple Silicon (`arm64`) exclusively. The project will optimize for modern Apple hardware rather than preserving compatibility with legacy Intel systems.

# 3. Privacy by Design
Kolom should never require users to trade privacy for functionality.
* Works fully offline.
* Never transmits typed text.
* The User Dictionary is stored exclusively on local disk.

# 4. Unicode Is the Source of Truth
All text produced by Kolom must be valid Unicode.

# 5. Performance Is a Feature
Typing should feel instantaneous.
* Typing latency under 16 ms.
* Low memory usage (e.g., dictionary loaded in memory must remain small).
* Expensive operations (like saving user dictionary) run on background threads.

# 6. Reliability Over Features
A smaller feature set that works flawlessly is preferable to a larger feature set with inconsistent behavior.

# 7. Simplicity Wins
Simple code is easier to understand, test, and maintain. Avoid premature optimizations (e.g., sticking with JSON linear scan until 100k+ words necessitates a Trie).

# 8. Modular Design
Each module should have a single, well-defined responsibility. Business logic must remain independent of presentation logic.

# 9. Composition Over Inheritance
Favor composition whenever possible. Prefer protocols and dependency injection.

# 10. Explicit Dependencies
Avoid global mutable state and hidden singletons unless strictly necessary (like `SettingsStore.shared`).

# 11. Readability Before Cleverness
Code is read more often than it is written. Choose the simpler approach.

# 12. Testability Is Required
Every significant component should be testable in isolation.

# 13. Swift API Design Guidelines
Follow Apple's Swift API Design Guidelines. Use descriptive names and minimize force unwrapping.

# 14. Human Interface Guidelines
The user experience should align with Apple's Human Interface Guidelines. E.g. using a modern Horizontal candidate layout that feels native.

# 15. Incremental Development
Develop Kolom in small, well-defined increments. Working software is preferred over speculative architecture.

# 16. Definition of Quality
High-quality code in Kolom is: Correct, Readable, Maintainable, Predictable, Performant, Native to macOS, and Respectful of user privacy.
