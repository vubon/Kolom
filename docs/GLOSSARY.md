# Glossary

**File:** `docs/GLOSSARY.md`

---

# Kolom Glossary

> This document defines the terminology used throughout the Kolom project.

---

# A

## Ambiguity Resolution
The process of intercepting phonetic collisions. E.g., when a user types `t` at the end of a word, it naturally maps to `ত`, but the user may have meant Khanda Ta `ৎ`. The engine resolves this by suggesting dictionary words ending in `ৎ`.

# C

## Candidate
A suggested word or phrase presented to the user during typing.

## Candidate Engine
The component responsible for generating, filtering, and ranking candidates by prioritizing the User Dictionary and falling back to the Core Dictionary.

## Candidate Window
The user interface that displays candidates. In Kolom, this is a floating **Horizontal** bar.

## Commit
The action of finalizing composed text and inserting it into the active application. Once committed, the word is saved to the User Dictionary for auto-learning.

## Composition
Temporary text being edited before it is committed (represented by underlined text).

# D

## Dictionary
The primary collections of Bengali words.
- **Core Dictionary:** Shipped with the app.
- **User Dictionary:** Dynamically learns from user typing.

# H

## Hasanta (Hasant / Hoshonto)
The explicit linking character `্`. Typed via backtick (\`), it explicitly suppresses the inherent vowel of a consonant, or links two consonants to form a Conjunct.

# I

## IME
Input Method Editor. Software that converts keyboard input into text for another language.

## Input Method
The macOS component (Input Method Kit) responsible for receiving keyboard events.

## Input Session
Represents a single active typing session. 

# P

## Phonetic Typing
A typing method where Latin characters are converted into Bengali text based on pronunciation (e.g. `ami` -> `আমি`).

# T

## Transliteration
The process of converting Latin keyboard input into Bengali Unicode text (e.g. `amar` -> `আমার`). This is language conversion, not translation.

# U

## Unicode
The international standard for representing text. 

## User Dictionary
A local, auto-expanding JSON collection of user-defined words stored in `~/Library/Application Support/KolomIME/`. Used to rank user vocabulary higher than core words.
