#!/usr/bin/env bash

# Exit on error
set -e

DOWNLOADS="$HOME/Downloads"

# Find all .deb files containing "upwork" in their name
mapfile -t packages < <(find "$DOWNLOADS" -maxdepth 1 -type f -iname "*upwork*.deb")

# Ensure at least one package was found
if [ ${#packages[@]} -eq 0 ]; then
    echo "No Upwork packages were found in $DOWNLOADS."
    exit 1
fi

echo "Select the Upwork package to install:"

select DEB_FILE in "${packages[@]}"; do
    if [[ -n "$DEB_FILE" ]]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

echo "=== Installing Upwork Desktop App ==="

# Update repositories
echo "--> Updating package list..."
sudo apt update

# Create temporary workspace
WORKDIR=$(mktemp -d)
BUILD_DIR="$WORKDIR/build"

trap 'rm -rf "$WORKDIR"' EXIT

mkdir "$BUILD_DIR"

echo "--> Extracting package..."
dpkg-deb -R "$DEB_FILE" "$BUILD_DIR"

CONTROL_FILE="$BUILD_DIR/DEBIAN/control"

# Patch old dependency name for Ubuntu 26.04+
if grep -q "libgdk-pixbuf2.0-0" "$CONTROL_FILE"; then
    echo "--> Patching obsolete dependency: libgdk-pixbuf2.0-0"

    sed -i \
        's/libgdk-pixbuf2\.0-0/libgdk-pixbuf-2.0-0/g' \
        "$CONTROL_FILE"
fi

PATCHED_DEB="$WORKDIR/upwork-patched.deb"

echo "--> Rebuilding package..."
dpkg-deb --build --root-owner-group "$BUILD_DIR" "$PATCHED_DEB"

echo "--> Installing package..."

sudo apt install -y "$PATCHED_DEB"

echo
echo "✅ Upwork installed successfully."
echo "=== Done! ==="
