#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Python Package Docs
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🐍
# @raycast.argument1 { "type": "text", "placeholder": "package name" }
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Open Python package on PyPI
# @raycast.author Alex Djalali

PACKAGE="$1"
open "https://pypi.org/project/$PACKAGE/"

echo "Opening PyPI for: $PACKAGE"
