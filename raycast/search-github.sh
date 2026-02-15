#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search GitHub
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🐙
# @raycast.argument1 { "type": "text", "placeholder": "search query" }
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Search GitHub repositories
# @raycast.author Alex Djalali

QUERY=$(python3 -c "import urllib.parse; print(urllib.parse.quote_plus('$1'))")
open "https://github.com/search?q=$QUERY&type=repositories"

echo "Searching GitHub for: $1"
