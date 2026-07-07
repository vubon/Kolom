<div align="center">
  <img src="assets/kolom_hero.png" alt="Kolom Logo" width="200"/>
</div>

# Kolom 

> **A native Bengali keyboard for Apple Silicon Macs.**

## Building from Source

For developers or open-source users who want to compile Kolom directly from source:

**Prerequisites:** You must have **Git** and full **Xcode** installed from the Mac App Store (the basic Command Line Tools are not enough to build macOS apps).

```bash
git clone https://github.com/vubon/kolom.git
cd kolom
./install.sh
```

This script will automatically:
1. Compile the app in Release mode
2. Install it to your `~/Library/Input Methods` folder
3. Register the keyboard with macOS instantly

---

Kolom is a modern, native Bengali Input Method (IME) designed exclusively for Apple Silicon Macs (`arm64`). It is built using Swift, SwiftUI, and macOS's native **Input Method Kit (IMK)** framework to provide a fast, reliable, privacy-focused typing experience that integrates seamlessly with the operating system.

---

## Architecture & Principles

Kolom is organized into highly independent modules to ensure speed, stability, and maintainability:
* **Native First:** Built with Swift, AppKit, SwiftUI, and Input Method Kit.
* **Privacy-First:** Operates entirely offline. No cloud sync, no tracking, and no internet connections.
* **Deterministic Suggestions:** Candidates are ranked using deterministic priority rules (exact matches, frequency scores, and user vocabulary) without external prediction libraries.

For detailed design specs, see the documentation:
* [System Architecture Document](docs/00-system-architecture.md)
* [Engineering Principles](docs/PRINCIPLES.md)
* [Glossary of Terms](docs/GLOSSARY.md)

---

## Prerequisites

