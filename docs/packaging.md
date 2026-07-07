# Packaging Guide — Kolom

**File:** `docs/packaging.md`

---

# Overview

This document describes how Kolom is packaged into a distributable macOS application bundle.

Kolom is an Input Method Kit (IMK) based system component, so its packaging must comply with macOS input method requirements in addition to standard app bundling rules.

---

# Packaging Goals

The packaging system must ensure:

* Valid macOS `.app` bundle structure
* Correct InputMethodKit integration
* Apple Silicon compatibility
* Proper resource inclusion
* Reliable loading by macOS input system
* Separation of debug and release builds

---

# Build Targets

Kolom should support two primary build configurations:

## 1. Debug Build

Used for development:

* Unsigned or development-signed
* Verbose logging enabled
* Hot reload (if supported internally)
* Local testing only
* Not suitable for distribution

---

## 2. Release Build

Used for production:

* Fully signed (Developer ID)
* Notarized by Apple
* Optimized performance
* No debug logging
* Ready for distribution

---

# Bundle Structure

Kolom must be packaged as a standard macOS application bundle:

```text id="pkg1"
Kolom.app
└── Contents
    ├── Info.plist
    ├── MacOS/
    │   └── Kolom (main binary & IMK Server)
    ├── Resources/
    │   ├── Dictionaries/
    │   ├── Assets/
    │   └── Config/
    └── Frameworks/
```

---

# Key Components

## 1. Main Binary (IMK Server)

Responsible for:

* Bootstrapping IMK system
* Initializing Input Method lifecycle
* Session creation and event forwarding
* Loading core engine modules

macOS launches this binary in the background when the input source is activated.

---

## 3. Resources

Includes:

* Core dictionary data
* User dictionary defaults
* Configuration templates
* UI assets (candidate window styling)

Resources must be read-only at runtime (except user dictionary layer).

---

# Info.plist Requirements

The `Info.plist` must define:

* Bundle identifier
* InputMethodKit registration keys
* Supported input sources
* Minimum macOS version
* Architecture compatibility (Apple Silicon only for V1)

Incorrect configuration will prevent system registration.

---

# Build Process

## Step 1: Compile Source

* Swift (or hybrid Swift + Rust core if used)
* Ensure architecture: `arm64`

---

## Step 2: Link Modules

* Core engine
* Core engine and UI components
* UI components
* Dictionary resources

---

## Step 3: Assemble App Bundle

* Create `.app` structure
* Place binaries in `MacOS/`
* Attach resources

---

## Step 4: Code Signing

Sign using Apple Developer ID:

* Maintain consistent entitlements across the app bundle
* Maintain consistent entitlements across modules

---

## Step 5: Notarization (Release only)

Submit to Apple notarization service:

* Required for external distribution
* Ensures macOS Gatekeeper compatibility

---

## Step 6: Distribution Packaging

Final output formats:

* `.app` (for development/testing)
* `.dmg` (optional distribution format)
* `.pkg` (installer-based distribution)

---

# Architecture Constraints

## Must NOT:

* Bundle AI or external network dependencies in core IME
* Mix debug and release resources
* Modify system-level IMK behavior at runtime
* Load external code dynamically in production

---

## Must:

* Keep IME deterministic
* Ensure reproducible builds
* Separate core engine from UI layer
* Maintain Apple Silicon compatibility

---

# Resource Management

### Dictionary Files

* Loaded at startup or lazily
* Cached in memory for performance
* Versioned for future updates

---

### Configuration Files

* Loaded at runtime
* Mapped to Settings module
* Safe to reload without restart

---

# Performance Considerations

Packaging must ensure:

* Fast startup (<200ms IME activation target)
* Minimal disk I/O during typing
* Efficient memory usage for dictionary loading
* No runtime decompression delays

---

# Development vs Production Differences

| Aspect       | Debug    | Release  |
| ------------ | -------- | -------- |
| Signing      | Optional | Required |
| Logging      | Verbose  | Disabled |
| Optimization | Off      | On       |
| Distribution | Local    | External |
| Notarization | No       | Yes      |

---

# Error Handling

Common packaging issues:

## IME not appearing in system

* Invalid Info.plist
* Missing InputMethodKit registration
* Unsigned bundle

---

## Crash on activation

* Architecture mismatch (non-arm64)
* Missing dependencies
* Broken framework linkage

---

## Candidate window not working

* UI module not included in bundle
* Resource loading failure
* Engine initialization error

---

# Security Requirements

Kolom must:

* Be fully signed in release builds
* Avoid runtime code injection
* Restrict external execution
* Prevent unauthorized resource modification

---

# Testing Requirements

Packaging must be validated with:

* Fresh macOS installation test
* Clean user profile test
* Input source activation test
* Restart persistence test
* Multi-app compatibility test (TextEdit, Safari, etc.)

---

# Relationship to Other Systems

Packaging connects:

```text id="pkgflow"
SPDD Core Engine
        ↓
Build System
        ↓
App Bundle
        ↓
macOS InputMethodKit Loader
        ↓
User Input Experience
```

Packaging is the bridge between architecture and real-world execution.

---

# Design Principle

Packaging must be:

> deterministic, reproducible, and system-compliant

A given commit should always produce a valid IME bundle without manual intervention.
