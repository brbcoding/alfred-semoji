#!/bin/bash

# Install script for Emoji Semantic Search Alfred Workflow

set -e

WORKFLOW_NAME="Emoji Semantic Search"
WORKFLOW_DIR="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows"

# Find an available workflow folder name
INSTALL_DIR=""
for i in "" ".1" ".2" ".3" ".4" ".5"; do
    CANDIDATE="$WORKFLOW_DIR/user.workflow.emoji-search$i"
    if [ ! -d "$CANDIDATE" ]; then
        INSTALL_DIR="$CANDIDATE"
        break
    fi
done

if [ -z "$INSTALL_DIR" ]; then
    echo "Error: Could not find available workflow directory"
    exit 1
fi

echo "Installing $WORKFLOW_NAME to Alfred..."

# Build if binary doesn't exist
if [ ! -f "emoji-search" ]; then
    echo "Building binary..."
    go build -o emoji-search .
fi

# Create workflow directory
mkdir -p "$INSTALL_DIR"

# Copy files
cp emoji-search "$INSTALL_DIR/"
cp info.plist "$INSTALL_DIR/"

echo ""
echo "✅ Workflow installed successfully!"
echo ""
echo "Usage:"
echo "  1. Open Alfred (Cmd+Space or your hotkey)"
echo "  2. Type: emoji <search term>"
echo ""
echo "Examples:"
echo "  emoji happy    → 😀 😃 😄 😊"
echo "  emoji love     → ❤️ 😍 💕 🥰"
echo "  emoji think    → 🤔"
echo "  emoji celebrate → 🎉 🥳 🎊"
echo ""
echo "Actions:"
echo "  Press Enter     → Copy emoji to clipboard"
echo "  Press Cmd+Enter → Paste emoji directly"
