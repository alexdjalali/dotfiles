#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Start Dev Stack
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🚀
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Start full development environment
# @raycast.author Alex Djalali

echo "Starting dev stack..."

# Start Docker if not running
if ! docker info > /dev/null 2>&1; then
    echo "Starting Docker..."
    open -a "Docker"
    sleep 5
fi

# Open iTerm
open -a "iTerm"

# Open TablePlus
open -a "TablePlus"

# Open Chrome with dev profile
open -a "Google Chrome"

echo "✅ Dev stack ready!"
