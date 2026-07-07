#!/bin/bash
set -e

echo "=== Kolom Uninstaller ==="

echo "1. Killing Kolom if running..."
killall Kolom 2>/dev/null || true

echo "2. Removing Kolom.app from Input Methods directories..."
rm -rf "$HOME/Library/Input Methods/Kolom.app"
sudo rm -rf "/Library/Input Methods/Kolom.app" 2>/dev/null || true

echo "3. Clearing system input caches..."
find /private/var/folders -name "*IntlDataCache*" -delete 2>/dev/null || true
killall -9 TextInputMenuAgent TextInputSwitcher 2>/dev/null || true
killall -HUP ControlCenter 2>/dev/null || true
killall -9 SystemSettings 2>/dev/null || true

echo "=== Uninstall Complete ==="
echo "If Kolom still appears in your Keyboard Settings, you may need to restart your Mac."
