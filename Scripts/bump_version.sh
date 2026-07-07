#!/bin/bash

# Exit on error
set -e

PROJECT_YML="project.yml"

if [ ! -f "$PROJECT_YML" ]; then
    echo "Error: $PROJECT_YML not found. Please run this script from the project root."
    exit 1
fi

# Extract current versions from project.yml
CURRENT_VERSION=$(grep 'MARKETING_VERSION:' "$PROJECT_YML" | awk '{print $2}' | tr -d '"')
CURRENT_BUILD=$(grep 'CURRENT_PROJECT_VERSION:' "$PROJECT_YML" | awk '{print $2}')

if [ -z "$1" ]; then
    echo "Usage: ./Scripts/bump_version.sh <new_version> [build_number]"
    echo "Example: ./Scripts/bump_version.sh 1.0.1"
    echo "Current Version: $CURRENT_VERSION (Build $CURRENT_BUILD)"
    exit 1
fi

NEW_VERSION="$1"
BUILD_NUM="$2"

if [ -z "$BUILD_NUM" ]; then
    # Auto-increment the build number
    if [ -z "$CURRENT_BUILD" ]; then
        CURRENT_BUILD=0
    fi
    BUILD_NUM=$((CURRENT_BUILD + 1))
fi

echo "Updating project.yml to Version: $NEW_VERSION (Build: $BUILD_NUM)..."

# Update project.yml using sed
# macOS sed requires an empty string for the backup extension (-i '')
sed -i '' "s/MARKETING_VERSION:.*/MARKETING_VERSION: \"$NEW_VERSION\"/" "$PROJECT_YML"
sed -i '' "s/CURRENT_PROJECT_VERSION:.*/CURRENT_PROJECT_VERSION: $BUILD_NUM/" "$PROJECT_YML"

echo "Regenerating Xcode project..."
xcodegen generate --spec project.yml > /dev/null

echo "Done! Kolom is now at $NEW_VERSION (Build $BUILD_NUM)."
