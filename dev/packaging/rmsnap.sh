#!/bin/bash
APP_ID=$(echo "$1" | tr '.' '-' | tr '[:upper:]' '[:lower:]')
if snap list | grep -q "^$APP_ID "; then
    echo "Removing snap package: $APP_ID..."
    sudo snap remove --purge "$APP_ID"
else
    echo "Error: Snap package '$APP_ID' is not installed."
fi