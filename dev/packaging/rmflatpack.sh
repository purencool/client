#!/bin/bash

# Setup variables
APP_ID="$1"
echo "Uninstalling $APP_ID..."
flatpak uninstall --user --delete-data -y $APP_ID
echo "Cleaning up unused runtimes..."
flatpak uninstall --unused -y
if [ -d "$HOME/.local/share/flatpak/exports/share/applications/" ]; then
    update-desktop-database ~/.local/share/flatpak/exports/share/applications/
fi
echo "Uninstallation complete. '$APP_ID' and its shortcut have been removed."

