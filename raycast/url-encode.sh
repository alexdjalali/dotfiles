#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title URL Encode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔗
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description URL encode clipboard content
# @raycast.author Alex Djalali

encoded=$(pbpaste | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip(), safe=''))")
echo -n "$encoded" | pbcopy
echo "URL encoded and copied to clipboard"
