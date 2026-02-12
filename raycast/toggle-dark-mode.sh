#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Dark Mode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌙
# @raycast.packageName System

# Documentation:
# @raycast.description Toggle system dark/light mode
# @raycast.author Alex Djalali

osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to not dark mode'

# Get current mode for notification
mode=$(osascript -e 'tell app "System Events" to tell appearance preferences to get dark mode')

if [ "$mode" == "true" ]; then
    echo "Dark mode enabled"
else
    echo "Light mode enabled"
fi
