#!/usr/bin/env bash

# Exit on error
set -e

APP_NAME="drsprinto"

DOWNLOADS="$HOME/Downloads"
TARGET_DIR="$HOME/Applications"
DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"

echo "=== Installing DrSprinto AppImage ==="

# Find DrSprinto AppImages
mapfile -t appimages < <(find "$DOWNLOADS" -maxdepth 1 -type f -iname "*drsprinto*.appimage")

# Ensure at least one AppImage was found
if [ ${#appimages[@]} -eq 0 ]; then
    echo "❌ No DrSprinto AppImage found in:"
    echo "$DOWNLOADS"
    exit 1
fi

echo "Select the DrSprinto AppImage to install:"

select APP_IMAGE in "${appimages[@]}"; do
    if [[ -n "$APP_IMAGE" ]]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

echo "--> Selected: $(basename "$APP_IMAGE")"

# Install FUSE support
echo "--> Installing FUSE support..."

sudo apt update
sudo apt install -y fuse3

# Create application directory
mkdir -p "$TARGET_DIR"

# Copy AppImage
APP_FILENAME="$(basename "$APP_IMAGE")"
TARGET_APP="$TARGET_DIR/$APP_FILENAME"

if [ -f "$TARGET_APP" ]; then
    echo "--> Existing installation found. Replacing..."
fi

cp -f "$APP_IMAGE" "$TARGET_APP"

echo "✅ Copied AppImage to $TARGET_APP"

# Make executable
chmod +x "$TARGET_APP"

echo "✅ Execution permission enabled"

# Create KDE application launcher
mkdir -p "$(dirname "$DESKTOP_FILE")"

cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=DrSprinto
Comment=DrSprinto AppImage
Exec=$TARGET_APP --no-sandbox
Icon=system-run
Type=Application
Categories=Utility;
Terminal=false
StartupNotify=true
EOF

echo "✅ Desktop entry created"

# Refresh application database
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" || true
fi

echo
echo "✅ DrSprinto installed successfully."
echo "Search for DrSprinto in KDE Application Launcher."
