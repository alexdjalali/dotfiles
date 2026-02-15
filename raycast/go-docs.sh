#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Go Package Docs
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🐹
# @raycast.argument1 { "type": "text", "placeholder": "package name" }
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Open Go package documentation
# @raycast.author Alex Djalali

PACKAGE="$1"
open "https://pkg.go.dev/$PACKAGE"

echo "Opening docs for: $PACKAGE"
