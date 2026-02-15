#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Format JSON
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📋
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Format JSON from clipboard and copy back
# @raycast.author Alex Djalali

json=$(pbpaste)

# Try to format with jq, fall back to python
if command -v jq &> /dev/null; then
    formatted=$(echo "$json" | jq '.' 2>/dev/null)
else
    formatted=$(echo "$json" | python3 -m json.tool 2>/dev/null)
fi

if [ $? -eq 0 ] && [ -n "$formatted" ]; then
    echo "$formatted" | pbcopy
    echo "JSON formatted and copied to clipboard"
else
    echo "Invalid JSON in clipboard"
    exit 1
fi
