#!/bin/bash
APP_ID="$1"
if [ -z "$APP_ID" ]; then
  echo "Usage: $0 <app_id>"
  exit 1
fi

PROJECT_NAME=$(grep '^name: ' pubspec.yaml | sed 's/name: //')
PROJECT_ROOT="$(pwd)"
BUILD_DIR="$PROJECT_ROOT/build/macos/Build/Products/Release"
APP_BUNDLE="${BUILD_DIR}/${PROJECT_NAME}.app"
OUTPUT_DIR="$PROJECT_ROOT/compiled/$APP_ID"
DMG_NAME="${PROJECT_NAME}.dmg"

# Build the Flutter macOS app
flutter build macos --release

# Make sure the app bundle exists
if [ ! -d "$APP_BUNDLE" ]; then
  echo "ERROR: App bundle not found at $APP_BUNDLE"
  exit 2
fi

# Prepare output directory
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Copy the .app bundle to output directory
cp -R "$APP_BUNDLE" "$OUTPUT_DIR/"

# Create the DMG
hdiutil create \
  -volname "$PROJECT_NAME" \
  -srcfolder "$OUTPUT_DIR" \
  -ov -format UDZO \
  "$OUTPUT_DIR/$DMG_NAME"

echo ""
echo "Installation complete!"
echo "1. Open the DMG file: $OUTPUT_DIR/$DMG_NAME"
echo "2. Drag '${PROJECT_NAME}.app' to your /Applications folder."
echo "3. Launch '${PROJECT_NAME}' from your Applications folder or via Spotlight search."