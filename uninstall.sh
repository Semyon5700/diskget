#!/bin/bash

# Uninstallation script for diskget
# Copyright (C) 2025 Semyon5700

set -e

PROJECT_NAME="diskget"
INSTALL_DIR="/opt/$PROJECT_NAME"
BIN_LINK="/usr/local/bin/$PROJECT_NAME"

echo "🗑️  Uninstalling diskget..."

# Remove symlink
if [[ -L "$BIN_LINK" ]]; then
    echo "🔗 Removing symlink: $BIN_LINK"
    sudo rm "$BIN_LINK"
else
    echo "ℹ️  Symlink not found: $BIN_LINK"
fi

# Remove installation directory
if [[ -d "$INSTALL_DIR" ]]; then
    echo "📁 Removing installation directory: $INSTALL_DIR"
    sudo rm -rf "$INSTALL_DIR"
else
    echo "ℹ️  Installation directory not found: $INSTALL_DIR"
fi

echo "✅ Uninstallation completed successfully!"
echo "Thank you for using diskget!"
