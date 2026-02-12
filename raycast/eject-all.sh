#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Eject All Drives
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ⏏️
# @raycast.packageName System

# Documentation:
# @raycast.description Safely eject all external drives
# @raycast.author Alex Djalali

osascript -e 'tell application "Finder" to eject (every disk whose ejectable is true)'

echo "All external drives ejected"
