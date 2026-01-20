#!/bin/bash

# Build script for Emoji Semantic Search Alfred Workflow

set -e

echo "Building Semoji..."

# Ensure the Perl scripts are executable
chmod +x emoji-search.pl emoji-add.pl emoji-save.pl

# Create the workflow package
rm -f "Semoji.alfredworkflow"
zip -j "Semoji.alfredworkflow" emoji-search.pl emoji-add.pl emoji-save.pl info.plist icon.png 2>/dev/null || \
zip -j "Semoji.alfredworkflow" emoji-search.pl emoji-add.pl emoji-save.pl info.plist

echo "Build complete! Workflow: Semoji.alfredworkflow"
echo ""
echo "To install: Double-click 'Semoji.alfredworkflow'"
