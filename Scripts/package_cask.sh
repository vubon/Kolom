#!/bin/bash
set -e

echo "=== Kolom Cask & Release Packaging Script ==="

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# 1. Determine Version
VERSION=$(grep 'MARKETING_VERSION:' project.yml | awk '{print $2}' | tr -d '"')
if [ -z "$VERSION" ]; then
    echo "Error: Could not extract MARKETING_VERSION from project.yml"
    exit 1
fi

echo "Packaging release for Kolom v${VERSION}..."

BUILD_DIR="$PROJECT_DIR/build_release_out"
rm -rf "$BUILD_DIR"
ZIP_NAME="Kolom-v${VERSION}.zip"
ZIP_PATH="$PROJECT_DIR/$ZIP_NAME"
rm -f "$ZIP_PATH"

# 2. Build Release Application
echo "Building Kolom in Release mode..."
xcodebuild clean build \
    -project Kolom.xcodeproj \
    -scheme Kolom \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    > /dev/null

BUILT_APP="$BUILD_DIR/Build/Products/Release/Kolom.app"
if [ ! -d "$BUILT_APP" ]; then
    echo "Error: Failed to find Kolom.app at $BUILT_APP"
    exit 1
fi

# 3. Create ZIP Archive
echo "Compressing $ZIP_NAME..."
(cd "$BUILD_DIR/Build/Products/Release" && zip -r -y -q "$ZIP_PATH" "Kolom.app")

# 4. Compute SHA-256 Checksum
SHA256=$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')
echo "Calculated SHA-256: $SHA256"

# 5. Build PKG Installer
echo "Building PKG installer..."
./Scripts/build_pkg.sh
PKG_NAME="Kolom-v${VERSION}.pkg"
PKG_PATH="$PROJECT_DIR/$PKG_NAME"

# 6. Generate Casks/kolom.rb
mkdir -p "$PROJECT_DIR/Casks"
CASK_FILE="$PROJECT_DIR/Casks/kolom.rb"

cat <<EOF > "$CASK_FILE"
cask "kolom" do
  version "${VERSION}"
  sha256 "${SHA256}"

  url "https://github.com/vubon/Kolom/releases/download/v#{version}/Kolom-v#{version}.zip"
  name "Kolom"
  desc "Native Bengali keyboard for Apple Silicon Macs"
  homepage "https://github.com/vubon/Kolom"

  depends_on arch: :arm64
  depends_on macos: :ventura

  input_method "Kolom.app"

  postflight do
    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", "#{Dir.home}/Library/Input Methods/Kolom.app"]
  end

  zap trash: [
    "~/Library/Preferences/com.kolom.inputmethod.plist",
    "~/Library/Application Support/Kolom",
  ]
end
EOF

echo "Generated $CASK_FILE successfully."

# 7. Upload to GitHub Release
if command -v gh &> /dev/null; then
    TAG="v${VERSION}"
    echo "Uploading assets to GitHub Release $TAG..."
    gh release upload "$TAG" "$ZIP_PATH" "$PKG_PATH" --clobber
    echo "Release assets uploaded successfully!"
else
    echo "Notice: gh CLI not found, skipping asset upload."
fi

# 8. Clean up build directory
rm -rf "$BUILD_DIR"

echo "=== Packaging Complete ==="
echo "Version:  $VERSION"
echo "ZIP:      $ZIP_PATH"
echo "PKG:      $PKG_PATH"
echo "SHA-256:  $SHA256"
echo "Cask:     $CASK_FILE"
