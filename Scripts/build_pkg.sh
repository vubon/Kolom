#!/bin/bash
set -e

echo "=== Kolom PKG Build Script ==="

DEVELOPER_ID_APP=""
DEVELOPER_ID_INSTALLER=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --sign-app) DEVELOPER_ID_APP="$2"; shift ;;
        --sign-pkg) DEVELOPER_ID_INSTALLER="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# 1. Build Kolom via Xcode
echo "Building Kolom in Release mode..."
BUILD_DIR="$(pwd)/build_pkg_out"
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

echo "Successfully built Kolom.app"

# 2. Optional: Sign App
if [ -n "$DEVELOPER_ID_APP" ]; then
    echo "Signing Kolom.app with Developer ID Application: $DEVELOPER_ID_APP..."
    codesign --force --options runtime --sign "$DEVELOPER_ID_APP" "$BUILT_APP"
fi

# 3. Create PKG
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$BUILT_APP/Contents/Info.plist")
PKG_NAME="Kolom-v${VERSION}.pkg"
OUTPUT_PKG="$(pwd)/$PKG_NAME"

echo "Packaging $PKG_NAME..."
PAYLOAD_DIR="$BUILD_DIR/Payload"
mkdir -p "$PAYLOAD_DIR"
cp -R "$BUILT_APP" "$PAYLOAD_DIR/"

# Prevent app relocation by the macOS installer
COMPONENTS_PLIST="$BUILD_DIR/components.plist"
pkgbuild --analyze --root "$PAYLOAD_DIR" "$COMPONENTS_PLIST" > /dev/null
/usr/libexec/PlistBuddy -c "Set :0:BundleIsRelocatable false" "$COMPONENTS_PLIST"

PKG_CMD=(pkgbuild --root "$PAYLOAD_DIR"
         --component-plist "$COMPONENTS_PLIST"
         --identifier "com.kolom.inputmethod.Kolom"
         --version "$VERSION"
         --install-location "/tmp/KolomInstall"
         --scripts "Scripts/Packaging"
         "$OUTPUT_PKG")

if [ -n "$DEVELOPER_ID_INSTALLER" ]; then
    echo "Signing PKG with Developer ID Installer: $DEVELOPER_ID_INSTALLER..."
    PKG_CMD+=(--sign "$DEVELOPER_ID_INSTALLER")
fi

"${PKG_CMD[@]}"

echo "=== Success ==="
echo "Created installer package: $OUTPUT_PKG"
