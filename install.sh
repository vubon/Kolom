#!/bin/bash

# Exit on error
set -e

echo "=== Kolom Builder & Installer ==="
echo "This script will compile Kolom from source and install it on your Mac."

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "Error: xcodebuild is not installed."
    echo "You must install Xcode from the Mac App Store to compile Kolom."
    exit 1
fi

if [[ $(xcode-select -p) == *"CommandLineTools"* ]]; then
    echo "Error: Full Xcode is required to build this macOS application."
    echo "You currently only have the Command Line Tools installed."
    echo "Please install Xcode from the Mac App Store, open it once, and run:"
    echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    exit 1
fi

# 1. Build Kolom via Xcode
echo "Building Kolom..."
BUILD_DIR="$(pwd)/build_temp"
rm -rf "$BUILD_DIR"

xcodebuild clean build \
    -project Kolom.xcodeproj \
    -scheme Kolom \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    > /dev/null

BUILT_APP="$BUILD_DIR/Build/Products/Release/Kolom.app"

if [ ! -d "$BUILT_APP" ]; then
    echo "Error: Failed to find Kolom.app after build."
    exit 1
fi

echo "Successfully built Kolom.app!"

# 2. Install Kolom
TARGET_DIR="$HOME/Library/Input Methods"
APP_TARGET="$TARGET_DIR/Kolom.app"

echo "Installing to $TARGET_DIR..."
mkdir -p "$TARGET_DIR"

# Kill any existing instance
killall Kolom 2>/dev/null || true

# Remove old app and copy new one
rm -rf "$APP_TARGET"
cp -R "$BUILT_APP" "$APP_TARGET"

# 3. Register and Clear Caches
echo "Registering Kolom with macOS..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_TARGET"

# Open the app once in the background to ensure macOS registers it
open -g "$APP_TARGET"

echo "Clearing macOS Input Service caches..."
find /private/var/folders -name "*IntlDataCache*" -delete 2>/dev/null || true
killall -9 TextInputMenuAgent TextInputSwitcher 2>/dev/null || true
killall -HUP ControlCenter 2>/dev/null || true
killall -9 SystemSettings 2>/dev/null || true

# 4. Clean up build files
rm -rf "$BUILD_DIR"

echo "=== Installation Complete! ==="
echo "Kolom is now installed and running."
echo "You can now go to: System Settings -> Keyboard -> Input Sources to add it."
