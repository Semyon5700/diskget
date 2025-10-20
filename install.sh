#!/bin/bash

# Installation script for diskget
# Copyright (C) 2025 Semyon5700

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="diskget"
INSTALL_DIR="/opt/$PROJECT_NAME"
BIN_LINK="/usr/local/bin/$PROJECT_NAME"

show_help() {
    cat << EOF
Installation script for diskget utility

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
    -u, --uninstall Uninstall diskget
    -v, --verbose   Enable verbose output

EOF
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo "❌ Error: Do not run this script as root."
        echo "The script will request sudo privileges when needed."
        exit 1
    fi
}

check_dependencies() {
    local deps=("sudo" "find" "df" "awk")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "❌ Error: Required tool '$dep' is not installed."
            exit 1
        fi
    done
}

install_diskget() {
    echo "🚀 Installing diskget..."
    
    # Create installation directory
    echo "📁 Creating installation directory: $INSTALL_DIR"
    sudo mkdir -p "$INSTALL_DIR"
    
    # Copy main script
    echo "📄 Installing main script..."
    sudo cp "$SCRIPT_DIR/diskget.sh" "$INSTALL_DIR/"
    sudo chmod +x "$INSTALL_DIR/diskget.sh"
    
    # Copy uninstall script
    if [[ -f "$SCRIPT_DIR/uninstall.sh" ]]; then
        echo "📄 Installing uninstall script..."
        sudo cp "$SCRIPT_DIR/uninstall.sh" "$INSTALL_DIR/"
        sudo chmod +x "$INSTALL_DIR/uninstall.sh"
    fi
    
    # Create symlink in /usr/local/bin
    echo "🔗 Creating symlink: $BIN_LINK -> $INSTALL_DIR/diskget.sh"
    sudo ln -sf "$INSTALL_DIR/diskget.sh" "$BIN_LINK"
    
    echo "✅ Installation completed successfully!"
    echo
    echo "Usage:"
    echo "  diskget --help"
    echo "  diskget --version"
}

uninstall_diskget() {
    echo "🗑️  Uninstalling diskget..."
    
    # Remove symlink
    if [[ -L "$BIN_LINK" ]]; then
        echo "🔗 Removing symlink: $BIN_LINK"
        sudo rm "$BIN_LINK"
    fi
    
    # Remove installation directory
    if [[ -d "$INSTALL_DIR" ]]; then
        echo "📁 Removing installation directory: $INSTALL_DIR"
        sudo rm -rf "$INSTALL_DIR"
    fi
    
    echo "✅ Uninstallation completed successfully!"
}

# Parse arguments
VERBOSE=false
UNINSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -u|--uninstall)
            UNINSTALL=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "❌ Error: Unknown option $1"
            show_help
            exit 1
            ;;
    esac
done

if $VERBOSE; then
    set -x
fi

check_root
check_dependencies

if $UNINSTALL; then
    uninstall_diskget
else
    install_diskget
fi