To compile and register Kolom, you need:
* An **Apple Silicon Mac** (M1/M2/M3/M4) running **macOS 13.0** or newer.
* **Xcode 15.0** or newer (available on the Mac App Store or [Apple Developer Portal](https://developer.apple.com/download/)).
* **XcodeGen** (used to generate the `.xcodeproj` file from the spec).

---

## Getting Started

### 1. Generate the Xcode Project

If the `.xcodeproj` is not present, or if you modify `project.yml`, regenerate it using XcodeGen:

```bash
# If XcodeGen is not installed
brew install xcodegen

# Generate the project
xcodegen generate --spec project.yml
```

This will create `Kolom.xcodeproj` containing:
- `Kolom` (Main target including the Input Method server and Settings UI)
- `KolomTests` (Unit tests)

---

## Building and Registering Kolom

macOS treats input methods as high-trust system components. You must perform the following steps in Xcode to enable it:

### Step 1: Open the Project
```bash
open Kolom.xcodeproj
```

### Step 2: Set your Development Team (Required for Code Signing)
1. In the left navigator pane, select the **Kolom** project node.
2. Select the **Kolom** target.
3. Select the **Signing & Capabilities** tab.
4. Set the **Team** dropdown to your Apple Developer account.
5. *Note:* Make sure both the main application target and any embedded extension schemas are signed with the same identity.

### Step 3: Build and Run
1. Select the **Kolom** scheme from the Xcode target selector.
2. Press **⌘R** (or Product → Run) to compile and launch the application helper.
3. The application will launch as a background utility (an icon `ক` will appear in your macOS menu bar).

### Step 4: Add to macOS Input Sources
1. Open **System Settings** on your Mac.
2. Navigate to **Keyboard** ➔ **Input Sources** (or **Keyboard** ➔ click **Edit...** under Input Sources).
3. Click the **+** (Add) button.
4. Search for or select **Kolom**, then click **Add**.
5. Switch to **Kolom** using the input switcher in your menu bar (or using the keyboard shortcut `Fn` / `🌐` / `Control+Space` depending on your settings).
6. Open **TextEdit** and start typing in Avro phonetic transliteration (e.g. type `ami` to get `আমি`).

---

## Run Unit Tests

You can run the unit tests directly from Xcode or via the command line.

**Option 1: Using the Command Line (Recommended)**
Open your terminal and run the following command in the `kolom` directory:
```bash
xcodebuild test -project Kolom.xcodeproj -scheme KolomTests -destination 'platform=macOS'
```

**Option 2: Using Xcode**
1. Open `Kolom.xcodeproj` in Xcode.
2. Select the **KolomTests** scheme from the top bar.
3. Press **⌘U** (or go to Product → Test in the menu).

Tests cover:
* [Transliteration Rules & Vowel/Consonant Context](Tests/TransliterationEngineTests.swift)
* [Composition Lifecycle & Buffer Updates](Tests/CompositionEngineTests.swift)
* [Candidate Deduplication & Scored Ranking](Tests/CandidateEngineTests.swift)

---

## Directory Structure

* [KolomApp/](KolomApp/) — App bootstrapping, status bar agent, and App Delegate.
* [KolomInputMethod/](KolomInputMethod/) — Core IME components, event interceptors, and candidate visual overlay.
* [KolomEngine/](KolomEngine/) — Phonetic parsing, rule compiler, and preedit buffer manager.
* [KolomDictionary/](KolomDictionary/) — Core and user lexicography stores.
* [KolomSettings/](KolomSettings/) — Preferences panels.
* [docs/](docs/) — Manual installation, signing, and integration specs.

---

## Phonetic Grammar (Typing Guide)

Kolom uses a standard phonetic mapping (similar to Avro) to transliterate English letters into Bengali characters.

### Vowels

| English | Independent (Start of word) | Dependent (Matra / কার) |
|---------|-----------------------------|-------------------------|
| `a` / `A` | আ | া |
| `i` | ই | ি |
| `I` | ঈ | ী |
| `u` | উ | ু |
| `U` | ঊ | ূ |
| `e` | এ | ে |
| `o` | অ | *(no matra)* |
| `O` | ও | ো |
| `aa` | আ | া |
| `ii` | ঈ | ী |
| `uu` | ঊ | ূ |
| `oi` | ঐ | ৈ |
| `ou` | ঔ | ৌ |
| `rri` | ঋ | ৃ |

### Consonants

| English | Bengali | English | Bengali |
|---------|---------|---------|---------|
| `k` | ক | `t` | ত |
| `kh` | খ | `th` | থ |
| `g` | গ | `d` | দ |
| `gh` | ঘ | `dh` | ধ |
| `ng` | ং (Anusvara) | `n` | ন |
| `Ng` | ঙ | `p` | প |
| `c` / `ch` | চ | `f` / `ph`| ফ |
| `Ch` / `chh`| ছ | `b` | ব |
| `j` | জ | `v` / `bh`| ভ |
| `jh` | ঝ | `m` | ম |
| `NG` | ঞ | `z` / `y` | য |
| `T` | ট | `Y` | য় |
| `Th` | ঠ | `r` | র |
| `D` | ড | `l` | ল |
| `Dh` | ঢ | `S` / `sh`| শ |
| `N` | ণ | `Sh` | ষ |
| `R` / `rr`| ড় | `s` | স |
| `Rh` | ঢ় | `h` | হ |

### Special Characters & Modifiers

| English | Bengali | Note |
|---------|---------|------|
| `t\`` or `T\``| ৎ | Khanda Ta |
| `^` | ঁ | Chandrabindu |
| `:` | ঃ | Bisarga |
| `\`` (backtick)| ্ | Hasanta (Explicitly link consonants) |
| `.` | । | Dari (Full stop) |
| `..` | ॥ | Double Dari |
| `kSh` | ক্ষ | Ksha Conjunct |
| `jNG` | ঞ্জ | Jnya Conjunct |

**Typing Conjuncts (যুক্তাক্ষর):**
To combine two consonants, simply type them consecutively. The engine automatically inserts a Hasanta (`্`) between them.
If you need to separate two consonants so they *don't* form a conjunct, use `o` (which acts as an invisible inherent vowel separator).

**Examples of Complex Words:**

| Bengali Word | English (Pronunciation) | Phonetic Typing | Explanation / Note |
|--------------|------------------------|-----------------|--------------------|
| **স্ত্রী**       | Stri                   | `strI`          | Consecutive consonants (`str`) join automatically |
| **বঙ্গ**       | Banga                  | `boNgg`         | The `o` separates `b` and `Ng` to prevent `ব্ঙ` |
| **বাঙালি**     | Bangali                | `baNgali`       | Capital `N` is required to get `ঙ` |
| **বিজ্ঞান**    | Biggan                 | `bijNGan`       | `jNG` is a built-in shortcut for `জ্ঞ` |
| **ক্ষমা**      | Kkhoma                 | `kShoma`        | `kSh` is a built-in shortcut for `ক্ষ` |
| **শিক্ষক**     | Shikkhok               | `shikShok`      | Standard use of the `kSh` conjunct |
| **বাংলা**     | Bangla                 | `bangla`         | `ng` naturally produces the Anusvara (`ং`) |
| **কৃষ্ণ**      | Krishno                 | `krriShN`       | `krri` gets you `কৃ` (k + rri), and `N` gets you `ণ` |
| **কৃষ্ণা**     | Krishnaa                | `krriShNa`      | Adding `a` at the end attaches the `া` to the conjunct |
| **গঞ্জ**     | Gonj                     | `goNGj`      | `NG` is used for `ঞ`. `ng` would wrongly produce `গংজ` |


**Auto-Learning & Ambiguity:**
If a typed word matches multiple spellings (like typing `t` at the end of a word when you meant `ৎ`), the candidate window will intelligently suggest words from the dictionary. Kolom also learns your unique words automatically!
