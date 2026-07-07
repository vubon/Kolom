#!/bin/bash

# Exit on error
set -e

echo "=== Kolom IME Deploy Helper ==="

# 1. Kill any active instance
echo "Stopping any running instances of Kolom..."
killall Kolom 2>/dev/null || true

# 2. Find the most recently built Kolom.app in Xcode DerivedData
echo "Searching for the built bundle in Xcode DerivedData..."
DERIVED_DATA_DIR="$HOME/Library/Developer/Xcode/DerivedData"

if [ ! -d "$DERIVED_DATA_DIR" ]; then
    echo "Error: Xcode DerivedData directory not found. Please compile the project in Xcode first (⌘B)."
    exit 1
fi

# Find the newest Kolom.app directory under DerivedData
BUILT_APP_PATH=$(find "$DERIVED_DATA_DIR" -type d -name "Kolom.app" -not -path "*/Index.noindex/*" -path "*/Build/Products/Debug/Kolom.app" | xargs stat -f "%m %N" | sort -rn | head -n 1 | cut -d' ' -f2-)

if [ -z "$BUILT_APP_PATH" ] || [ ! -d "$BUILT_APP_PATH" ]; then
    echo "Error: Could not find built Kolom.app in DerivedData. Make sure you build the 'Kolom' scheme in Xcode first!"
    exit 1
fi

echo "Found built bundle: $BUILT_APP_PATH"

# 3. Clean up the global Applications directory to avoid conflicts
echo "Cleaning up global Applications directory..."
rm -rf "/Applications/Kolom.app"

# 4. Copy to user Library Input Methods directory (mandatory for system registration)
TARGET_DIR="$HOME/Library/Input Methods"
echo "Preparing target in '$TARGET_DIR'..."
mkdir -p "$TARGET_DIR"
rm -rf "$TARGET_DIR/Kolom.app"

echo "Copying bundle to Input Methods directory..."
cp -R "$BUILT_APP_PATH" "$TARGET_DIR/"

# 5. Launch the bundle once to register with macOS Input Method Kit
echo "Forcing Launch Services registration database refresh..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u "/Applications/Kolom.app" 2>/dev/null || true
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$TARGET_DIR/Kolom.app"

echo "Launching app bundle to trigger macOS system registration..."
open "$TARGET_DIR/Kolom.app"

# 6. Force reload the system menu bar services to flush input source caches
echo "Reloading system text services and clearing caches..."
find /private/var/folders -name "*IntlDataCache*" -delete 2>/dev/null || true
killall -9 TextInputMenuAgent TextInputSwitcher 2>/dev/null || true
killall -HUP ControlCenter 2>/dev/null || true
killall -9 SystemSettings 2>/dev/null || true

echo "=== Success! ==="
echo "Please do the following now:"
echo "1. Open System Settings -> Keyboard -> Input Sources."
echo "2. Click '+' at the bottom."
echo "3. Search for 'Kolom' or select 'Bengali', and add 'Kolom'."
echo "4. Switch to Kolom using the macOS input switcher in your menu bar."
