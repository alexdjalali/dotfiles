#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Base64 Decode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔓
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Decode Base64 content from clipboard
# @raycast.author Alex Djalali

decoded=$(pbpaste | base64 -d 2>/dev/null)

if [ $? -eq 0 ]; then
    echo -n "$decoded" | pbcopy
    echo "Base64 decoded and copied to clipboard"
else
    echo "Invalid Base64 in clipboard"
    exit 1
fi
