# System Architecture

**File:** `docs/00-system-architecture.md`

---

# Purpose

This document defines the architectural boundaries of Kolom. It establishes a shared understanding of the system's design, updated to reflect its current capabilities (such as the auto-learning user dictionary and ambiguity resolution).

---

# Architectural Goals

Kolom should be:

* Modular
* Predictable
* Native to macOS
* Easy to test
* Easy to maintain
* Easy to extend
* Optimized for Apple Silicon

Architecture should prioritize clarity over cleverness.

---

# High-Level Architecture

```text
┌───────────────────────────────┐
│ macOS                         │
│ Input Method Kit (IMK)        │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│ KolomInputMethod              │
│ Session Coordinator           │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│ KolomEngine                   │
│ Transliteration               │
│ Composition                   │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│ KolomDictionary               │
│ Core Lookup                   │
│ User Dictionary (Learning)    │
│ Ambiguity Resolution          │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│ Candidate Engine              │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│ Candidate Window (Horizontal) │
└───────────────────────────────┘
```

---

# Module Responsibilities

## KolomInputMethod

Responsibilities:
* Integrate with macOS via `IMKInputController`.
* Receive keyboard events (including arrow keys for candidate navigation).
* Manage input sessions.
* Coordinate typing and commit actions.

## KolomEngine

Responsibilities:
* Transliteration (parsing English inputs to Bengali phonetics using longest-prefix-matching).
* Composition state management.
* Must remain independent of macOS APIs.

## KolomDictionary

Responsibilities:
* `JSONDictionaryStore`: Core dictionary lookup using prefix matching.
* `UserDictionaryStore`: In-memory tracking of learned user words, with debounced background JSON serialization to minimize disk I/O.

## Candidate Engine

Responsibilities:
* Candidate generation by merging core and user dictionaries.
* Candidate ranking (sorting by frequency, prioritizing user words).
* Ambiguity Resolution: Intercepting common phonetic collisions (e.g. trailing `ত` being converted to Khanda Ta `ৎ` if it exists in the dictionary).

## Candidate Window

Responsibilities:
* Display suggestions in a modern, floating, **horizontal** SwiftUI view.
* Handle candidate selection states.
* Follow active cursor coordinates provided by the IMK.

## Settings

Responsibilities:
* User preferences (if applicable).
* Configuration.

---

# Dependency Rules

Allowed dependencies:

```text
Input Method
        │
        ▼
Engine
        │
        ▼
Dictionary
```

Not allowed:

```text
Dictionary
      │
      ▼
Input Method
```

Business logic must never depend on UI. UI may depend on business logic.

---

# Data Flow Principles

Data should flow in one direction:

```text
Input (Keystroke)
   │
   ▼
Engine (Transliteration)
   │
   ▼
Candidate Engine (Dictionary Lookup & Merging)
   │
   ▼
UI (Horizontal Candidate Window)
   │
   ▼
Commit (Saves to User Dictionary)
```

---

# Performance Principles

Optimize only after measurement.
Focus on:
* Dictionary lookup (fast prefix scanning).
* Composition updates.
* Memory allocation (keeping User Dictionary RAM footprint under ~5MB for 40,000 words).
* Background tasks (writing the User Dictionary to disk asynchronously).

Typing should remain responsive (under 16ms latency) under sustained input.
