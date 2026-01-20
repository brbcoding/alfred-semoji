#!/bin/bash

# Build script for Emoji Semantic Search Alfred Workflow

set -e

echo "Building Emoji Semantic Search..."

# Build for current architecture
go build -o emoji-search .

echo "Build complete! Binary: emoji-search"
echo ""
echo "To install the workflow:"
echo "1. Create a folder: 'Emoji Semantic Search.alfredworkflow'"
echo "2. Copy these files into it:"
echo "   - emoji-search (binary)"
echo "   - info.plist"
echo "3. Double-click the .alfredworkflow folder to install"
echo ""
echo "Or run: ./install.sh"
