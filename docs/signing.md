# Code Signing Guide — Kolom

**File:** `docs/signing.md`

---

# Overview

This document defines how Kolom is signed, verified, and authorized to run on macOS systems.

Code signing is mandatory for:

* Input Method Kit (IMK) registration
* System-level input source activation
* Distribution outside local development

Without proper signing, macOS will block or ignore the input method entirely.

---

# Why Code Signing Matters

macOS treats Input Methods as **high-trust system components**.

Therefore Kolom must prove:

* It is from a trusted developer
* It has not been modified after build
* It is safe to load into system input services

---

# Signing Requirements

Kolom must be signed with:

## Developer Identity

* Apple Developer ID Application certificate

This enables:

* System trust
* Gatekeeper compatibility
* Notarization eligibility

---

## Architecture Consistency

All components must be signed consistently:

* Main app bundle
* Embedded frameworks

Mismatch will cause IME loading failure.

---

# Signing Scope

Every distributed build must sign:

* `Kolom.app`
* `Contents/MacOS/Kolom`
* All embedded frameworks
* All helper binaries

---

# Entitlements

Kolom requires minimal but specific entitlements.

## Required Entitlements

* Input Method usage permissions (IMK system registration)
* App Sandbox (optional depending on distribution strategy)
* Accessibility access (if used for advanced text handling)

---

## Recommended Entitlements Strategy

For V1:

* Prefer **minimal entitlements**
* Avoid unnecessary sandbox restrictions if they interfere with IME behavior
* Keep system interaction permissions explicit

---

# Signing Process

## Step 1: Build App

Ensure:

* Architecture = `arm64`
* Release configuration
* No debug artifacts

---

## Step 2: Sign Components Individually

Each module must be signed before bundling:

```text id="sig1"
codesign --force --sign "Developer ID Application" Kolom.app
```

---

## Step 3: Verify Signature

Validation:

```text id="sig2"
codesign --verify --deep --strict --verbose=2 Kolom.app
```

Expected result:

* No errors
* All nested components validated

---

## Step 4: Notarization (Required for Distribution)

Submit to Apple notarization service:

* Ensures Gatekeeper approval
* Prevents “unidentified developer” warnings
* Required for external users

---

## Step 5: Staple Notarization Ticket

After approval:

```text id="sig3"
xcrun stapler staple Kolom.app
```

This allows offline validation.

---

# Input Method Specific Constraints

IMK-based components have stricter rules:

* Must be signed correctly OR macOS will silently ignore them
* Unsigned IME may not appear in Input Sources list
* Partial signing breaks system loading

---

# Common Failure Cases

## 1. IME not appearing in System Settings

Cause:

* Missing or invalid signature
* Not notarized (in external distribution)

---

## 2. IME loads but does not activate

Cause:

* Main binary signature mismatch
* Broken embedded framework signing

---

## 3. Crash on input activation

Cause:

* Architecture mismatch
* Corrupted signing chain
* Invalid entitlements

---

# Security Model

Kolom must guarantee:

* No runtime code injection
* No unsigned binaries loaded
* No external dynamic execution in production
* Deterministic signed artifacts

macOS will enforce this at runtime.

---

# Development vs Production Signing

## Development

* Developer ID or ad-hoc signing
* Not notarized
* Local testing only

---

## Production

* Full Developer ID signing
* Notarized
* Stapled ticket included
* Gatekeeper approved

---

# Update Safety

Every update must:

* Preserve signing identity
* Maintain bundle consistency
* Avoid mixing old and new signed components

A partially updated IME bundle is invalid.

---

# Verification Checklist

Before release:

* [ ] All binaries signed
* [ ] No unsigned embedded frameworks
* [ ] Notarization successful
* [ ] Stapler applied
* [ ] Verified with `codesign --verify`

---

# Relationship to Other Systems

Signing sits between:

```text id="signflow"
Build System
      ↓
Packaging
      ↓
Code Signing
      ↓
Notarization
      ↓
macOS Trust Layer
      ↓
Input Method Activation
```

Without this layer, Kolom cannot reach the user.

---

# Design Principle

Signing is not optional infrastructure.

It is a **hard requirement of macOS trust boundaries**.

> A correctly built IME that is not signed is functionally invisible to the system.
