#!/bin/bash
APP_ID="$1"
if [ -z "$APP_ID" ]; then
  echo "Usage: $0 <app_id>"
  exit 1
fi

# Setup variables
APP_ID="$1"
PROJECT_NAME=$(grep '^name: ' pubspec.yaml | sed 's/name: //')

# Capture absolute paths
PROJECT_ROOT="$(pwd)"
FLUTTER_BUNDLE_ABS="$PROJECT_ROOT/build/linux/x64/release/bundle"
OUTPUT_DIR="$PROJECT_ROOT/compiled/$APP_ID"

# Run the Flutter build
flutter build linux --release

# Create and move to the isolated output directory
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# Create the Manifest
cat <<EOF > "${APP_ID}.yml"
id: ${APP_ID}
runtime: org.gnome.Platform
runtime-version: '49'
sdk: org.gnome.Sdk
command: start-app
finish-args:
  - --share=ipc
  - --socket=x11
  - --socket=wayland
  - --socket=fallback-x11
  - --device=dri
  - --talk-name=org.freedesktop.secrets
modules:
  - name: app-module
    buildsystem: simple
    build-commands:
      # Install Executable & Engine Data
      - install -D ${PROJECT_NAME} /app/bin/${PROJECT_NAME}
      - install -D lib/libapp.so /app/bin/lib/libapp.so
      - install -D lib/libapp.so /app/lib/libapp.so
      - mkdir -p /app/lib && cp lib/*.so /app/lib/
      - mkdir -p /app/bin/data && cp -r data/* /app/bin/data/
      - mkdir -p /app/bin
      - mkdir -p /app/lib
      - mkdir -p /app/share/applications
      - mkdir -p /app/share/icons/hicolor/512x512/apps
      - ln -s /app/bin/${PROJECT_NAME} /app/bin/start-app

      # Install Desktop File (Menu Shortcut)
      - mkdir -p /app/share/applications
      - |
        cat <<INNEREOF > /app/share/applications/${APP_ID}.desktop
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=${PROJECT_NAME}
        Comment="App"
        Exec=start-app
        Icon=${APP_ID}
        Terminal=false
        Categories=Utility;
        INNEREOF
      - install -D icon.png /app/share/icons/hicolor/512x512/apps/${APP_ID}.png
    sources:
      - type: dir
        path: ${FLUTTER_BUNDLE_ABS}
      - type: file
        path: ${PROJECT_ROOT}/assets/desktop/icon.png
        dest-filename: icon.png  
EOF

# Build and Install
flatpak-builder --force-clean --user --install --disable-rofiles-fuse --install-deps-from=flathub repo "${APP_ID}.yml"

echo "Installation complete!"
echo "1. Run via terminal: flatpak run $APP_ID"
echo "2. Or find '${PROJECT_NAME}' in your applications menu."
