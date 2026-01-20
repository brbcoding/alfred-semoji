#!/bin/bash

# Build script for Emoji Semantic Search Alfred Workflow

set -e

echo "Building Emoji Semantic Search..."

# Ensure the Perl script is executable
chmod +x emoji-search.pl

# Create the workflow package
rm -f "Emoji Semantic Search.alfredworkflow"
zip -j "Emoji Semantic Search.alfredworkflow" emoji-search.pl info.plist icon.png 2>/dev/null || \
zip -j "Emoji Semantic Search.alfredworkflow" emoji-search.pl info.plist

echo "Build complete! Workflow: Emoji Semantic Search.alfredworkflow"
echo ""
echo "To install: Double-click 'Emoji Semantic Search.alfredworkflow'"
