#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Generate UUID
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔑
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Generate a new UUID and copy to clipboard
# @raycast.author Alex Djalali

uuid=$(uuidgen | tr '[:upper:]' '[:lower:]')
echo -n "$uuid" | pbcopy
echo "Copied: $uuid"
