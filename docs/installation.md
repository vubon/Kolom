# Installation Guide — Kolom

**File:** `docs/installation.md`

---

# Overview

This document explains how Kolom is installed, registered, and activated as a macOS Input Method on Apple Silicon systems.

Kolom is not a standard application. It is an Input Method Kit (IMK) based system component that integrates directly with macOS text input services.

---

# Installation Model

Kolom follows a **system-registered input method architecture**:

* Installed as a macOS app bundle
* Registered with InputMethodKit
* Enabled manually by the user in System Settings
* Activated per input source selection

Kolom does not run as a background typing daemon. It is loaded by macOS when selected as an input source.

---

# Prerequisites

* macOS (Apple Silicon only target for v1)
* Code-signed application bundle (required for IMK)
* Notarized build (recommended for distribution)
* Accessibility permission (for full text interaction support)
* Input Monitoring permission (if required by implementation)

---

# Installation Steps (User Perspective)

## 1. Install Application

User installs Kolom via:

* `.app` bundle (drag into Applications)
* or signed installer package (`.pkg`)

---

## 2. Open System Settings

Navigate to:

* System Settings → Keyboard → Input Sources

---

## 3. Add Input Method

User selects:

* “Kolom” from input source list

If Kolom is not visible:

* Restart system or log out/in
* Ensure app is properly installed and signed

---

## 4. Enable Kolom

User activates Kolom as an input source.

From this point:

* macOS loads Kolom via InputMethodKit
* Kolom becomes available in menu bar input switcher

---

## 5. Start Typing

When selected:

* Kolom intercepts keyboard events
* IME pipeline becomes active
* Candidate window appears during composition

---

# System Integration Model

```text id="imkflow1"
macOS Text System
        │
        ▼
InputMethodKit Loader
        │
        ▼
Kolom Input Method Bundle
        │
        ▼
Input Session
        │
        ▼
IME Pipeline (SPDD Core)
```

Kolom is not manually launched by the user.

It is instantiated by macOS when needed.

---

# Application Bundle Requirements

Kolom must be packaged as a valid macOS Input Method bundle:

## Required structure

```text id="bundle1"
Kolom.app
├── Contents
│   ├── Info.plist
│   ├── MacOS/ (Contains IMK Server and Kolom binary)
│   ├── Resources/
│   └── Frameworks/
```

---

## Key Requirement

The Input Method must be registered in:

* `Info.plist`
* InputMethodKit configuration
* Bundle identifiers consistent across system

---

# Code Signing Requirements

Kolom must be:

* Code signed with Apple Developer ID
* Notarized for distribution outside local development
* Proper entitlements set

Without signing:

* macOS may block IME loading
* Input Method may not appear in system list

---

# Permissions Model

Depending on implementation details, Kolom may require:

## Accessibility Permission

* Required for advanced text interaction
* Enables better integration with text fields

## Input Monitoring Permission

* Required for capturing keyboard events in some contexts

User must explicitly grant permissions in:

* System Settings → Privacy & Security

---

# First Run Behavior

On first activation:

* Kolom initializes default settings
* Loads core dictionary
* Registers candidate engine
* Creates initial input session factory

No user data is collected.

---

# Input Source Registration

Kolom registers itself as:

* A system input source
* Available in keyboard switcher
* Persistent across system restarts

Registration is handled by macOS, not manually by Kolom.

---

# Failure Scenarios

## Input Method Not Visible

Possible causes:

* Improper code signing
* Missing Info.plist configuration
* Bundle not installed in correct location

---

## IME Not Activating

Possible causes:

* Permissions not granted
* System not restarted after installation
* Input Method not enabled

---

## Candidate Window Not Showing

Possible causes:

* Candidate Engine not connected
* Composition not active
* UI layer failure

---

# Performance Expectations

At system level:

* IME activation must be near-instant
* No noticeable delay when switching input sources
* Minimal system resource usage when idle

---

# Security Considerations

Kolom must:

* Respect system input boundaries
* Not capture input outside active composition
* Not log or transmit keystrokes
* Operate fully offline

---

# Troubleshooting Guide

If Kolom does not appear:

1. Verify app is in Applications folder
2. Restart macOS
3. Check System Settings → Input Sources
4. Verify code signing status
5. Reinstall application

---

# Relationship to SPDD

This document is NOT part of SPDD runtime design.

It is a system integration guide that supports SPDD-defined behavior.

SPDD defines:

* How typing works

This document defines:

* How typing becomes available in macOS

---

# Design Principle

Installation is not part of the IME logic.

It is the bridge between:

> Kolom (software system)
> and
> macOS (host platform)
