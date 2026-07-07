# Contributing to Kolom

First off, thank you for considering contributing to Kolom! Kolom is an open-source, privacy-first Bengali input method for macOS, and community contributions are highly valued.

Whether it's reporting a bug, proposing a new feature, or submitting a Pull Request, your help makes Kolom better for everyone.

## Table of Contents
1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Architecture Overview](#architecture-overview)
4. [Development Workflow](#development-workflow)
5. [Submitting a Pull Request](#submitting-a-pull-request)

## Code of Conduct
By participating in this project, you agree to abide by standard open-source conduct: be respectful, welcoming, and collaborative. 

## Getting Started

To contribute code to Kolom, you'll need:
* An Apple Silicon Mac (M1/M2/M3/M4) running macOS 13.0 or newer.
* Xcode 15.0 or newer.
* `xcodegen` to generate the project files.

### Setting up your environment

1. **Fork the repository** on GitHub.
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/kolom.git
   cd kolom
   ```
3. **Generate the Xcode project**:
   ```bash
   xcodegen generate --spec project.yml
   ```
4. **Open the project**:
   ```bash
   open Kolom.xcodeproj
   ```

## Architecture Overview

Kolom is built on macOS's **Input Method Kit (IMK)**. It is heavily modularized to ensure speed and stability. 

If you are modifying code, please familiarise yourself with the directory structure:
* **KolomApp/**: Application bootstrapping and the macOS menu bar agent.
* **KolomInputMethod/**: Core IME components that intercept keystrokes and render the Candidate Window.
* **KolomEngine/**: The phonetic parsing engine (transliteration rules and buffer state).
* **KolomDictionary/**: The lexicon services (Core vocabulary and User dictionary).
* **KolomSettings/**: SwiftUI views for the Preferences panel.

For a deeper dive, read the [System Architecture](docs/00-system-architecture.md) and [Engineering Principles](docs/PRINCIPLES.md).

## Development Workflow

### Building and Testing

1. **Compile and Run**: Use the `install.sh` script to quickly build the Release version and register it with your system.
   ```bash
   ./install.sh
   ```
2. **Run Unit Tests**: Before submitting any PR, ensure that all unit tests pass. You can run them directly from the command line:
   ```bash
   xcodebuild test -project Kolom.xcodeproj -scheme KolomTests -destination 'platform=macOS'
   ```
   Or inside Xcode by pressing **⌘U**.

### Code Guidelines
- Kolom is written entirely in Swift. Please follow standard Swift API Design Guidelines.
- **Strict Concurrency**: Kolom relies heavily on asynchronous Tasks and MainActor isolation to prevent deadlocks with host applications (like Chrome or Terminal). Avoid adding synchronous IPC calls (`client.attributes`, `client.insertText`) on the main thread if possible.
- **Privacy First**: Do not add any analytics, tracking, or network requests. Kolom must function 100% offline.

## Submitting a Pull Request

1. Create a new branch for your feature or bugfix:
   ```bash
   git checkout -b feature/my-awesome-feature
   ```
2. Make your changes, adding tests if applicable.
3. Ensure the test suite passes (`⌘U`).
4. Commit your changes with a descriptive commit message.
5. Push your branch to your fork:
   ```bash
   git push origin feature/my-awesome-feature
   ```
6. Open a Pull Request against the `main` branch of the original `kolom` repository.

In your PR description, clearly state the problem you are solving and how your changes implement the fix. If it's a UI change, please include screenshots!

Thank you for contributing!
