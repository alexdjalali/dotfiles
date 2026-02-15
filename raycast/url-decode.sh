#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title URL Decode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔗
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description URL decode clipboard content
# @raycast.author Alex Djalali

decoded=$(pbpaste | python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read().strip()))")
echo -n "$decoded" | pbcopy
echo "URL decoded and copied to clipboard"
