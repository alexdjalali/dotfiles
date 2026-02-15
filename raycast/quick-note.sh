#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Quick Note
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📝
# @raycast.argument1 { "type": "text", "placeholder": "note content" }
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Add quick note to daily notes file
# @raycast.author Alex Djalali

NOTES_DIR="$HOME/notes"
TODAY=$(date +%Y-%m-%d)
NOTE_FILE="$NOTES_DIR/$TODAY.md"

mkdir -p "$NOTES_DIR"

# Create file with header if it doesn't exist
if [ ! -f "$NOTE_FILE" ]; then
    echo "# Notes for $TODAY" > "$NOTE_FILE"
    echo "" >> "$NOTE_FILE"
fi

# Append the note with timestamp
TIMESTAMP=$(date +%H:%M)
echo "- [$TIMESTAMP] $1" >> "$NOTE_FILE"

echo "✅ Note added to $TODAY.md"
