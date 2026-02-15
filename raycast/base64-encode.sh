#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Base64 Encode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔐
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Encode clipboard content to Base64
# @raycast.author Alex Djalali

encoded=$(pbpaste | base64)
echo -n "$encoded" | pbcopy
echo "Base64 encoded and copied to clipboard"
