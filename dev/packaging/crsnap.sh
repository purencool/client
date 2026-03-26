#!/bin/bash
APP_ID="$1"
if [ -z "$APP_ID" ]; then
  echo "Usage: $0 <app_id>"
  exit 1
fi

# Ensure we are in the project root
if [ ! -f pubspec.yaml ]; then
    echo "Error: Run this script from the Flutter project root."
    exit 1
fi

# Configuration
# Trimming for common snap naming conventions
APP_ID=$(echo "$1" | tr '.' '-' | tr '[:upper:]' '[:lower:]')
PROJECT_NAME=$(grep '^name: ' pubspec.yaml | sed 's/name: //')

# Clean local build artifacts
echo "Cleaning local build artifacts..."
flutter clean
rm -rf build/
rm -rf linux/flutter/ephemeral/

# Setup Snap GUI folder and Icon
echo "Setting up desktop icons..."
mkdir -p snap/gui

if [ -f "assets/desktop/icon.png" ]; then
    cp assets/desktop/icon.png "snap/gui/${APP_ID}.png"
else
    echo "Warning: assets/desktop/icon.png not found. Creating placeholder."
    convert -size 256x256 xc:blue "snap/gui/${APP_ID}.png" 2>/dev/null || touch "snap/gui/${APP_ID}.png"
fi

# Generate the .desktop file
cat <<EOF > "snap/gui/${APP_ID}.desktop"
[Desktop Entry]
Name=${PROJECT_NAME^}
Comment=Professional utility configuration tool.
Exec=${APP_ID}
Icon=\${SNAP}/meta/gui/${APP_ID}.png
Terminal=false
Type=Application
Categories=Utility;
EOF

# Generate snapcraft.yaml
cat <<EOF > snap/snapcraft.yaml
name: ${APP_ID}
version: '1.0'
summary: ${PROJECT_NAME}
description: |
  Synchronize organizational utility configurations across all professional devices.
base: core22
confinement: strict
grade: stable

apps:
  ${APP_ID}:
    command: ${PROJECT_NAME}
    extensions: [gnome]
    # REMOVED the 'desktop:' key. Snapcraft automatically finds 
    # snap/gui/${APP_ID}.desktop and places it in meta/gui/
    plugs:
      - network
      - opengl
      - wayland
      - x11

parts:
  ${PROJECT_NAME}:
    source: .
    plugin: flutter
    flutter-target: lib/main.dart
    build-packages:
      - libsecret-1-dev
      - pkg-config
      - libglib2.0-dev
    stage-packages:
      - libsecret-1-0
EOF

# Build using the specific 'pack' command to avoid deprecation warnings
echo "Starting build..."
snapcraft pack --use-lxd

rm -Rf  ./snap/*
mv  ./${APP_ID}_1.0_amd64.snap ./compiled/${APP_ID}_1.0_amd64.snap

echo "Build complete! Install your snap with:"
echo "sudo snap install ./${APP_ID}_1.0_amd64.snap --dangerous"
