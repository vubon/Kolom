# Input Source Registration — Kolom

**File:** `docs/input-source-registration.md`

---

# Overview

This document defines how Kolom is registered as a macOS Input Source and becomes available in the system keyboard switcher.

Input Source Registration is the final step that connects:

* Installed application bundle
* macOS InputMethodKit system
* User-accessible keyboard input selection

---

# What is an Input Source?

In macOS, an input source is:

> A system-recognized keyboard or input method that users can switch to while typing.

Examples:

* U.S. English Keyboard
* Emoji Keyboard
* Third-party IMEs (like Kolom)

---

# Registration Model

Kolom is registered as:

* A system input method (via InputMethodKit)
* A selectable input source
* A persistent system configuration entry

Registration is handled by macOS, not manually by Kolom at runtime.

---

# Registration Prerequisites

Before Kolom can appear as an input source:

* App must be installed in `/Applications`
* Bundle must be valid `.app` structure
* Code signing must be valid
* IMK plugin must be properly embedded
* System must recognize InputMethodKit declaration

---

# Registration Flow

## Step 1: System Discovery

macOS scans:

```text id="reg1"
~/Library/Input Methods/
```

and:

```text id="reg2"
/Applications/Kolom.app
```

It detects IMK-compatible bundles via:

* Info.plist configuration
* InputMethodKit declarations

---

## Step 2: Input Method Loading

When discovered, macOS:

* Registers Kolom as available input method
* Adds it to system input source database
* Makes it visible in Keyboard settings

---

## Step 3: User Enablement

User must manually enable Kolom:

* System Settings → Keyboard → Input Sources
* Click “+”
* Select Kolom

This step is required for security reasons.

---

## Step 4: Activation

Once enabled:

* Kolom appears in menu bar input switcher
* macOS can activate Kolom per text field context
* InputMethodKit instantiates Kolom when selected

---

# Runtime Activation Flow

```text id="actflow1"
User selects Kolom input source
            ↓
macOS Input System
            ↓
InputMethodKit loads Kolom bundle
            ↓
Kolom Input Method instance created
            ↓
Input Session initialized
            ↓
IME pipeline becomes active
```

---

# Info.plist Requirements

Kolom must declare itself correctly:

* InputMethodKit bundle type
* Input source identifiers
* Language support metadata
* Bundle identifier consistency

Incorrect metadata results in silent failure (IME not appearing).

---

# System Registration Location

macOS stores enabled input sources in:

* User-level preferences database
* System input source registry

Kolom does not directly modify these.

---

# First-Time Enablement Behavior

When Kolom is enabled for the first time:

* System loads Kolom IME module
* Default settings are initialized
* Core dictionary is loaded
* Input Session factory is prepared
* Candidate engine becomes ready

No user data is collected or transmitted.

---

# Switching Behavior

Kolom supports:

* Instant switching via keyboard shortcut
* Menu bar input source switching
* Per-application input persistence (macOS feature)

Kolom must respond correctly to activation and deactivation events.

---

# Deactivation Behavior

When user switches away:

* Active Input Session is terminated
* Composition is either committed or cancelled
* Candidate window is dismissed
* State is cleaned up

No persistent runtime state should remain active.

---

# Failure Modes

## 1. Kolom does not appear in input sources

Possible causes:

* Improper code signing
* Invalid Info.plist configuration
* Missing InputMethodKit declaration
* Bundle not in correct location

---

## 2. Kolom appears but cannot be enabled

Possible causes:

* Corrupted IMK plugin
* Missing architecture support (arm64 required)
* System cache not refreshed

---

## 3. Kolom enabled but not active in text fields

Possible causes:

* Input Session not initialized
* IMK delegate failure
* Candidate engine not responding

---

# System Constraints

macOS enforces:

* User must explicitly enable input sources
* IMEs cannot self-activate globally
* Input switching is user-controlled

Kolom must comply fully with these rules.

---

# Security Model

Input sources are sensitive system components.

Kolom must ensure:

* No unauthorized input capture
* No background keylogging outside active composition
* No persistence of keystrokes
* No external transmission of input data

---

# Performance Requirements

* Input source switching must be instantaneous
* IME activation latency must be minimal (<100ms target)
* No delay when switching between apps
* Clean deactivation without memory leaks

---

# Relationship to Other Systems

```text id="relflow1"
Installation
      ↓
Packaging
      ↓
Signing
      ↓
Input Source Registration
      ↓
Runtime IME Activation
      ↓
SPDD Core Pipeline
```

This is the final step before runtime execution begins.

---

# Design Principle

Input Source Registration is not application logic.

It is system integration logic.

> It determines whether Kolom exists as a usable keyboard inside macOS.
