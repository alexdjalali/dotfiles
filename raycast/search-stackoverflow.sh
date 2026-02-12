#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search Stack Overflow
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📚
# @raycast.argument1 { "type": "text", "placeholder": "search query" }
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Search Stack Overflow
# @raycast.author Alex Djalali

QUERY=$(echo "$1" | sed 's/ /+/g')
open "https://stackoverflow.com/search?q=$QUERY"

echo "Searching Stack Overflow for: $1"
