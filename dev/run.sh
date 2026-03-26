#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# This script is for running the application on various platforms.
# It has been refactored to be non-destructive and more efficient.
# It no longer uses `flutter create .` or `rm -rf`, which can cause loss of native configuration.

##
# Run Linux
##
if [ "$1" == "linux" ]; then
  flutter config --enable-linux-desktop
  rm -rf ./linux
  flutter create . --platforms=linux
  flutter clean
  flutter pub get
  #flutter pub run flutter_launcher_icons
  flutter run -d linux
fi

##
# Run MacOs
##
if [ "$1" == "macos" ]; then
  flutter config --enable-macos-desktop
  flutter pub get
  flutter pub run flutter_launcher_icons
  flutter run -d macos
fi

##
# Run iOS
##
if [ "$1" == "ios" ]; then
  flutter config --enable-ios
  flutter pub get
  flutter pub run flutter_launcher_icons
  echo "Available iOS simulators:"
  flutter emulators
  echo "To run, use: flutter run -d <emulator_id>"
  echo "Or connect a physical device and use: flutter run"
fi

##
# Run Android
##
if [ "$1" == "android" ]; then
  flutter config --enable-android
  flutter pub get
  flutter pub run flutter_launcher_icons
  echo "Available Android emulators:"
  flutter emulators
  echo "To run, use: flutter run -d <emulator_id>"
  echo "Or connect a physical device and use: flutter run"
fi